# ECS Cluster (Fargate - no EC2 nodes to manage or pay for at rest)
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled" # disabled to avoid CloudWatch costs; enable if observability is needed
  }

  tags = {
    Environment = "prod"
    Project     = "ecommerce-platform"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT" # Up to 70% cheaper than regular Fargate
    weight            = 4
    base              = 0
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1 # At least 1 task always on regular Fargate for stability
  }
}

# Security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.cluster_name}-ecs-tasks-sg"
  description = "Allow inbound from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-ecs-tasks-sg"
  }
}

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.cluster_name}-alb-sg"
  description = "Allow HTTP inbound"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-alb-sg"
  }
}

# Application Load Balancer (single ALB shared across all microservices - cheapest option)
resource "aws_lb" "main" {
  name               = "${var.cluster_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  # Access logs disabled by default to avoid S3 costs
  enable_deletion_protection = false

  tags = {
    Environment = "prod"
    Project     = "ecommerce-platform"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# IAM role for ECS task execution (pulling images, writing logs)
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.cluster_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch log group (single group for all services, 7-day retention to minimise cost)
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = 7

  tags = {
    Environment = "prod"
    Project     = "ecommerce-platform"
  }
}

# ─── Microservices ───────────────────────────────────────────────────────────
# Each service gets: task definition, ECS service, target group, and ALB rule.
# CPU/memory are set to the smallest Fargate-supported values (256 CPU / 512 MB).

locals {
  services = {
    frontend = {
      port        = 3000
      path_pattern = "/*"
      priority    = 100
    }
    api-gateway = {
      port        = 8080
      path_pattern = "/api/*"
      priority    = 10
    }
    user-service = {
      port        = 8081
      path_pattern = "/api/users/*"
      priority    = 20
    }
    product-service = {
      port        = 8082
      path_pattern = "/api/products/*"
      priority    = 30
    }
    order-service = {
      port        = 8083
      path_pattern = "/api/orders/*"
      priority    = 40
    }
  }
}

resource "aws_lb_target_group" "services" {
  for_each = local.services

  name        = "${var.cluster_name}-${each.key}"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # Required for Fargate

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Service = each.key
  }
}

resource "aws_lb_listener_rule" "services" {
  for_each = local.services

  listener_arn = aws_lb_listener.http.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.services[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.path_pattern]
    }
  }
}

resource "aws_ecs_task_definition" "services" {
  for_each = local.services

  family                   = "${var.cluster_name}-${each.key}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256  # Minimum Fargate unit
  memory                   = 512  # Minimum Fargate unit

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = each.key
    image     = "${var.ecr_registry}/${each.key}:latest"
    essential = true

    portMappings = [{
      containerPort = each.value.port
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = each.key
      }
    }
  }])

  tags = {
    Service = each.key
  }
}

resource "aws_ecs_service" "services" {
  for_each = local.services

  name            = each.key
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count   = 1 # Start with 1 task per service; scale via App Auto Scaling if needed

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 4
    base              = 0
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.services[each.key].arn
    container_name   = each.key
    container_port   = each.value.port
  }

  depends_on = [aws_lb_listener_rule.services]

  tags = {
    Service = each.key
  }

  lifecycle {
    ignore_changes = [task_definition] # Allow deployments without Terraform drift
  }
}
