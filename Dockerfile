# ===== RUNTIME STAGE =====
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl ca-certificates bash curl \
  && rm -rf /var/lib/apt/lists/*

# user non-root (opsional)
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
# ===== RUNTIME STAGE =====
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl ca-certificates bash curl \
  && rm -rf /var/lib/apt/lists/*

# user non-root (opsional)
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
