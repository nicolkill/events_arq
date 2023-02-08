defmodule EventsArqBackend.AWS.SqsClient do
  defp base_queue_url, do: Application.get_env(:ex_aws, :sqs)[:base_queue_url]

  def add_message_to_queue(queue, data) do
    url = "#{base_queue_url()}#{queue}"
    encoded_data = Jason.encode!(data)

    {:ok, %{status_code: code}} =
      url
      |> ExAws.SQS.send_message(encoded_data)
      |> ExAws.request()

    if code >= 200 and code < 300, do: :ok, else: :error
  end
end
