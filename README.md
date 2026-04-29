# Kurogane Satellite SDK

Kurogane Satellite SDK is a public Elixir SDK for preliminary satellite and connector integration patterns in the public technical ecosystem around Kurogane Hub.

It is intended for connector authors, OT cybersecurity reviewers, Elixir developers, and partners who need to understand public event contracts and synthetic integration examples. It does not provide access to the private Kurogane Hub production core.

## Scope

- Event structs and validation helpers for synthetic asset, alarm, and telemetry events.
- A minimal client abstraction that targets caller-provided URLs only.
- Connector behaviour examples for synthetic satellite architecture experiments.
- JSON schemas and fixtures for public integration discussion.

## Non-Scope

- Production Kurogane Hub source code.
- Sensitive detection logic.
- Customer deployment logic.
- Real endpoints, credentials, tokens, IP addresses, or plant data.

## Keywords

Elixir, SDK, industrial monitoring, OT cybersecurity, telemetry, event contracts, satellite architecture, PLC, SCADA, data sovereignty, cyber-physical systems.

## Quick Start

```bash
mix test
mix run examples/basic_event_publisher.exs
```

The example uses a dry-run client by default. Any endpoint must be supplied by the caller and should be a test or lab endpoint.

## Event Contracts

The event contracts are preliminary and oriented to integration, labs, and public feedback. They are not a compatibility guarantee for private Kurogane Hub internals.

See [docs/event-contracts.md](docs/event-contracts.md).

## License

SDK code, examples, schemas, fixtures, and technical snippets are licensed under Apache-2.0.
