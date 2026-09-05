/*
 * Ensures authoritative wallet/bank records and the seven-digit personal account number exist for a player.
 * 3DEN starting values and pending shared memberships are resolved here so playable slots work correctly on dedicated/JIP.
 * Returns: [uid, wallet, bank]
 */
params ["_player", ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {["", 0, 0]};
if (!isServer || {isNull _player} || {!isPlayer _player}) exitWith {["", 0, 0]};

private _uid = getPlayerUID _player;
if (_uid == "") exitWith {["", 0, 0]};

private _wallets = missionNamespace getVariable ["FCash_server_wallets", createHashMap];
private _banks = missionNamespace getVariable ["FCash_server_banks", createHashMap];
private _names = missionNamespace getVariable ["FCash_server_names", createHashMap];
private _pins = missionNamespace getVariable ["FCash_server_personalPins", createHashMap];

if (isNil {_wallets get _uid}) then {
    private _raw = _player getVariable ["FCash_3denWalletRaw", ""];
    private _start = [_player, _raw, ["startWallet", 0] call FCash_fnc_getSetting, _token] call FCash_fnc_serverResolveStartingValue;
    _wallets set [_uid, _start];
};
if (isNil {_banks get _uid}) then {
    private _raw = _player getVariable ["FCash_3denBankRaw", ""];
    private _start = [_player, _raw, ["startBank", 0] call FCash_fnc_getSetting, _token] call FCash_fnc_serverResolveStartingValue;
    _banks set [_uid, _start];
};

private _pinIndex = missionNamespace getVariable ["FCash_server_pinIndex", createHashMap];
private _pin = [_pins getOrDefault [_uid, ""]] call FCash_fnc_formatAccountNumber;
if (_pin == "") then {
    _pin = ["PERSONAL", _uid, _token] call FCash_fnc_serverGeneratePin;
};
if (_pin != "") then {
    _pins set [_uid, _pin];
    _pinIndex set [_pin, ["PERSONAL", _uid]];
    missionNamespace setVariable ["FCash_server_pinIndex", _pinIndex];
};
_names set [_uid, name _player];

missionNamespace setVariable ["FCash_server_wallets", _wallets];
missionNamespace setVariable ["FCash_server_banks", _banks];
missionNamespace setVariable ["FCash_server_names", _names];
missionNamespace setVariable ["FCash_server_personalPins", _pins];

// Resolve shared-bank memberships authored through 3DEN synchronization.
private _pending = _player getVariable ["FCash_pendingSharedMembership", []];
if !(_pending isEqualTo []) then {
    private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
    {
        _x params ["_id", ["_role", "MEMBER"], ["_missionOwner", ""]];
        private _shared = _sharedMap getOrDefault [_id, createHashMap];
        if (count _shared > 0) then {
            private _members = _shared getOrDefault ["members", createHashMap];
            if (_role == "OWNER") then {
                private _oldOwner = _shared getOrDefault ["owner", ""];
                if (_oldOwner == _missionOwner || {((_oldOwner find "MISSION:") == 0)}) then {
                    _members deleteAt _oldOwner;
                    _shared set ["owner", _uid];
                    _members set [_uid, "OWNER"];
                } else {
                    if (isNil {_members get _uid}) then {_members set [_uid, "MEMBER"]};
                };
            } else {
                if (isNil {_members get _uid}) then {_members set [_uid, _role]};
            };
            _shared set ["members", _members];
            _sharedMap set [_id, _shared];
        };
    } forEach _pending;
    missionNamespace setVariable ["FCash_server_shared", _sharedMap];
    _player setVariable ["FCash_pendingSharedMembership", nil, true];
};

[_uid, _wallets get _uid, _banks get _uid]
