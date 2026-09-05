/*
 * Applies Fuhrizen's Cash 3DEN object attributes to one initialized entity.
 * Handles unit starting wallet/bank values and object stash/terminal flags.
 */
params ["_entity", ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {};
if (!isServer || {isNull _entity}) exitWith {};
if (_entity getVariable ["FCash_3denApplied", false]) exitWith {};
_entity setVariable ["FCash_3denApplied", true];

if (_entity isKindOf "CAManBase") then {
    // Players are resolved by serverEnsureAccount after UID assignment. AI can be initialized now.
    if (!isPlayer _entity) then {
        private _walletRaw = _entity getVariable ["FCash_3denWalletRaw", ""];
        private _bankRaw = _entity getVariable ["FCash_3denBankRaw", ""];
        private _wallet = [_entity, _walletRaw, ["startWallet", 0] call FCash_fnc_getSetting, _token] call FCash_fnc_serverResolveStartingValue;
        private _bank = [_entity, _bankRaw, ["startBank", 0] call FCash_fnc_getSetting, _token] call FCash_fnc_serverResolveStartingValue;
        [_entity, _wallet, "SET", "3DEN", _token] call FCash_fnc_serverAdjustWallet;
        [_entity, _bank, "SET", "3DEN", _token] call FCash_fnc_serverAdjustBank;
    };
} else {
    if (_entity getVariable ["FCash_3denIsStorage", false]) then {
        private _raw = _entity getVariable ["FCash_3denStorageRaw", "0"];
        private _starting = [_entity, _raw, 0, _token] call FCash_fnc_serverResolveStartingValue;
        [_entity, "", _starting, _token] call FCash_fnc_registerStorage;
    };
    if (_entity getVariable ["FCash_3denIsTerminal", false]) then {
        [_entity, _token] call FCash_fnc_registerTerminal;
    };
};
