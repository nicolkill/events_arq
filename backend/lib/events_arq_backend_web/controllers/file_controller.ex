defmodule EventsArqBackendWeb.FileController do
  @moduledoc false
  use EventsArqBackendWeb, :controller

  alias EventsArqBackend.Generator
  alias EventsArqBackend.AWS.S3Client

  # 30 mins
  @presigned_upload_url_max_age 60 * 30
  # 10 MB
  @presigned_upload_url_max_file_size 10 * 1_000_000

  @presigned_url_opts [
    ["starts-with", "$Content-Type", ""],
    {:expires_in, @presigned_upload_url_max_age},
    {:content_length_range, [1, @presigned_upload_url_max_file_size]}
  ]

  def get_presigned_url(conn, _) do
    {:ok, url} =
      Generator.generate_unique_ref()
      |> S3Client.presigned_url_upload(@presigned_url_opts)

    conn
    |> put_status(200)
    |> render("upload_url.json", url: url)
  end
end
