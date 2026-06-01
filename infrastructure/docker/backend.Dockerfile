# Base stage
FROM node:20-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

# Builder stage
FROM base AS builder
WORKDIR /app

# Copy root configs and package definitions
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY packages/config/eslint/package.json ./packages/config/eslint/
COPY packages/config/prettier/package.json ./packages/config/prettier/
COPY packages/config/typescript/package.json ./packages/config/typescript/
COPY apps/backend/package.json ./apps/backend/

# Install workspace dependencies (using build cache for pnpm store)
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

# Copy the rest of the source code
COPY . .

# Build the backend app
RUN pnpm --filter backend build

# Deploy production-only dependencies and built assets
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm --filter backend deploy --prod /prod/backend

# Final production stage
FROM base AS runner
WORKDIR /app

# Copy production dependencies and build artifacts from builder stage
COPY --from=builder /prod/backend/node_modules ./node_modules
COPY --from=builder /prod/backend/package.json ./package.json
COPY --from=builder /prod/backend/dist ./dist

# Set run environments
ENV NODE_ENV=production
ENV PORT=4000
EXPOSE 4000

CMD ["node", "dist/main"]
