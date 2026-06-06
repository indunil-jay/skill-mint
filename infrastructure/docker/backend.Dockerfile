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
COPY apps/backend/package.json             ./apps/backend/

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm install --frozen-lockfile --shamefully-hoist

# ─── builder stage: compile TypeScript ─────────────────────────────────────
FROM deps AS builder
WORKDIR /app

ENV CI=true

COPY apps/backend ./apps/backend
COPY packages     ./packages

RUN pnpm --filter backend build

# ─── prod-deps stage: production-only deps via pnpm deploy ──────────────────
FROM deps AS prod-deps
WORKDIR /app

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm --filter backend deploy --prod --legacy /prod/backend

# ─── runner stage: lean final image ─────────────────────────────────────────
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=4000
EXPOSE 4000

COPY --from=prod-deps /prod/backend/node_modules ./node_modules
COPY --from=prod-deps /prod/backend/package.json ./package.json
COPY --from=builder   /app/apps/backend/dist     ./dist

CMD ["node", "dist/main"]
