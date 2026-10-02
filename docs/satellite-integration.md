# Integration boundary

The public path is: synthetic source → connector mapping → local validation → dry-run preview or local file. No hub endpoint, ingestion API, identity protocol or production topology is specified here.

`Client.publish/2` requires a caller-provided HTTP(S) URL with a host and valid port. Credentials in the URL and fragments are rejected. The URL is only displayed in the preview; the client performs no I/O. Never put a secret in an endpoint query, event or log.

Before implementing transport, request a versioned receiver contract: authentication, endpoint, accepted schema version, duplicate policy, timeout/retry behavior, payload bounds and acknowledgment semantics. Record these as unanswered integration decisions until evidence is supplied.

For a local exercise, generate events in [Labs](https://github.com/Mysthrala-Kurogane-Defense-Labs/kurogane-labs), validate their JSON against these schemas, and compare the resulting field mapping. This verifies public examples, not private-core interoperability.
