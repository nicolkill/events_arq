defmodule EventsArqBackendWeb.FileView do
  use EventsArqBackendWeb, :view

  alias EventsArqBackendWeb.FileView

  def render("upload_url.json", %{url: url}) do
    %{
      url: url
    }
  end
end
