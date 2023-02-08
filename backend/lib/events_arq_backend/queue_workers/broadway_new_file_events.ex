defmodule EventsArqBackend.QueueWorkers.BroadwayNewFileEvents do
  @moduledoc false
  use Broadway

  alias Broadway.Message
  alias EventsArqBackend.QueueWorkers.BroadwayGeneralEvents

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

    %{"Records" => records} = decoded_data

    Enum.each(records, fn
      %{
        "eventName" => event_name,
        "eventSource" => "aws:s3",
        "eventTime" => event_time,
        "s3" => %{
          "bucket" => %{
            "name" => bucket_name
          },
          "object" => %{
            "eTag" => entity_id,
            "key" => object_key,
            "size" => object_size
          }
        }
      }
      when event_name in ["ObjectCreated:Put", "ObjectCreated:Post"] ->
        data = %{
          event: "new_file",
          timestamp: DateTime.utc_now(),
          metadata: %{
            bucket_name: bucket_name,
            entity_id: entity_id,
            object_key: object_key,
            object_size: object_size,
            inserted_at: event_time
          }
        }

        BroadwayGeneralEvents.insert_message(data)

      _ ->
        :ok
    end)

    Message.update_data(message, fn _data -> decoded_data end)
  end

  defp queue_url,
    do:
      "#{Application.get_env(:ex_aws, :sqs)[:base_queue_url]}#{Application.get_env(:ex_aws, :sqs)[:new_files_queue]}"

  defp producer_module, do: Application.get_env(:events_arq_backend, :broadway)[:producer_module]
end
