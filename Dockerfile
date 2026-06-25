# =============================================================
# ETAPA 1: builder
# =============================================================
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN if [ -f package-lock.json ]; then \
      npm ci; \
    else \
      npm install; \
    fi

COPY . .

RUN npm run build

# =============================================================
# ETAPA 2: runtime
# =============================================================
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime

LABEL maintainer="casino-devops"

COPY --from=builder --chown=nginx:nginx /app/dist/casino-frontend/browser/. /usr/share/nginx/html/
COPY --chown=nginx:nginx nginx.conf /etc/nginx/templates/default.conf.template

USER nginx

EXPOSE 8080
