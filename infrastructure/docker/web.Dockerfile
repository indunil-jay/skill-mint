FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && corepack prepare pnpm@11.5.2 --activate

# ─── deps stage: install all workspace deps ────────────────────────────────
FROM base AS deps
WORKDIR /app

COPY pnpm-lock.yaml pnpm-workspace.yaml package.json .npmrc ./
COPY packages/config/eslint/package.json   ./packages/config/eslint/
COPY packages/config/prettier/package.json ./packages/config/prettier/
COPY packages/config/typescript/package.json ./packages/config/typescript/
COPY apps/web/package.json                 ./apps/web/

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm install --frozen-lockfile

# ─── builder stage: compile Next.js ─────────────────────────────────────────
FROM deps AS builder
WORKDIR /app

ENV CI=true
ENV NEXT_TELEMETRY_DISABLED=1

COPY apps/web  ./apps/web
COPY packages  ./packages

RUN pnpm --filter web build

# ─── runner stage: lean final image (Next.js standalone) ────────────────────
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
ENV NEXT_TELEMETRY_DISABLED=1
EXPOSE 3000

COPY --from=builder /app/apps/web/.next/standalone    ./
COPY --from=builder /app/apps/web/.next/static        ./apps/web/.next/static
COPY --from=builder /app/apps/web/public              ./apps/web/public

CMD ["node", "apps/web/server.js"]
