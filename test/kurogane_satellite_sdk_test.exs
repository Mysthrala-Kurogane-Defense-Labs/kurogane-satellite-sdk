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
    assert {:error, {:missing_fields, [:occurred_at, :site_id, :asset_id, :name]}} =
             KuroganeSatelliteSdk.build_event(:asset, %{event_id: "evt"})
  end

  test "dry-run publish requires caller-provided endpoint" do
    event = %{
      type: :alarm,
      event_id: "evt-synthetic-002",
      occurred_at: "2026-01-01T00:00:00Z",
      site_id: "site-synthetic",
      asset_id: "line-1",
      severity: "warning",
      message: "Synthetic alarm"
    }

    assert {:ok, %{dry_run: true}} =
             KuroganeSatelliteSdk.Client.publish(event, endpoint: "http://localhost:4000/lab")
  end

  defp telemetry do
    %{
      type: :telemetry,
      event_id: "evt",
      occurred_at: "2026-01-01T00:00:00Z",
      site_id: "synthetic",
      asset_id: "pump",
      metric: "pressure",
      value: 6.4
    }
  end

  test "rejects values previously accepted just because their fields existed" do
    invalid = %{
      telemetry()
      | event_id: 5,
        occurred_at: false,
        site_id: %{},
        asset_id: [],
        value: "bad"
    }

    assert {:error, {:invalid_fields, fields}} = KuroganeSatelliteSdk.Event.normalize(invalid)
    assert fields == [:event_id, :occurred_at, :site_id, :asset_id, :value]
  end

  test "accepts JSON-style string keys and returns the same public wire contract" do
    wire = %{
      "type" => "telemetry",
      "event_id" => "evt",
      "occurred_at" => "2026-01-01T00:00:00Z",
      "site_id" => "synthetic",
      "asset_id" => "pump",
      "metric" => "pressure",
      "value" => 6.4
    }

    assert :ok = KuroganeSatelliteSdk.Event.validate(wire)
    assert {:ok, event} = KuroganeSatelliteSdk.Event.normalize(wire)
    assert event == telemetry()
    assert {:ok, ^wire} = KuroganeSatelliteSdk.Event.to_wire(event)
  end

  test "requires usable type-specific content" do
    assert {:error, {:missing_fields, [:metric]}} =
             KuroganeSatelliteSdk.Event.normalize(Map.delete(telemetry(), :metric))

    assert {:error, {:missing_fields, [:severity, :message]}} =
             KuroganeSatelliteSdk.Event.normalize(
               telemetry()
               |> Map.drop([:metric, :value])
               |> Map.put(:type, :alarm)
             )
  end

  test "checks timestamps and numeric values rather than their presence" do
    for value <- [
          "2026-02-30T00:00:00Z",
          "2026-01-01",
          "2026-01-01T00:00:60Z",
          "2026-01-01T00:00:00"
        ] do
      assert {:error, {:invalid_fields, [:occurred_at]}} =
               KuroganeSatelliteSdk.Event.normalize(%{telemetry() | occurred_at: value})
    end

    for value <- [nil, true, "6.4", %{}] do
      assert {:error, {:invalid_fields, [:value]}} =
               KuroganeSatelliteSdk.Event.normalize(%{telemetry() | value: value})
    end

    assert :ok =
             KuroganeSatelliteSdk.Event.validate(%{
               telemetry()
               | occurred_at: "2026-01-01T01:00:00+01:00",
                 value: 0
             })
  end

  test "does not silently overwrite conflicting atom and string keys" do
    assert {:error, {:conflicting_field, :event_id}} =
             KuroganeSatelliteSdk.Event.normalize(Map.put(telemetry(), "event_id", "other"))

    assert {:error, {:conflicting_field, :type}} =
             KuroganeSatelliteSdk.build_event(:asset, telemetry())
  end

  test "retains JSON extensions and rejects ambiguous or non-JSON content" do
    event = Map.put(telemetry(), "metadata", %{"operator" => nil, "read_only" => true})
    assert {:ok, wire} = KuroganeSatelliteSdk.Event.to_wire(event)
    assert wire["metadata"]["read_only"]

    for extension <- [
          :secret_atom,
          {:tuple},
          %{1 => "value"},
          %{:a => 1, "a" => 2},
          %{<<255>> => 1},
          [1 | 2]
        ] do
      assert {:error, :non_json_value} =
               KuroganeSatelliteSdk.Event.normalize(Map.put(telemetry(), "extra", extension))
    end
  end

  test "invalid public inputs produce errors, not function clause exceptions" do
    assert {:error, :invalid_event} = KuroganeSatelliteSdk.build_event(:asset, nil)
    assert {:error, :invalid_event} = KuroganeSatelliteSdk.Event.validate([])

    assert {:error, :unsupported_event_type} =
             KuroganeSatelliteSdk.build_event("untrusted-type", %{})

    assert {:error, :invalid_options} = KuroganeSatelliteSdk.Client.publish(telemetry(), %{})
  end

  test "client only previews valid caller-provided URLs and never supplies transport" do
    for endpoint <- [
          "not-a-url",
          "file:///tmp/event",
          "https://example.test:99999/lab",
          "https://example.test:0/lab",
          "https://user:password@example.test/lab",
          "https://example.test/#fragment"
        ] do
      assert {:error, :invalid_endpoint} =
               KuroganeSatelliteSdk.Client.publish(telemetry(), endpoint: endpoint)
    end

    assert {:error, :missing_endpoint} = KuroganeSatelliteSdk.Client.publish(telemetry())

    assert {:error, :invalid_dry_run} =
             KuroganeSatelliteSdk.Client.publish(telemetry(),
               endpoint: "https://example.test",
               dry_run: "false"
             )

    assert {:error, :transport_not_implemented} =
             KuroganeSatelliteSdk.Client.publish(telemetry(),
               endpoint: "https://example.test",
               dry_run: false
             )
  end

  test "invalid UTF-8 timestamp returns a validation error" do
    assert {:error, {:invalid_fields, [:occurred_at]}} =
             KuroganeSatelliteSdk.Event.normalize(%{telemetry() | occurred_at: <<255>>})
  end
end
