# ===== BUILD STAGE =====
FROM hexpm/elixir:1.16.2-erlang-26.2.5-debian-bookworm-20240513-slim AS build

RUN apt-get update && apt-get install -y \
    build-essential git curl ca-certificates \
    nodejs npm \
    pkg-config libssl-dev libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Elixir tools
RUN mix local.hex --force && mix local.rebar --force

# Ambil deps awal (cache)
COPY mix.exs mix.lock ./
ENV MIX_ENV=prod
RUN mix deps.get --only prod

# Copy source lalu sync ulang deps
COPY . .
RUN mix deps.get --only prod --force

# Assets (opsional; kalau proyekmu pakai)
RUN mix assets.deploy || true

# Compile & release
RUN mix deps.compile --all --verbose
RUN mix compile --verbose
RUN mix release

# ===== RUNTIME STAGE =====
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl ca-certificates bash \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# GANTI jika nama OTP app kamu bukan "hello_phoenix"
ARG APP_NAME=hello_phoenix
COPY --from=build /app/_build/prod/rel/${APP_NAME} /app

ENV PHX_SERVER=true MIX_ENV=prod PORT=4000
EXPOSE 4000

CMD ["/app/bin/hello_phoenix", "start"]
