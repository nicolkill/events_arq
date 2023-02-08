defmodule EventsArqBackendWeb.UserSocket do
  use Phoenix.Socket

  alias EventsArqBackend.Generator

  channel "room:*", EventsArqBackendWeb.Channels.UserRoom

  def connect(_params, socket, _connect_info) do
    # add the token to assigns to identify the connection session
    #    socket = assign(socket, :user_id, Map.get(params, "someToken"))
    {:ok, socket}
  end

  # identify the connection by unique id
  #  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  def id(_socket), do: "users_socket:#{Generator.generate_unique_ref()}"
end
