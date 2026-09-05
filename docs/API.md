# FCash API

All balances are integer currency units. Client getters return the last server snapshot; only server APIs are authoritative.

## Client/common API

### `FCash_fnc_getWallet`

```sqf
private _wallet = [] call FCash_fnc_getWallet;
```

On a client, returns the local cached wallet. On the server, `[uid] call FCash_fnc_getWallet` reads the authoritative map.

**Parameters:** optional UID string.  
**Returns:** number.

### `FCash_fnc_getBank`

```sqf
private _bank = [] call FCash_fnc_getBank;
```

On a client, returns the local cached personal-bank balance. On the server, `[uid] call FCash_fnc_getBank` reads the authoritative map.

**Parameters:** optional UID string.  
**Returns:** number.

### `FCash_fnc_requestSync`

```sqf
[] call FCash_fnc_requestSync;
```

Requests a fresh sanitized snapshot from the server.

**Returns:** nothing.

### `FCash_fnc_openBanking`

```sqf
[_atmObject] call FCash_fnc_openBanking;
```

Opens the banking UI. The server independently verifies that the supplied object is a configured/registered terminal and that the player remains in range for every transaction.

**Parameters:** terminal object.  
**Returns:** nothing.

### `FCash_fnc_openAmountDialog`

```sqf
[_targetPlayer, "WALLET_GIVE"] call FCash_fnc_openAmountDialog;
```

Modes intended for mission/UI use:

- `WALLET_GIVE`
- `WALLET_TAKE`
- `STORAGE_DEPOSIT`
- `STORAGE_WITHDRAW`
- `DIRECT_SEND` (requires `allowDirectSend = 1`)

**Parameters:** target object, mode string.  
**Returns:** nothing.

## Server-only mutation API

These functions reject direct remote execution. Call them from server-side mission code, persistence code, admin systems, or trusted server event handlers.

### `FCash_fnc_serverAdjustWallet`

```sqf
[getPlayerUID _player, 500, "ADD", "JOB_PAY"] call FCash_fnc_serverAdjustWallet;
[getPlayerUID _player, 0, "SET", "ADMIN_RESET"] call FCash_fnc_serverAdjustWallet;
```

**Parameters:** UID string, value number, mode `ADD`/`SET`, reason string.  
**Returns:** new balance, or `-1` on failure.

A negative `ADD` debits the wallet but is clamped at zero. Mission systems that require strict insufficient-funds rejection should inspect the authoritative balance first or use their own server transaction wrapper.

### `FCash_fnc_serverAdjustBank`

```sqf
[getPlayerUID _player, 2500, "ADD", "SALARY"] call FCash_fnc_serverAdjustBank;
```

**Parameters/return:** same pattern as `FCash_fnc_serverAdjustWallet`.

### `FCash_fnc_registerStorage`

```sqf
[_crate, "", 0] call FCash_fnc_registerStorage;
[_safe, getPlayerUID _owner, 1000] call FCash_fnc_registerStorage;
```

Registers a networked object as cash storage and installs ACE actions for clients. A non-empty owner UID makes the storage secured to that UID.

**Parameters:** object, optional owner UID string, optional starting balance.  
**Returns:** boolean.

### `FCash_fnc_registerTerminal`

```sqf
[_customBankDesk] call FCash_fnc_registerTerminal;
```

Registers a custom networked object as a valid bank terminal and installs its ACE banking action.

**Returns:** boolean.

## Persistence API

### `FCash_fnc_exportState`

```sqf
private _state = [] call FCash_fnc_exportState;
```

Server only. Returns a serializable schema-versioned array containing wallets, banks, names, shared accounts and registered storage state. Use this as input to your database/extDB adapter.

### `FCash_fnc_importState`

```sqf
private _ok = [_savedState] call FCash_fnc_importState;
```

Server only. Imports schema version `1`, replaces the in-memory ledger and resynchronizes connected players.

### `FCash_fnc_getAuditLog`

```sqf
private _rows = [] call FCash_fnc_getAuditLog;
```

Server only. Returns a copy of the bounded in-memory audit log.

## Custom events

FCash has a lightweight local event registry. The returned handler ID can be removed later.

```sqf
private _id = ["transaction", {
    params ["_type", "_actorUid", "_target", "_amount", "_details"];
}] call FCash_fnc_addEventHandler;

["transaction", _id] call FCash_fnc_removeEventHandler;
```

### Server events

`transaction` — emitted after an authoritative transaction/audit write.

Payload:

```sqf
[_type, _actorUid, _target, _amount, _details]
```

### Client events

`balanceChanged`

```sqf
[_accountType, _oldBalance, _newBalance]
```

`sharedChanged`

```sqf
[_sharedAccounts, _pendingInvites]
```

`snapshot`

```sqf
[_wallet, _bank, _sharedAccounts, _pendingInvites, _onlinePlayers]
```
