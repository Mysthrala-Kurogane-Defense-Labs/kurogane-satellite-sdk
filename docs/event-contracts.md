# Public event contract 0.2

## Fields

| Event | Common required fields | Additional required fields |
| --- | --- | --- |
| asset | type, event_id, occurred_at, site_id, asset_id | name |
| alarm | type, event_id, occurred_at, site_id, asset_id | severity, message |
| telemetry | type, event_id, occurred_at, site_id, asset_id | metric, value |

Identifiers, names, metrics, messages and optional `unit` / `asset_type` are nonblank UTF-8 strings. `value` is a finite JSON number, including zero; a boolean or numeric string is invalid. Severity is `info`, `warning` or `critical`. The helper validates known optional fields even when supplied on another event type.

`occurred_at` uses a real calendar date in years 0001–9999 with uppercase `T`, seconds 00–59, optional 1–6 fractional digits, and explicit `Z` or `±HH:MM` offset. Naive timestamps and leap seconds are outside this public contract. Examples: `2026-01-01T00:00:00Z`, `2026-01-01T01:00:00+01:00`.

The RFC 3339 `-00:00` convention is accepted and preserved: the UTC instant is known while the local offset is unknown. It is normalized only internally for calendar validation, never rewritten in the event or wire output. See [RFC 3339 section 4.3](https://www.rfc-editor.org/rfc/rfc3339#section-4.3).

Additional fields are allowed only as JSON-compatible data. Elixir known atom keys or string keys are accepted; normalization returns known atom keys. `Event.to_wire/1` converts all keys to strings and the event type to a string. It does not encode JSON. Conflicting dual keys, invalid UTF-8, structs, arbitrary atom values, tuples and ambiguous nested keys are rejected. No atoms are created from incoming keys.

## Validation is not authenticity

The schemas do not authenticate the source, deduplicate IDs, order events, check metric units against plant specifications or prove data freshness. A receiver must define these policies separately. The lab analyzer demonstrates duplicate detection and gaps without diagnosing a physical fault.

## Errors and independent checks

`Event.validate/1` returns `:ok` or an error tuple. `Event.normalize/1` and `build_event/2` return `{:ok, event}` or errors such as `:unsupported_event_type`, `{:missing_fields, fields}`, `{:invalid_fields, fields}`, `{:conflicting_field, field}` and `:non_json_value`.

The [local schemas](../schemas/) use [JSON Schema 2020-12](https://json-schema.org/draft/2020-12/json-schema-validation). Enable format assertions in your validator; `format` alone may be an annotation. `tools/event_contract.py` enables date validation and rejects non-finite numbers. The [74 shared vectors](../fixtures/contract_cases.json) are regression cases, not exhaustive compatibility proof.
