defmodule Anonimyzer.Map do
  @moduledoc false

  alias Anonimyzer.Utils

  @behaviour Anonimyzer.DataKind

  @impl true
  def anonymize_data(payload, selectors) do
    Enum.reduce(selectors, payload, &Map.merge(&2, anonymize(&2, &1)))
  end

  defp anonymize(payload, {path, :mask = method}) do
    case get_in(payload.data, determine_path(path)) do
      nil ->
        Utils.put_error(payload, path, method)

      _ ->
        payload.data
        |> update_in(determine_path(path), &Utils.mask_data/1)
        |> Utils.put_data(payload)
    end
  end

  defp anonymize(payload, {path, :drop = method}) do
    case pop_in(payload.data, determine_path(path)) do
      {nil, _data} -> Utils.put_error(payload, path, method)
      {_drop, data} -> Utils.put_data(data, payload)
    end
  end

  defp determine_path(path) do
    path
    |> String.split("/")
    |> Enum.map(&Utils.safe_string_to_atom/1)
  end
end
