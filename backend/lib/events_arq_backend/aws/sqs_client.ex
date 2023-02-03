defmodule EventsArqBackend.AWS.SqsClient do
  defp base_queue_url, do: Application.get_env(:ex_aws, :sqs)[:base_queue_url]

  def add_message_to_queue(queue, data) do
    query =
      %{}
      |> Map.put("Action", "SendMessage")
      |> Map.put("MessageBody", Jason.encode!(data))
      |> URI.encode_query()

    url = "#{base_queue_url()}#{queue}?#{query}"

    headers = [{"Accept", "application/json"}]

    {:ok, %HTTPoison.Response{status_code: code}} = HTTPoison.get(url, headers)

    if code >= 200 and code < 300, do: :ok, else: :error
  end
end
