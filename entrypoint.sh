#!/usr/bin/env bash

# Wait until Postgres is ready
while ! pg_isready -q -h $PG_HOST -p $PG_PORT -U $PG_USER
do
  echo "$(date) - waiting for database to start"
  sleep 4
done

# Create, migrate, and seed database if it doesn't exist.
if [[ -z `psql -Atqc "\\list $PG_DATABASE"` ]]; then
  echo "Database $PG_DATABASE does not exist. Creating..."
  cd /rumbl_umbrella/apps/rumbl && mix ecto.reset
  echo "Database $PG_DATABASE created."
fi

cd /rumbl_umbrella/apps/rumbl_web && mix phx.server