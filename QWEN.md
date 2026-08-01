# Road Wave FM — Context Guide

## Project Overview

**Road Wave FM** is a monorepo that orchestrates multiple independent repositories supporting the Road Wave FM application — a radio station data platform. It uses **git submodules** to link sub-projects and provides shared tooling to ease developing them together.

All packages are published under the `@linkedmink` NPM scope and authored by Harlan Sang.

## Architecture

```
road-wave-fm (this repo — glue/submodule container)
├── packages/external-idp-user-api   ← NestJS API for external identity token verification
├── packages/road-wave-fm-rpc        ← TRPC data service providing radio station information
├── packages/road-wave-fm-web        ← React/MUI web frontend
├── packages/eip-4361-parser         ← EIP-4361 "Sign in with Ethereum" parser (CJS + ESM)
└── packages/node-cli-utilities      ← Shared CLI utilities and dev environment config
```

### Sub-package Details

| Package | Role | Key Tech | Entry |
|---|---|---|---|
| `external-idp-user-api` | Verify external ID tokens; let internal APIs authenticate without knowing the IdP | NestJS, Prisma, Redis (Keyv), ethers.js, jose, Zod | `nest start --watch` |
| `road-wave-fm-rpc` | TRPC-based RPC service delivering radio station data | TRPC, Mongoose, Redis, ws (WebSocket), Zod | `tsx watch src/server` |
| `road-wave-fm-web` | Web app frontend communicating with the Road Wave FM data source | React 19, MUI, Webpack, react-hook-form, ethers.js | `webpack serve` |
| `eip-4361-parser` | Parse EIP-4361 Sign-in with Ethereum messages; optional Zod schema validation | apg-lite (ABNF grammar), dual CJS/ESM build | — |
| `node-cli-utilities` | Shared CLI utilities, logger preload, and dev environment setup helpers | Winston, chalk, EJS | — |

### Docker Services

The root `compose.yml` includes sub-compose files from each package. Core infrastructure services:
- **postgres** — relational database
- **valkey** — Redis-compatible cache/session store (two instances)
- **mongodb** — document store (used by road-wave-fm-rpc via Mongoose)

Application containers per package: `eiu-api` / `rwf-api` / `web` (dev and prod variants).

## Building and Running

### Prerequisites
- Node.js 24+ (all packages target `@tsconfig/node24`)
- Docker / Docker Compose
- Git (for submodule management)

### Initial Setup
```sh
# Clone with submodules
git clone --recurse-submodules git@github.com:LinkedMink/road-wave-fm.git
cd road-wave-fm

# Install all packages and their deps (runs postinstall → installs each submodule)
npm install

# Start infrastructure services
npm run start:docker:services

# Per-package setup (interactive CLI prompts)
npm run setup:external-idp-user-api
npm run setup:road-wave-fm-rpc
```

### Full Stack (Development)
```sh
# Starts Docker infra + all app dev servers concurrently
npm start
```

Individual app dev servers:
```sh
npm run start:app:external-idp-user-api   # NestJS watch mode
npm run start:app:road-wave-fm-rpc        # tsx watch mode
npm run start:app:road-wave-fm-web        # webpack-dev-server
```

### Docker Builds
```sh
# Build all dev images
npm run build:docker

# Build production images
npm run build:docker:prod

# Run deployed containers
npm run start:docker:deployed
```

### Per-Package Commands
Each submodule package follows its own conventions. Key patterns:
- **Build**: `npm run build` (varies — NestJS uses `nest build`, web uses `webpack`, etc.)
- **Lint**: `npm run lint`
- **Test**: `npm run test` (interactive watch) or `npm run test:ci` (headless)
- **Format**: `npm run format` (Prettier)

## Development Conventions

### Branching
- `fix/*` — bug fixes
- `feature/*` — new or altered functionality
- `main` — release-ready code

### Code Quality
- **TypeScript** across all packages (targets Node 24)
- **ESLint** for linting (shared `@linkedmink/eslint-config`)
- **Prettier** for formatting
- **Husky + lint-staged** for pre-commit hooks in each package

### Module System
All packages use `"type": "module"` (ESM). The `eip-4361-parser` and `node-cli-utilities` packages produce both CJS and ESM outputs.

### Testing
Jest is the test runner across all packages. CI mode (`test:ci`) runs headless with coverage. Watch mode (`test`) is for interactive development.

### Versioning & Publishing
- Pre-release: `npm version prerelease` → publishes to `beta`/`dev` tag
- Production: `npm version [major|minor|patch]` → pushes git tags, publishes to `latest`
- Post-version Docker images are auto-built for non-prerelease versions

### Environment
- `.env.ejs` — template file for Docker environment variables (processed via EJS)
- Each package uses `@dotenvx/dotenvx` for `.env` loading at runtime

## Key Files to Know

| File | Purpose |
|---|---|
| `package.json` | Root orchestrator scripts (concurrent dev start, Docker builds, installs) |
| `compose.yml` | Docker Compose root — includes sub-compose files from each package |
| `.gitmodules` | Defines the 5 git submodule mappings |
| `.env.ejs` | Environment variable template for Docker containers |
| `.github/CONTRIBUTING.md` | Contribution guidelines and branching strategy |
| `.github/developing.md` | NPM publish/versioning instructions |

## Working with Submodules

Submodules live under `packages/`. Since they are independent git repos:
```sh
# Update all submodules to latest on their tracked branches
git submodule update --remote

# Commit changes across the meta-repo (records new submodule commits)
git add packages/<package-name>
git commit -m "chore: bump <package>"
```

Changes to individual packages should be made in their own repos and pulled via `git submodule update --remote`.
