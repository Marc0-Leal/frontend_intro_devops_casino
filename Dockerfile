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
FROM nginx:alpine AS runtime

LABEL maintainer="casino-devops"

RUN rm -rf /usr/share/nginx/html/* \
 && rm -f /etc/nginx/conf.d/default.conf

COPY default.conf.template /etc/nginx/templates/default.conf.template

COPY --from=builder /app/dist/casino-frontend/browser/. /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:80/ > /dev/null || exit 1
