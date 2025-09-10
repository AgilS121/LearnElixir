# ===== BUILD STAGE =====
FROM hexpm/elixir:1.16.2-erlang-26.2.5-debian-bookworm-20240904-slim AS build

# Install build dependencies
RUN apt-get update -y && apt-get install -y \
  build-essential \
  git \
  curl \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Prepare build dir
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only=prod
RUN mkdir config

# Copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Copy priv and lib (compiling assets if needed)
COPY priv priv
COPY lib lib

# NOTE: Jika menggunakan assets, uncomment baris ini:
# COPY assets assets
# RUN mix assets.deploy

# Compile the release
RUN mix compile

# Copy runtime config (if exists)
COPY config/runtime.exs config/ || true

# Assemble the release
RUN mix release

# ===== RUNTIME STAGE =====
FROM debian:bookworm-slim AS app

# Install runtime dependencies
RUN apt-get update -y && apt-get install -y \
  libstdc++6 \
  openssl \
  libncurses5 \
  locales \
  curl \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app
RUN chown nobody /app

# Set runner ENV
ENV MIX_ENV=prod

# Only copy the final release from the build stage
COPY --from=build --chown=nobody:root /app/_build/${MIX_ENV}/rel/hello_phoenix ./

USER nobody

# Expose port 4000
EXPOSE 4000

# Start the Phoenix server
CMD ["/app/bin/hello_phoenix", "start"]