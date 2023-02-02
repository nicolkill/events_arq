defmodule EventsArqBackend.Repo do
  use Ecto.Repo,
    otp_app: :events_arq_backend,
    adapter: Ecto.Adapters.Postgres
end
