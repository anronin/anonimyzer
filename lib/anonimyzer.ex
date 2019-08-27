defmodule Anonimyzer do
  @moduledoc """
  Documentation for Anonimyzer.
  """

  @type anonymization_method :: :mask | :drop
  @type selector :: {String.t(), anonymization_method()}
  @type profile :: %{kind: module(), selectors: [selector()]}

  @doc """
  Let's anonymize some data.

  ### Examples:

    iex> data = %{name: "Philip K. Dick", email: "philip.k.dick@dreamofelectricsheep.com"}
    iex> profile = %{kind: Anonimyzer.Map, selectors: [{"name", :mask}, {"email", :drop}]}
    iex> Anonimyzer.anonymize(data, profile)
    %{name: "P*@#$%^&!?*@#k"}

  """
  @spec anonymize(any(), profile()) :: any()
  def anonymize(data, %{kind: data_kind_module, selectors: selectors}) do
    payload = %{data: data, errors: [], valid?: true}

    case data_kind_module.anonymize_data(payload, selectors) do
      %{valid?: true, data: data} -> data
      %{valid?: false, errors: errors} -> {:error, errors}
    end
  end

  defmodule DataKind do
    @moduledoc false

    @type payload :: %{data: any(), errors: [], valid?: boolean}
    @type error :: %{error: String.t(), path: String.t()}

    @callback anonymize_data(payload(), [Anonimyzer.selector()]) :: any() | {:error, [error()]}
  end
end
