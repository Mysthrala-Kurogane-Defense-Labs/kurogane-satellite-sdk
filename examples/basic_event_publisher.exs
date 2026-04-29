attrs = %{
  event_id: "evt-synthetic-telemetry-001",
  occurred_at: "2026-01-01T00:00:00Z",
  site_id: "site-synthetic-alpha",
  asset_id: "compressor-1",
  metric: "pressure_bar",
  value: 6.4
}

{:ok, event} = KuroganeSatelliteSdk.build_event(:telemetry, attrs)

IO.inspect(
  KuroganeSatelliteSdk.Client.publish(event,
    endpoint: "http://localhost:4000/synthetic-ingest",
    dry_run: true
  )
)
