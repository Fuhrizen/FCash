# Fuhrizen's Cash

Fuhrizen's Cash is a multiplayer cash and banking addon for Arma 3 authored by **Fuhrizen**. The public scripting namespace is `FCash`.

The addon provides server-authoritative wallets, personal bank accounts, shared accounts, cash stashes, bank terminals, 3DEN authoring tools, ACE interactions, and live Zeus administration.

## Features

- Server-authoritative wallet and personal-bank balances.
- Physical cash payments to living players and AI.
- Cash recovery from dead or captive units.
- Optional wallet loss and corpse cash on death.
- Cash stashes with ACE deposit and withdrawal interactions.
- Bank terminals and supported ATM objects with ACE banking access.
- Personal-bank deposits, withdrawals, and transfers.
- Searchable transfer recipients with personal/shared filters.
- Seven-digit account numbers for direct transfers.
- Shared bank accounts with public/private visibility.
- Shared account roles: Owner, Manager, Member, and Viewer.
- Shared account membership management and invitations.
- Per-account shared-bank transaction logs.
- Multiplayer, JIP, and respawn-safe player ledgers.
- Server audit logging and request validation.
- Mission event hooks through the `FCash_fnc_*` API.
- Persistence export/import API for external storage adapters.
- CBA Addon Options available in the 3DEN Editor.
- 3DEN object attributes for starting balances, stashes, and terminals.
- 3DEN shared-bank module with synchronized membership.
- Compact Zeus administration modules under **Fuhrizen's Cash**.
- Vanilla-friendly animated UI with ZEN curator integration when available.

## Requirements

- Arma 3 2.18+
- CBA_A3
- ACE3 (`ace_interact_menu`)

## Build

The Docker workflow has one service and produces the complete signed release. From the repository root:

```bash
docker compose run --rm --build build
```

The build container performs the release checks, runs the FCash static validator, executes `hemtt release`, verifies that signed PBO/BISIGN/BIKEY output exists, and copies the release tree to `dist/`. It also writes `dist/SHA256SUMS.txt` for the signed release files.

`--rm` removes the build container when the command exits. Docker may keep the built image in its local cache; remove that separately with `docker compose down --rmi local` if required.

Release signing uses a reusable HEMTT private key. Complete the one-time setup in [docs/SIGNING.md](docs/SIGNING.md) before the first signed build. The private key is mounted read-only and is never copied into the image.

The builder also mounts `.git` read-only and refuses to sign a release when the working tree contains uncommitted changes.

The included Dockerfile pins HEMTT `1.21.0`.

For direct local use without Docker, the equivalent HEMTT command is:

```bash
hemtt release
```

See [docs/SIGNING.md](docs/SIGNING.md) for signing-key setup and handling.

## Configuration

Open **Configure Addons > Fuhrizen's Cash** from the game options or 3DEN Editor. Mission-facing settings cover starting balances, cash interactions, banking, shared accounts, display options, and Zeus behavior.

`CfgFCash` values provide addon defaults and can also be overridden in mission config where appropriate.

See [docs/CONFIGURATION.md](docs/CONFIGURATION.md).

## 3DEN Editor

Objects and units expose a **Fuhrizen's Cash** category in **Edit Attributes**.

Units can define:
- starting wallet cash;
- starting personal-bank balance.

Objects can define:
- cash-stash state and starting cash;
- bank-terminal state.

Starting-value fields accept either a number or SQF code returning a number.

The **Shared Bank** module creates a shared account at mission start. Synchronized playable units are added as members, with the first synchronized playable unit becoming the owner.

See [docs/EDEN.md](docs/EDEN.md).

## Zeus

The **Fuhrizen's Cash** Zeus category contains:

- **Manage Funds**
- **Manage Shared Banks**
- **Manage Stash**
- **Set Bank Terminal**
- **Remove Bank Terminal**

Module dialogs expose only the fields required by the selected operation. Signed balance changes are supported where applicable.

See [docs/ZEUS.md](docs/ZEUS.md).

## Runtime behavior

- **Pay cash** is available only on living units.
- **Take cash** handles dead and captive targets and displays the available amount.
- Shared banks marked private are omitted from recipient browsing but remain reachable by their seven-digit account number.
- Supported ATM classes are treated as bank terminals:
  - `Land_Atm_01_F`
  - `Land_Atm_02_F`
  - `Land_ATM_01_malden_F`
  - `Land_ATM_02_malden_F`
- Map-baked ATM terrain objects are detected near players and converted server-side into interactive networked ATM objects.
- Runtime-created terminals and stashes install ACE interactions for current and JIP clients.
- Zeus feedback uses curator feedback messages while the curator interface is open.
- Player notifications use the compact FCash HUD overlay.

## Scripting API

Example:

```sqf
private _wallet = [] call FCash_fnc_getWallet;
[_player, 500, "ADD", "JOB_PAY"] call FCash_fnc_serverAdjustWallet;
```

See:
- [docs/API.md](docs/API.md)
- [docs/SECURITY.md](docs/SECURITY.md)

## License

See [LICENSE](LICENSE).
