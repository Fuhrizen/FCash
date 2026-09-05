/*
 * Low-friction Zeus administration dispatcher.
 * Gameplay transactions stay server-led, but assigned curators bypass terminal,
 * proximity and player rate-limit checks for live administration.
 */
params ["_action", ["_data", []]];
if (!isServer || {!(_action isEqualType "")} || {!(_data isEqualType [])}) exitWith {};

private _ownerId = remoteExecutedOwner;
private _token = missionNamespace getVariable ["FCash_server_internalToken", ""];
private _caller = [_ownerId] call FCash_fnc_serverFindCaller;
if (isNull _caller) exitWith {};
if ((["zeusModulesEnabled", 1] call FCash_fnc_getSetting) != 1) exitWith {
    [_caller, "Cash administration modules are disabled.", "ERROR", _token] call FCash_fnc_serverNotify;
};
private _curator = getAssignedCuratorLogic _caller;
if (isNull _curator) exitWith {
    [_caller, "You are not an assigned curator.", "ERROR", _token] call FCash_fnc_serverNotify;
};

private _callerUid = getPlayerUID _caller;
private _reason = format ["ZEUS:%1:%2", _callerUid, name _caller];
private _notify = {
    params ["_message", ["_kind", "INFO"]];
    [_caller, _message, _kind, _token] call FCash_fnc_serverNotify;
};
private _notifyAffected = {
    params ["_targetPlayer", "_message"];
    if ((["zeusNotifyAffectedPlayers", 1] call FCash_fnc_getSetting) == 1 && {!isNull _targetPlayer} && {isPlayer _targetPlayer}) then {
        [_targetPlayer, _message, "INFO", _token] call FCash_fnc_serverNotify;
    };
};

private _attachedOps = ["FUNDS_MANAGE", "STASH_MANAGE", "TERMINAL_SET", "TERMINAL_REMOVE"];
private _globalOps = ["SHARED_MANAGE"];
private _allOps = _attachedOps + _globalOps;

private _storageRecord = {
    params ["_object"];
    if (isNull _object) exitWith {[]};
    (missionNamespace getVariable ["FCash_server_storage", createHashMap]) getOrDefault [netId _object, []]
};

switch (_action) do {
    case "OPEN": {
        _data params [["_operation", "", [""]], ["_target", objNull, [objNull]]];
        if !(_operation in _allOps) exitWith {["Unknown cash module operation.", "ERROR"] call _notify};
        if (_operation in _attachedOps && {isNull _target}) exitWith {["Attach this module to an object or unit.", "ERROR"] call _notify};

        if (_operation == "FUNDS_MANAGE") then {
            private _record = [_target] call _storageRecord;
            if ((count _record) < 2 && {!(_target isKindOf "CAManBase")}) exitWith {
                ["Manage Funds requires a unit or registered stash.", "ERROR"] call _notify;
            };
        };

        private _title = if (isNull _target) then {""} else {
            if (_target isKindOf "CAManBase" && {name _target != ""}) then {name _target} else {typeOf _target}
        };
        private _record = [_target] call _storageRecord;
        private _isStorage = count _record >= 2;
        private _stashBalance = if (_isStorage) then {_record select 0} else {0};
        private _wallet = if (!isNull _target && {_target isKindOf "CAManBase"}) then {[_target] call FCash_fnc_getWallet} else {0};
        private _bank = if (!isNull _target && {_target isKindOf "CAManBase"}) then {[_target] call FCash_fnc_getBank} else {0};

        private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
        private _shared = [];
        {
            private _id = _x;
            private _account = _sharedMap get _id;
            private _pin = [_account getOrDefault ["pin", ""]] call FCash_fnc_formatAccountNumber;
            _shared pushBack [
                _id,
                _account getOrDefault ["name", "Shared Account"],
                _account getOrDefault ["balance", 0],
                _pin,
                _account getOrDefault ["public", true]
            ];
        } forEach keys _sharedMap;

        [_operation, _target, [_title, _wallet, _bank, _isStorage, _stashBalance], _shared] remoteExecCall ["FCash_fnc_clientZeusContext", owner _caller];
    };

    case "EXECUTE": {
        _data params [
            ["_operation", "", [""]],
            ["_target", objNull, [objNull]],
            ["_mode", "SET", [""]],
            ["_rawValue", 0],
            ["_selector", "", [""]],
            ["_name", "", [""]]
        ];
        if !(_operation in _allOps) exitWith {["Unknown cash module operation.", "ERROR"] call _notify};
        if (_operation in _attachedOps && {isNull _target}) exitWith {["Target object is no longer available.", "ERROR"] call _notify};
        if !(_rawValue isEqualType 0) then {_rawValue = parseNumber str _rawValue};
        if !(finite _rawValue) exitWith {["Invalid value.", "ERROR"] call _notify};
        private _signedValue = round _rawValue;
        private _value = _signedValue max 0;
        _mode = toUpper _mode;
        _selector = toUpper _selector;

        private _ok = false;
        private _message = "Operation failed.";

        switch (_operation) do {
            case "FUNDS_MANAGE": {
                private _record = [_target] call _storageRecord;
                private _isStorage = count _record >= 2;
                if (!_isStorage && {!(_target isKindOf "CAManBase")}) exitWith {};
                if (_isStorage) then {_selector = "STASH"};
                if !(_selector in ["WALLET", "BANK", "STASH"]) then {_selector = "WALLET"};
                if !(_mode in ["SET", "CHANGE"]) then {_mode = "SET"};
                private _adjustValue = [_signedValue, _value] select (_mode == "SET");
                private _adjustMode = ["ADD", "SET"] select (_mode == "SET");
                private _new = switch (_selector) do {
                    case "STASH": {[_target, _adjustValue, _adjustMode, _reason, _token] call FCash_fnc_serverAdjustStorage};
                    case "BANK": {[_target, _adjustValue, _adjustMode, _reason, _token] call FCash_fnc_serverAdjustBank};
                    default {[_target, _adjustValue, _adjustMode, _reason, _token] call FCash_fnc_serverAdjustWallet};
                };
                _ok = _new >= 0;
                if (_ok) then {
                    private _label = toLower _selector;
                    _message = format ["%1 balance: %2", _label, [_new] call FCash_fnc_formatMoney];
                    if (isPlayer _target) then {[_target, format ["Zeus adjusted your %1 to %2.", _label, [_new] call FCash_fnc_formatMoney]] call _notifyAffected};
                };
            };

            case "SHARED_MANAGE": {
                if !(_mode in ["CREATE", "CHANGE", "DELETE"]) then {_mode = "CHANGE"};
                switch (_mode) do {
                    case "CREATE": {
                        private _id = [_callerUid, _name, _value, _reason, _token, true] call FCash_fnc_serverCreateShared;
                        _ok = _id != "";
                        _message = ["Could not create shared bank.", format ["Created shared bank '%1'.", _name]] select _ok;
                    };
                    case "DELETE": {
                        if (_selector == "") exitWith {};
                        private _refund = [_selector, _reason, _token] call FCash_fnc_serverDeleteShared;
                        _ok = _refund >= 0;
                        _message = ["Shared bank not found.", format ["Removed shared bank. Refunded %1 to its owner.", [_refund] call FCash_fnc_formatMoney]] select _ok;
                    };
                    default {
                        if (_selector == "") exitWith {};
                        private _new = [_selector, _signedValue, "ADD", _reason, _token, _callerUid] call FCash_fnc_serverAdjustShared;
                        _ok = _new >= 0;
                        if (_ok) then {_message = format ["Shared bank balance: %1", [_new] call FCash_fnc_formatMoney]};
                    };
                };
            };

            case "STASH_MANAGE": {
                switch (_mode) do {
                    case "CREATE": {
                        private _record = [_target] call _storageRecord;
                        if ((count _record) >= 2) then {
                            private _new = [_target, _value, "SET", _reason, _token] call FCash_fnc_serverAdjustStorage;
                            _ok = _new >= 0;
                        } else {
                            _ok = [_target, "", _value, _token] call FCash_fnc_registerStorage;
                        };
                        _message = ["Could not create/update stash.", format ["Stash balance: %1.", [_value] call FCash_fnc_formatMoney]] select _ok;
                    };
                    case "CHANGE": {
                        private _new = [_target, _signedValue, "ADD", _reason, _token] call FCash_fnc_serverAdjustStorage;
                        _ok = _new >= 0;
                        _message = ["Object is not a stash.", format ["Stash balance: %1.", [_new max 0] call FCash_fnc_formatMoney]] select _ok;
                    };
                    default {
                        _ok = [_target, _token, true] call FCash_fnc_unregisterStorage;
                        _message = ["Object is not a stash.", "Stash removed from object."] select _ok;
                    };
                };
            };

            case "TERMINAL_SET": {
                _ok = [_target, _token] call FCash_fnc_registerTerminal;
                _message = ["Could not enable bank terminal.", "Bank terminal enabled on object."] select _ok;
            };

            case "TERMINAL_REMOVE": {
                _ok = [_target, _token] call FCash_fnc_unregisterTerminal;
                _message = ["Object is not a registered bank terminal.", "Bank terminal removed from object."] select _ok;
            };
        };

        [_message, ["ERROR", "SUCCESS"] select _ok] call _notify;
    };
};
