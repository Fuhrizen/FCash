/*
 * Exports serializable authoritative state for persistence adapters. Server only.
 * Schema 1: [schema, wallets, banks, names, shared, storage, personalPins]
 */
if (isRemoteExecuted) exitWith {[]};
if (!isServer) exitWith {[]};

private _pairs = {
    params ["_map"];
    private _out = [];
    {_out pushBack [_x, _map get _x]} forEach keys _map;
    _out
};

private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
private _sharedOut = [];
{
    private _id = _x;
    private _a = _sharedMap get _id;
    _sharedOut pushBack [
        _id,
        _a getOrDefault ["name", "Shared Account"],
        _a getOrDefault ["balance", 0],
        _a getOrDefault ["owner", ""],
        [_a getOrDefault ["members", createHashMap]] call _pairs,
        [_a getOrDefault ["invites", createHashMap]] call _pairs,
        _a getOrDefault ["createdAt", []],
        _a getOrDefault ["pin", ""],
        _a getOrDefault ["public", true],
        _a getOrDefault ["log", []]
    ];
} forEach keys _sharedMap;

[
    1,
    [missionNamespace getVariable ["FCash_server_wallets", createHashMap]] call _pairs,
    [missionNamespace getVariable ["FCash_server_banks", createHashMap]] call _pairs,
    [missionNamespace getVariable ["FCash_server_names", createHashMap]] call _pairs,
    _sharedOut,
    [missionNamespace getVariable ["FCash_server_storage", createHashMap]] call _pairs,
    [missionNamespace getVariable ["FCash_server_personalPins", createHashMap]] call _pairs
]
