defmodule Anonimyzer.Utils do
  @moduledoc false

  @letter_replacements ~w(* @ # $ % ^ & ! ?)

  def put_data(data, payload) do
    Map.put(payload, :data, data)
  end

  def put_error(payload, path, method) do
    error_name = "Selector with anonymization method: :#{method} didn't match the data"
    error = %{path: path, error: error_name}

    payload
    |> Map.update!(:errors, fn errors -> [error | errors] end)
    |> Map.put(:valid?, false)
  end

  def safe_string_to_atom(string) do
    String.to_existing_atom(string)
  rescue
    ArgumentError -> String.to_atom(string)
  end

  def mask_data(data) do
    case String.next_grapheme(data) do
      {_letter, ""} -> List.first(@letter_replacements)
      {letter, rest} -> mask_data(letter, rest)
      nil -> data
    end
  end

  defp mask_data(first_letter, rest) when byte_size(rest) == 1 do
    first_letter <> List.first(@letter_replacements) <> rest
  end

  defp mask_data(first_letter, rest) do
    String.pad_trailing(first_letter, byte_size(rest), @letter_replacements) <> String.last(rest)
  end
end
