use Mix.Config

# Configure your database
config :rumbl, Rumbl.Repo,
  username: System.get_env("PG_USER"),
  password: System.get_env("PG_PASSWORD"),
  database: System.get_env("PG_DATABASE") <> "_test",
  hostname: System.get_env("PG_HOST"),
  port: System.get_env("PG_PORT"),
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rumbl_web, RumblWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Password hashing
config :pbkdf2_elixir, :rounds, 1

import_config "../apps/info_sys/config/test.exs"