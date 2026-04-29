defmodule KuroganeSatelliteSdkTest do
  use ExUnit.Case, async: true

  test "builds a public telemetry event" do
    attrs = %{
      event_id: "evt-synthetic-001",
      occurred_at: "2026-01-01T00:00:00Z",
      site_id: "site-synthetic",
      asset_id: "pump-1",
      metric: "temperature_c",
      value: 42.1
    }

    assert {:ok, event} = KuroganeSatelliteSdk.build_event(:telemetry, attrs)
    assert event.type == :telemetry
  end

  test "rejects missing required fields" do
    assert {:error, {:missing_fields, [:occurred_at, :site_id, :asset_id]}} =
             KuroganeSatelliteSdk.build_event(:asset, %{event_id: "evt"})
  end

  test "dry-run publish requires caller-provided endpoint" do
    event = %{
      type: :alarm,
      event_id: "evt-synthetic-002",
      occurred_at: "2026-01-01T00:00:00Z",
      site_id: "site-synthetic",
      asset_id: "line-1"
    }

    assert {:ok, %{dry_run: true}} =
             KuroganeSatelliteSdk.Client.publish(event, endpoint: "http://localhost:4000/lab")
  end
end
