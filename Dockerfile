# Build
FROM hexpm/elixir:1.16.2-erlang-26.2.5-debian-bookworm AS build
RUN apt-get update && apt-get install -y build-essential git curl nodejs npm
WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force && mix deps.get
COPY . .
ENV MIX_ENV=prod
RUN mix deps.compile && mix compile

# Runtime
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y openssl ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app /app
ENV MIX_ENV=prod PHX_SERVER=true PORT=4000
EXPOSE 4000
CMD ["bash","-lc","mix ecto.migrate || true; mix phx.server"]
