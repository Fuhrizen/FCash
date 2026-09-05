/*
 * Server-only wallet adjustment for a UID or object.
 * Objects may be players, AI/NPCs, tracked corpses, or registered stashes.
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

    private _deathCashId = _account getVariable ["FCash_deathCashId", ""];
    if (!alive _account && {_deathCashId != ""}) exitWith {
        private _corpses = missionNamespace getVariable ["FCash_server_corpses", createHashMap];
        private _record = _corpses getOrDefault [_deathCashId, [0, _account getVariable ["FCash_deathCashOwner", ""]]];
        private _old = _record param [0, 0];
        private _new = if (_mode == "SET") then {round _value max 0} else {round (_old + _value) max 0};
        if (_new > 0) then {
            _corpses set [_deathCashId, [_new, _record param [1, ""]]];
            _account setVariable ["FCash_hasDeathCash", true, true];
        } else {
            _corpses deleteAt _deathCashId;
            _account setVariable ["FCash_hasDeathCash", false, true];
        };
        missionNamespace setVariable ["FCash_server_corpses", _corpses];
        ["WALLET_ADJUST_CORPSE", "SERVER", _deathCashId, _new - _old, [_reason, _old, _new], _token] call FCash_fnc_serverAudit;
        _new
    };

    if (isPlayer _account) exitWith {
        [getPlayerUID _account, _value, _mode, _reason, _token] call FCash_fnc_serverAdjustWallet
    };

    private _map = missionNamespace getVariable ["FCash_server_entityWallets", createHashMap];
    private _old = _map getOrDefault [_id, 0];
    private _new = if (_mode == "SET") then {round _value max 0} else {round (_old + _value) max 0};
    _map set [_id, _new];
    missionNamespace setVariable ["FCash_server_entityWallets", _map];
    _account setVariable ["FCash_wallet", _new, true];
    ["WALLET_ADJUST_ENTITY", "SERVER", _id, _new - _old, [_reason, _old, _new], _token] call FCash_fnc_serverAudit;
    _new
};

if !(_account isEqualType "") exitWith {-1};
private _uid = _account;
if (_uid == "") exitWith {-1};
private _wallets = missionNamespace getVariable ["FCash_server_wallets", createHashMap];
private _old = _wallets getOrDefault [_uid, 0];
private _new = if (_mode == "SET") then {round _value max 0} else {round (_old + _value) max 0};
_wallets set [_uid, _new];
missionNamespace setVariable ["FCash_server_wallets", _wallets];

private _playerIndex = allPlayers findIf {getPlayerUID _x isEqualTo _uid};
if (_playerIndex >= 0) then {[allPlayers select _playerIndex, _token] call FCash_fnc_serverSyncPlayer};
["WALLET_ADJUST", "SERVER", _uid, _new - _old, [_reason, _old, _new], _token] call FCash_fnc_serverAudit;
_new
