/*
 * Reads a personal/entity bank balance.
 * Parameters: [account <STRING UID | OBJECT, optional>]
 * Client with no account: local cached player bank.
 * Server with UID/object: authoritative player, AI or stash balance.
 * Returns: NUMBER
 */
params [["_account", "", ["", objNull]]];

if (isServer && {!(_account isEqualTo "")}) exitWith {
    if (_account isEqualType "") exitWith {
        private _banks = missionNamespace getVariable ["FCash_server_banks", createHashMap];
        _banks getOrDefault [_account, 0]
    };

    if (isNull _account) exitWith {0};
    private _storage = missionNamespace getVariable ["FCash_server_storage", createHashMap];
    private _storageRecord = _storage getOrDefault [netId _account, []];
    if ((count _storageRecord) >= 2) exitWith {_storageRecord select 0};

    private _ownerUid = _account getVariable ["FCash_deathCashOwner", ""];
    if (_ownerUid != "") exitWith {
        private _banks = missionNamespace getVariable ["FCash_server_banks", createHashMap];
        _banks getOrDefault [_ownerUid, 0]
    };

    if (isPlayer _account) exitWith {
        private _uid = getPlayerUID _account;
        private _banks = missionNamespace getVariable ["FCash_server_banks", createHashMap];
        _banks getOrDefault [_uid, 0]
    };

    private _entities = missionNamespace getVariable ["FCash_server_entityBanks", createHashMap];
    _entities getOrDefault [netId _account, _account getVariable ["FCash_bank", 0]]
};

if (_account isEqualType objNull && {!isNull _account}) exitWith {
    _account getVariable ["FCash_bank", 0]
};
missionNamespace getVariable ["FCash_cache_bank", 0]
