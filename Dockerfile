# ====== BUILD IMAGE ======
FROM hexpm/elixir:1.16.2-erlang-26.2.5-debian-bookworm-20240513-slim AS build

# Paket untuk compile deps (NIF), assets, SSL, dll.
RUN apt-get update && apt-get install -y \
    build-essential git curl ca-certificates \
    nodejs npm \
    pkg-config libssl-dev libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Elixir toolchain
RUN mix local.hex --force && mix local.rebar --force

# (Opsional cache awal) ambil deps berdasarkan mix.exs & mix.lock
COPY mix.exs mix.lock ./
ENV MIX_ENV=prod
RUN mix deps.get --only prod

# Salin seluruh source, lalu **sync ulang deps** supaya lock selalu cocok
COPY . .
RUN mix deps.get --only prod --force

# (Jika ada assets, aktifkan baris berikut)
# RUN npm --prefix ./assets ci \
#  && npm --prefix ./assets run build \
#  && mix phx.digest

# Compile deps & project (pisah layer agar error jelas)
RUN mix deps.compile --all --verbose
RUN mix compile --verbose


# ====== RUNTIME IMAGE ======
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /app /app

ENV MIX_ENV=prod PHX_SERVER=true PORT=4000
EXPOSE 4000

# Jalankan migrasi (jika ada DB) lalu start server
CMD ["bash","-lc","mix ecto.migrate || true; mix phx.server"]
