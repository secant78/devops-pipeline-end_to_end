FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine
RUN addgroup -g 1001 appgroup && adduser -u 1001 -G appgroup -s /bin/sh -D appuser
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY src/ ./src/
USER appuser
EXPOSE 3005
HEALTHCHECK --interval=30s --timeout=3s CMD wget -qO- http://localhost:3005/health || exit 1
CMD ["node", "src/index.js"]
