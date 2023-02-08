defmodule EventsArqBackend.QueueWorkers.BroadwayGeneralEvents do
  @moduledoc false
  use Broadway

  alias Broadway.Message
  alias EventsArqBackend.Generator
  alias EventsArqBackend.AWS.SqsClient

  def start_link(_opts) do
    {module, opts} = producer_module()
    options = opts ++ [queue_url: queue_url()]

    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {module, options}
      ],
      processors: [
        default: []
      ]
    )
  end

  @impl true
  def handle_message(_processor, %Message{data: data} = message, _context) do
    decoded_data =
      case Jason.decode!(data) do
        %{"Message" => message} -> Jason.decode!(message)
        message -> message
      end
      |> Map.put("id", Generator.generate_unique_ref())

    EventsArqBackendWeb.Endpoint.broadcast!("room:lobby", "new_message", decoded_data)

    Message.update_data(message, fn _data -> decoded_data end)
  end

  def insert_message(data), do: SqsClient.add_message_to_queue(queue_name(), data)

  defp queue_name, do: Application.get_env(:ex_aws, :sqs)[:general_events_queue]
  defp queue_url, do: "#{Application.get_env(:ex_aws, :sqs)[:base_queue_url]}#{queue_name()}"
  defp producer_module, do: Application.get_env(:events_arq_backend, :broadway)[:producer_module]
end
