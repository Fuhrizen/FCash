/*
 * Reads a wallet/cash balance.
 * Parameters: [account <STRING UID | OBJECT, optional>]
 * Client with no account: local cached player wallet.
 * Server with UID/object: authoritative player, AI, corpse or stash cash.
 * Returns: NUMBER
 */
params [["_account", "", ["", objNull]]];

if (isServer && {!(_account isEqualTo "")}) exitWith {
    if (_account isEqualType "") exitWith {
        private _wallets = missionNamespace getVariable ["FCash_server_wallets", createHashMap];
        _wallets getOrDefault [_account, 0]
    };

    if (isNull _account) exitWith {0};
    private _storage = missionNamespace getVariable ["FCash_server_storage", createHashMap];
    private _storageRecord = _storage getOrDefault [netId _account, []];
    if ((count _storageRecord) >= 2) exitWith {_storageRecord select 0};

    private _deathCashId = _account getVariable ["FCash_deathCashId", ""];
    if (!alive _account && {_deathCashId != ""}) exitWith {
        private _corpses = missionNamespace getVariable ["FCash_server_corpses", createHashMap];
        (_corpses getOrDefault [_deathCashId, [0, ""]]) param [0, 0]
    };

    if (isPlayer _account) exitWith {
        private _uid = getPlayerUID _account;
        private _wallets = missionNamespace getVariable ["FCash_server_wallets", createHashMap];
        _wallets getOrDefault [_uid, 0]
    };

    private _entities = missionNamespace getVariable ["FCash_server_entityWallets", createHashMap];
    _entities getOrDefault [netId _account, _account getVariable ["FCash_wallet", 0]]
};

if (_account isEqualType objNull && {!isNull _account}) exitWith {
    _account getVariable ["FCash_wallet", 0]
};
missionNamespace getVariable ["FCash_cache_wallet", 0]
