defmodule KuroganeSatelliteSdk.Event do
  @moduledoc "Preliminary public event contract helpers for synthetic OT labs."

  @types [:asset, :alarm, :telemetry]
  @required [:event_id, :occurred_at, :site_id, :asset_id]

  def new(type, attrs) when type in @types and is_map(attrs) do
    event =
      attrs
      |> Map.new()
      |> Map.put(:type, type)

    case validate(event) do
      :ok -> {:ok, event}
      {:error, _} = error -> error
    end
  end

  def new(_type, _attrs), do: {:error, :unsupported_event_type}

  def validate(event) when is_map(event) do
    missing = Enum.reject(@required, &present?(event, &1))

    cond do
      missing != [] -> {:error, {:missing_fields, missing}}
      event[:type] not in @types -> {:error, :unsupported_event_type}
      true -> :ok
    end
  end

  defp present?(event, key), do: Map.has_key?(event, key) and event[key] not in [nil, ""]
end
