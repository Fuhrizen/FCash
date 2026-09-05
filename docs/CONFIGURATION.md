# FCash configuration

FCash reads `CfgFCash` from `missionConfigFile` first and falls back to the addon defaults in `configFile`. This allows a mission to tune behaviour without repacking the mod.

## Settings

| Setting | Default | Meaning |
|---|---:|---|
| `startWallet` | `0` | Initial physical cash when a UID is first seen by the server ledger. |
| `startBank` | `0` | Initial personal bank balance when a UID is first seen. |
| `loseWalletOnDeath` | `1` | Clears remaining wallet cash when the player respawns. |
| `allowGive` | `1` | Enables physical player-to-player cash giving. |
| `allowTakeDead` | `1` | Allows taking physical cash from a dead player before respawn. |
| `allowTakeCaptive` | `1` | Allows taking physical cash from captive players. |
| `allowDirectSend` | `0` | Enables the `DIRECT_SEND` request/API path. Disabled by default. |
| `allowBankTransferAnySide` | `1` | If `0`, personal/shared bank transfers require both players to be on the same side. |
| `interactionDistance` | `3.5` | Server-side maximum distance for physical cash/storage transactions. |
| `terminalDistance` | `5.0` | Server-side maximum distance for banking operations. |
| `maxTransaction` | `100000000` | Maximum accepted value for one transaction. |
| `sharedBankEnabled` | `1` | Enables shared-account creation and use. |
| `sharedCreateFee` | `0` | Fee deducted from the creator's personal bank. |
| `sharedMaxOwned` | `5` | Maximum shared accounts owned by one UID. |
| `sharedMaxMembers` | `32` | Maximum members per shared account, including owner. |
| `sharedNameMin` | `3` | Minimum shared account name length. |
| `sharedNameMax` | `32` | Maximum shared account name length. |
| `requestBurst` | `10` | Maximum client requests accepted inside `requestWindow`. |
| `requestWindow` | `1.0` | Rate-limit window in seconds. |
| `auditLimit` | `250` | Maximum authoritative audit rows kept in memory. |
| `currencySymbol` | `"$"` | Prefix used by FCash UI formatting. |
| `atmClasses[]` | Arma ATM classes | Vehicle/object classes treated as bank terminals. |

## Example

```cpp
class CfgFCash {
    startWallet = 250;
    startBank = 2500;
    loseWalletOnDeath = 1;

    allowGive = 1;
    allowTakeDead = 1;
    allowTakeCaptive = 1;
    allowDirectSend = 0;

    interactionDistance = 3.0;
    terminalDistance = 4.5;
    maxTransaction = 5000000;

    sharedBankEnabled = 1;
    sharedCreateFee = 500;
    sharedMaxOwned = 3;
    sharedMaxMembers = 16;

    currencySymbol = "$";
    atmClasses[] = {
        "Land_Atm_01_F",
        "Land_Atm_02_F",
        "Land_Atm_03_F"
    };
};
```

## CfgRemoteExec

FCash ships target restrictions for its network entry points but does **not** force a global whitelist mode, because doing so from an addon can break unrelated mission/mod remote execution. If your mission uses `mode = 1`, ensure its final merged policy includes:

```cpp
class FCash_fnc_serverRequest { allowedTargets = 2; jip = 0; };
class FCash_fnc_clientSync { allowedTargets = 1; jip = 0; };
class FCash_fnc_clientNotify { allowedTargets = 1; jip = 0; };
class FCash_fnc_clientEvent { allowedTargets = 1; jip = 0; };
class FCash_fnc_clientInstallObjectActions { allowedTargets = 1; jip = 1; };
```

When a mission defines its own `CfgRemoteExec`, merge/import the entries required by every loaded mod rather than replacing them blindly.
