# Kurogane Satellite SDK

Build and validate synthetic asset, alarm and telemetry events in Elixir. This repository implements a **local event contract and a dry-run preview**. It does not contain an HTTP publisher, authentication, buffering or a connection to the private Kurogane Hub.

## For businesses

Use the examples to discuss what an integration would need: asset identifiers, timestamps, measurements and alarm descriptions. A valid event demonstrates its shape; it does not establish that a measurement is trustworthy or that an installation is secure. Start with the [company preparation guide](https://github.com/Mysthrala-Kurogane-Defense-Labs/kurogane-docs/blob/main/docs/sme-onboarding.md).

## Run locally

Requires Elixir >= 1.14 with a compatible Erlang/OTP installation. The Elixir library has no external dependencies. Python >= 3.11 is only needed for independent schema validation.

```sh
mix format --check-formatted
mix compile --warnings-as-errors
mix test
mix run examples/basic_event_publisher.exs
mix run examples/synthetic_connector.exs
```

The publisher example prints a preview. It does not send a request. `Client.publish(event, endpoint: "http://localhost:4000/lab", dry_run: false)` returns `{:error, :transport_not_implemented}`.

```elixir
attrs = %{
  event_id: "demo-001", occurred_at: "2026-01-01T00:00:00Z",
  site_id: "synthetic", asset_id: "pump-1",
  metric: "pressure_bar", value: 2.5, unit: "bar"
}
{:ok, event} = KuroganeSatelliteSdk.build_event(:telemetry, attrs)
{:ok, wire} = KuroganeSatelliteSdk.Event.to_wire(event)
# wire contains JSON-compatible values and string keys, not encoded JSON.
```

Validate JSON Schema independently:

```sh
python -m venv .venv
# Activate .venv: source .venv/bin/activate (Unix), .venv\Scripts\Activate.ps1 (PowerShell)
python -m pip install -r requirements-dev.txt
python tools/validate_contracts.py
python tools/event_contract.py fixtures/sample_asset_event.json fixtures/sample_alarm_event.json fixtures/sample_telemetry_event.json
```

## Contract and contribution

- [Required fields, accepted values and errors](docs/event-contracts.md)
- [Connector responsibilities](docs/connector-development.md)
- [Integration boundary](docs/satellite-integration.md)
- [0.2 migration and version policy](docs/versioning-policy.md)
- [Executable synthetic scenarios](https://github.com/Mysthrala-Kurogane-Defense-Labs/kurogane-labs)

CI checks the same positive and negative vectors in Elixir and JSON Schema, and regenerates the Elixir vectors to detect drift. For a contract change, update schemas, fixtures, documentation and both validators together. Use synthetic data in issues and examples.

## License

Code is Apache-2.0; see [license](LICENSE.md). Public contracts do not promise compatibility with the private core.
