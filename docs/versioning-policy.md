# Versioning and migration

The package version is 0.2.0. No production support or private-core compatibility is implied. Until 1.0, minor versions may introduce contract changes; patch versions should preserve accepted public behavior unless rejecting an invalid input is necessary and documented.

## From 0.1 to 0.2

The previous helper mostly checked field presence. Inputs with invalid types could pass, while string-keyed JSON events failed. Version 0.2 accepts known string keys and validates values, timestamps, JSON extensions and type-specific content.

- Asset events now require `name`.
- Alarm events require `severity` and `message`.
- Telemetry events require `metric` and numeric `value`.
- All events require nonblank identifiers and an explicit timezone.
- Conflicting keys and non-JSON extension values fail validation.
- `dry_run: false` still returns `:transport_not_implemented`.

Update old fixtures before upgrading. Run schema validation and Elixir tests on your own synthetic examples. Coordinate changes to the copied schemas in Labs; identical public schema files are expected. Release notes must distinguish a library change from an implemented transport or deployed service.
