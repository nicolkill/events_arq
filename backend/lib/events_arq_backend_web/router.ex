defmodule EventsArqBackendWeb.Router do
  use EventsArqBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EventsArqBackendWeb do
    pipe_through :api
  end
end
