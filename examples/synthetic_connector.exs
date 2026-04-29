defmodule SyntheticConnector do
  @behaviour KuroganeSatelliteSdk.Connector

  def source_name, do: "synthetic-plant-demo"

  def poll do
    KuroganeSatelliteSdk.build_event(:asset, %{
      event_id: "evt-synthetic-asset-001",
      occurred_at: "2026-01-01T00:00:00Z",
      site_id: "site-synthetic-alpha",
      asset_id: "pump-1",
      name: "Synthetic Pump 1"
    })
    |> case do
      {:ok, event} -> {:ok, [event]}
      error -> error
    end
  end
end

IO.inspect(SyntheticConnector.poll())
