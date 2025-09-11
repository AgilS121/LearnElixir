# ===== BUILD STAGE =====
FROM hexpm/elixir:1.16.2-erlang-26.2.5-debian-bookworm-20240513-slim AS build

RUN apt-get update && apt-get install -y \
    build-essential git curl ca-certificates \
    nodejs npm \
    pkg-config libssl-dev libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Elixir tooling
RUN mix local.hex --force && mix local.rebar --force

# Cache deps
COPY mix.exs mix.lock ./
ENV MIX_ENV=prod
RUN mix deps.get --only prod

# Copy source & deps again (ensure lock synced)
COPY . .
RUN mix deps.get --only prod --force

# Assets (jika ada)
RUN mix assets.deploy || true

# Compile & release
RUN mix deps.compile --all --verbose
RUN mix compile --verbose
RUN mix release

# ===== RUNTIME STAGE =====
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl ca-certificates bash curl \
  && rm -rf /var/lib/apt/lists/*

# user non-root (opsional, bagus untuk security)
RUN useradd -m -u 10001 app

WORKDIR /app

ARG APP_NAME=hello_phoenix
COPY --from=build /app/_build/prod/rel/${APP_NAME} /app
COPY entrypoint.sh /app/entrypoint.sh

RUN chmod +x /app/entrypoint.sh && chown -R app:app /app

ENV PHX_SERVER=true MIX_ENV=prod PORT=4000
EXPOSE 4000

USER app

ENTRYPOINT ["/app/entrypoint.sh"]
