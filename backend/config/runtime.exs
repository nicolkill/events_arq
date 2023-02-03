import Config

defmodule RuntimeUtil do
  def get_env_or_raise_error(var_name),
    do:
      System.get_env(var_name) ||
        raise("""
        environment variable #{var_name} is missing.
        """)
end

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/events_arq_backend start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :events_arq_backend, EventsArqBackendWeb.Endpoint, server: true
end

if config_env() == :prod do
  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :events_arq_backend, EventsArqBackend.Repo,
    # ssl: true,
    username: RuntimeUtil.get_env_or_raise_error("POSTGRES_USERNAME"),
    password: RuntimeUtil.get_env_or_raise_error("POSTGRES_PASSWORD"),
    hostname: RuntimeUtil.get_env_or_raise_error("POSTGRES_HOSTNAME"),
    database: RuntimeUtil.get_env_or_raise_error("POSTGRES_DATABASE"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  config :ex_aws, :s3,
    region: RuntimeUtil.get_env_or_raise_error("AWS_REGION"),
    bucket: RuntimeUtil.get_env_or_raise_error("AWS_S3_BUCKET")

  config :ex_aws, :sqs,
    region: RuntimeUtil.get_env_or_raise_error("AWS_REGION"),
    base_queue_url: RuntimeUtil.get_env_or_raise_error("AWS_BASE_QUEUE_URL"),
    new_files_queue: RuntimeUtil.get_env_or_raise_error("AWS_SQS_NEW_FILES_QUEUE"),
    general_events_queue: RuntimeUtil.get_env_or_raise_error("AWS_SQS_GENERAL_EVENTS_QUEUE")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base = RuntimeUtil.get_env_or_raise_error("SECRET_KEY_BASE")

  port = String.to_integer(System.get_env("PORT") || "4000")

  config :events_arq_backend, EventsArqBackendWeb.Endpoint,
    http: [port: String.to_integer(System.get_env("PORT") || "4000")],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
