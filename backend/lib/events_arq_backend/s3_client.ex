defmodule EventsArqBackend.S3Client do
  @moduledoc false

  defmacrop is_prod, do: Mix.env() == :prod
  defp s3_bucket, do: Application.get_env(:ex_aws, :s3)[:bucket]
  defp config, do: ExAws.Config.new(:s3, [])

  def presigned_url_upload(object_key, opts \\ []) do
    get_presigned_url(:put, object_key, opts)
  end

  defp get_presigned_url(http_method, object_key, opts) do
    # this its for a configuration issue with localhost
    opts =
      if is_prod() do
        opts
      else
        opts
        |> Keyword.put(:virtual_host, is_prod())
        |> Keyword.put(:bucket_as_host, true)
      end

    ExAws.S3.presigned_url(
      config(),
      http_method,
      s3_bucket(),
      object_key,
      opts
    )
  end
end