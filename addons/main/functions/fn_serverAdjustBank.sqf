/*
 * Server-only bank adjustment for a UID or object.
 * Objects may be players, AI/NPCs, player corpses (owner bank), or registered stashes.
 * Parameters: [account <STRING UID | OBJECT>, value <NUMBER>, mode <ADD|SET>, reason <STRING>, internalToken <STRING optional>]
 * Returns: new balance, or -1 on failure
 */
params ["_account", "_value", ["_mode", "ADD"], ["_reason", "SCRIPT"], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {-1};
if (!isServer || {!(_value isEqualType 0)} || {!(finite _value)} || {!(_mode in ["ADD", "SET"])}) exitWith {-1};

if (_account isEqualType objNull) exitWith {
    if (isNull _account) exitWith {-1};
    private _id = netId _account;
    if (_id == "") exitWith {-1};

    private _storage = missionNamespace getVariable ["FCash_server_storage", createHashMap];
    if ((count (_storage getOrDefault [_id, []])) >= 2) exitWith {
        [_account, _value, _mode, _reason, _token] call FCash_fnc_serverAdjustStorage
    };

    private _ownerUid = _account getVariable ["FCash_deathCashOwner", ""];
    if (_ownerUid != "") exitWith {
        [_ownerUid, _value, _mode, _reason, _token] call FCash_fnc_serverAdjustBank
    };

    if (isPlayer _account) exitWith {
        [getPlayerUID _account, _value, _mode, _reason, _token] call FCash_fnc_serverAdjustBank
    };

    private _map = missionNamespace getVariable ["FCash_server_entityBanks", createHashMap];
    private _old = _map getOrDefault [_id, 0];
    private _new = if (_mode == "SET") then {round _value max 0} else {round (_old + _value) max 0};
    _map set [_id, _new];
    missionNamespace setVariable ["FCash_server_entityBanks", _map];
    _account setVariable ["FCash_bank", _new, true];
    ["BANK_ADJUST_ENTITY", "SERVER", _id, _new - _old, [_reason, _old, _new], _token] call FCash_fnc_serverAudit;
    _new
};

if !(_account isEqualType "") exitWith {-1};
private _uid = _account;
if (_uid == "") exitWith {-1};
private _banks = missionNamespace getVariable ["FCash_server_banks", createHashMap];
private _old = _banks getOrDefault [_uid, 0];
private _new = if (_mode == "SET") then {round _value max 0} else {round (_old + _value) max 0};
_banks set [_uid, _new];
missionNamespace setVariable ["FCash_server_banks", _banks];

private _playerIndex = allPlayers findIf {getPlayerUID _x isEqualTo _uid};
if (_playerIndex >= 0) then {[allPlayers select _playerIndex, _token] call FCash_fnc_serverSyncPlayer};
["BANK_ADJUST", "SERVER", _uid, _new - _old, [_reason, _old, _new], _token] call FCash_fnc_serverAudit;
_new
