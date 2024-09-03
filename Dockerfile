# Stage 1: Configure pnpm, install dependencies and build project
FROM node:current-slim AS builder

## Configure environment to use pnpm for package management
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

## Copy source code into /app inside the container
WORKDIR /app
COPY packages ./packages
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

## Install & build all packages
RUN pnpm install --frozen-lockfile
RUN pnpm build:frontend

# Stage 2: Start the web server
FROM nginx:stable-alpine AS runner

## Copy each frontend to the nginx html folder
COPY --from=builder /app/dist /usr/share/nginx/html

## Copy the Nginx config file
COPY nginx/default.conf /etc/nginx/conf.d/

## Open the default Nginx port
EXPOSE 80

## Start the web server in the foreground
CMD ["nginx", "-g", "daemon off;"]
