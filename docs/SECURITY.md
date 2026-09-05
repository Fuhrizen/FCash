# FCash multiplayer/security model

## Authority

Clients never write authoritative wallet, personal-bank, shared-bank or storage balances. Client UI submits an operation request to `FCash_fnc_serverRequest`; the server resolves the sender from `remoteExecutedOwner`, validates the request, mutates server memory and pushes a sanitized snapshot to the affected clients.

## Validation performed by the server

Depending on operation, FCash validates:

- network owner -> actual player identity;
- numeric type, finiteness, positive integer normalization and maximum amount;
- sufficient authoritative source balance;
- physical player/object distance for cash/storage operations;
- terminal class/registration and terminal distance for banking operations;
- player state for dead/captive cash taking;
- online recipient identity and optional same-side transfer policy;
- shared-account membership, role permission and member limits;
- shared-account name length and safe character set;
- per-client request burst/window rate limit.

Server transactions contain no `sleep`/scheduled yield, preventing request interleaving inside one mutation path.

## Internal function protection

FCash generates a server-only internal capability token at startup to protect authoritative server operations. Internal functions that mutate/synchronize authoritative state require that token when they are reached from a remotely executed context. Server-only public APIs (`serverAdjust*`, persistence, registration) reject remote execution entirely.

The only intended client -> server network entry point is:

```text
FCash_fnc_serverRequest
```

## CfgRemoteExec recommendation

For hardened public servers, use a mission-level whitelist (`mode = 1`) and merge the FCash entries documented in `CONFIGURATION.md` with the requirements of your other mods. Mission config takes precedence over addon config.

## Persistence

FCash keeps server state for the current mission/server process. For restart persistence, export schema version `1` through `FCash_fnc_exportState`, store it in a trusted server-side persistence layer, and restore it with `FCash_fnc_importState` before gameplay transactions begin.

Never let clients submit imported ledger state.
