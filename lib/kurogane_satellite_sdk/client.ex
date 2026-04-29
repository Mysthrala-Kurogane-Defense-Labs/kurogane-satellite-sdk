defmodule KuroganeSatelliteSdk.Client do
  @moduledoc """
  Minimal dry-run client abstraction for caller-provided lab endpoints.

  The client intentionally has no baked-in production endpoint.
  """

  alias KuroganeSatelliteSdk.Event

  def publish(event, opts \\ []) when is_map(event) do
    with :ok <- Event.validate(event),
         {:ok, endpoint} <- endpoint(opts) do
      if Keyword.get(opts, :dry_run, true) do
        {:ok, %{dry_run: true, endpoint: endpoint, event: event}}
      else
        {:error, :transport_not_implemented}
      end
    end
  end

  defp endpoint(opts) do
    case Keyword.get(opts, :endpoint) do
      value when is_binary(value) and value != "" -> {:ok, value}
      _ -> {:error, :missing_endpoint}
    end
  end
end
