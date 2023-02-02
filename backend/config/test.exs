import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :events_arq_backend, EventsArqBackend.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "events_arq_backend_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :events_arq_backend, EventsArqBackendWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "L7P/7wPq4Z2CbBNn6Qmc9wVm9w3z6bbn2BXMpA6sPFg3WvRLjdU7lyed/HwWxrrP",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
