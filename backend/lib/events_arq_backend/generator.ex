defmodule EventsArqBackend.Generator do
  def generate_unique_ref,
    do:
      make_ref()
      |> :erlang.ref_to_list()
      |> List.to_string()
      |> String.replace("#Ref<", "")
      |> String.replace(">", "")
      |> String.replace(".", "")
      |> String.codepoints()
      |> Enum.chunk_every(8)
      |> Enum.join("-")
end
