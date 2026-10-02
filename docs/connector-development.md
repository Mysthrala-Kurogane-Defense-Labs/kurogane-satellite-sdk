# Developing a connector

## Inputs and boundary

Use an approved synthetic source first. Write down the source format, asset mapping, units, timestamp origin and expected volume. This SDK provides event construction and validation, not a protocol driver or production delivery service.

## Implementation steps

1. Map one synthetic source record to one public event. Give each logical occurrence a stable ID; retries should preserve that ID.
2. Preserve the original occurrence time and explicit offset. Distinguish a device clock from collection time in an extension field when needed.
3. Validate the result with `Event.normalize/1`, then inspect `Event.to_wire/1`.
4. Exercise missing fields, incorrect types, unknown assets, clock skew and duplicates using synthetic records.
5. Define transport, authentication, retry bounds, backpressure, storage limits and idempotency separately before connecting any receiver.

## Review output

Deliver a mapping table, sample events, rejected-input tests, a statement of read-only behavior and the failure policy. A passing SDK test is evidence of the public contract only. Credentials, private endpoints and real plant data must stay outside this repository.

For real equipment, agree scope with the owner and vendor, and test in a separate environment. This repository supplies no authorization to connect to a customer network.
