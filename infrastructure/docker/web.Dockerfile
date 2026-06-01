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
COPY apps/web/package.json ./apps/web/

# Install workspace dependencies (using build cache for pnpm store)
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

# Copy the rest of the source code
COPY . .

# Build Next.js application
ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm --filter web build

# Production runner stage
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
EXPOSE 3000

# Copy static assets and next.js standalone bundle
COPY --from=builder /app/apps/web/public ./apps/web/public
COPY --from=builder /app/apps/web/.next/standalone ./
COPY --from=builder /app/apps/web/.next/static ./apps/web/.next/static

CMD ["node", "apps/web/server.js"]
