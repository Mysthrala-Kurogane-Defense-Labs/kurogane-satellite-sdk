defmodule KuroganeSatelliteSdk.Client do
  @moduledoc """
  Validated dry-run preview for caller-provided lab URLs. No HTTP transport exists.
  """
  alias KuroganeSatelliteSdk.Event

  def publish(event, opts \\ []) do
    if is_list(opts) and Keyword.keyword?(opts) do
      with {:ok, event} <- Event.normalize(event),
           {:ok, endpoint} <- endpoint(opts) do
        case Keyword.get(opts, :dry_run, true) do
          true -> {:ok, %{dry_run: true, endpoint: endpoint, event: event}}
          false -> {:error, :transport_not_implemented}
          _ -> {:error, :invalid_dry_run}
        end
      end
    else
      {:error, :invalid_options}
    end
  end

  defp endpoint(opts) do
    case Keyword.get(opts, :endpoint) do
      value when is_binary(value) and value != "" ->
        case URI.new(value) do
          {:ok, %URI{scheme: scheme, host: host, port: port, userinfo: nil, fragment: nil}}
          when scheme in ["http", "https"] and is_binary(host) and host != "" and
                 is_integer(port) and port > 0 and port <= 65_535 ->
            {:ok, value}

          _ ->
            {:error, :invalid_endpoint}
        end

      _ ->
        {:error, :missing_endpoint}
    end
  end
end
