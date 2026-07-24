FROM elixir:1.17-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app

COPY mix.exs mix.lock ./
RUN MIX_ENV=dev mix deps.get

COPY . .

EXPOSE 9000

CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && mix run priv/repo/seeds.exs; mix phx.server"]
