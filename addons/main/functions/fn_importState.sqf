/* Imports a serialized FCash persistence snapshot. */
params ["_state"];
if (isRemoteExecuted) exitWith {false};
if (!isServer || {!(_state isEqualType [])} || {count _state < 7}) exitWith {false};
if ((_state select 0) != 1) exitWith {false};

private _walletPairs = _state select 1;
private _bankPairs = _state select 2;
private _namePairs = _state select 3;
private _sharedRows = _state select 4;
private _storagePairs = _state select 5;
private _pinPairs = _state select 6;

private _toMap = {
    params ["_rows"];
    private _map = createHashMap;
    {
        if (_x isEqualType [] && {count _x >= 2}) then {
            _map set [_x select 0, _x select 1];
        };
    } forEach _rows;
    _map
};

private _wallets = [_walletPairs] call _toMap;
private _banks = [_bankPairs] call _toMap;
private _names = [_namePairs] call _toMap;
private _storage = [_storagePairs] call _toMap;
private _personalPins = [_pinPairs] call _toMap;
private _shared = createHashMap;

{
    if (_x isEqualType [] && {count _x >= 10}) then {
        _x params ["_id", "_name", "_balance", "_owner", "_members", "_invites", "_createdAt", "_pin", "_public", "_log"];
        _shared set [_id, createHashMapFromArray [
            ["name", _name],
            ["balance", round _balance max 0],
            ["owner", _owner],
            ["members", [_members] call _toMap],
            ["invites", [_invites] call _toMap],
            ["createdAt", _createdAt],
            ["pin", [_pin] call FCash_fnc_formatAccountNumber],
            ["public", _public],
            ["log", _log]
        ]];
    };
} forEach _sharedRows;

missionNamespace setVariable ["FCash_server_wallets", _wallets];
missionNamespace setVariable ["FCash_server_banks", _banks];
missionNamespace setVariable ["FCash_server_names", _names];
missionNamespace setVariable ["FCash_server_shared", _shared];
missionNamespace setVariable ["FCash_server_storage", _storage];
missionNamespace setVariable ["FCash_server_personalPins", _personalPins];
missionNamespace setVariable ["FCash_server_pinIndex", createHashMap];

private _token = missionNamespace getVariable ["FCash_server_internalToken", ""];
private _pinIndex = missionNamespace getVariable ["FCash_server_pinIndex", createHashMap];

{
    private _uid = _x;
    private _pin = [_personalPins getOrDefault [_uid, ""]] call FCash_fnc_formatAccountNumber;
    if (_pin == "") then {
        _pin = ["PERSONAL", _uid, _token] call FCash_fnc_serverGeneratePin;
    };
    if (_pin != "") then {
        _personalPins set [_uid, _pin];
        _pinIndex set [_pin, ["PERSONAL", _uid]];
    };
} forEach keys _banks;

{
    private _id = _x;
    private _account = _shared get _id;
    private _pin = [_account getOrDefault ["pin", ""]] call FCash_fnc_formatAccountNumber;
    if (_pin == "") then {
        _pin = ["SHARED", _id, _token] call FCash_fnc_serverGeneratePin;
    };
    if (_pin != "") then {
        _account set ["pin", _pin];
        _shared set [_id, _account];
        _pinIndex set [_pin, ["SHARED", _id]];
    };
} forEach keys _shared;

missionNamespace setVariable ["FCash_server_personalPins", _personalPins];
missionNamespace setVariable ["FCash_server_shared", _shared];
missionNamespace setVariable ["FCash_server_pinIndex", _pinIndex];

{
    [_x, _token] call FCash_fnc_serverSyncPlayer;
} forEach allPlayers;

true
