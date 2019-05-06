#!/usr/bin/env bash

cd /app

# Wait until Postgres is ready
while ! pg_isready -q -h $PG_HOST -p $PG_PORT -U $PG_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

# Create, migrate, and seed database if it doesn't exist.
if [[ -z `psql -Atqc "\\list $PG_DATABASE"` ]]; then
  echo "Database $PG_DATABASE does not exist. Creating..."
  mix ecto.create
  mix ecto.migrate
  mix run priv/repo/seeds.exs
  echo "Database $PG_DATABASE created."
fi

exec mix phx.server