/* Dispatches a banking UI action to the authoritative server. */
params ["_action"];
disableSerialization;
private _display = uiNamespace getVariable ["FCash_ui_bankDisplay", displayNull];
if (isNull _display) exitWith {};
private _terminal = uiNamespace getVariable ["FCash_ui_terminal", objNull];
if (isNull _terminal) exitWith {["Bank terminal is unavailable.", "ERROR"] call FCash_fnc_clientNotify};

private _personalAmount = round parseNumber ctrlText (_display displayCtrl 61124);
private _sharedAmount = round parseNumber ctrlText (_display displayCtrl 61145);
private _accountCtrl = _display displayCtrl 61141;
private _accountId = if ((lbCurSel _accountCtrl) >= 0) then {_accountCtrl lbData (lbCurSel _accountCtrl)} else {""};

switch (_action) do {
    case "PERSONAL_DEPOSIT": {["PERSONAL_DEPOSIT", [_terminal, _personalAmount]] remoteExecCall ["FCash_fnc_serverRequest", 2]};
    case "PERSONAL_WITHDRAW": {["PERSONAL_WITHDRAW", [_terminal, _personalAmount]] remoteExecCall ["FCash_fnc_serverRequest", 2]};
    case "PERSONAL_TRANSFER": {
        private _recipient = uiNamespace getVariable ["FCash_ui_personalRecipient", []];
        if (count _recipient < 1) exitWith {["Select a recipient.", "ERROR"] call FCash_fnc_clientNotify};
        ["PERSONAL_TRANSFER", [_terminal, _recipient select 0, _personalAmount]] remoteExecCall ["FCash_fnc_serverRequest", 2];
    };
    case "SHARED_CREATE": {createDialog "FCash_CreateSharedDialog"};
    case "SHARED_DEPOSIT": {["SHARED_DEPOSIT", [_terminal, _accountId, _sharedAmount]] remoteExecCall ["FCash_fnc_serverRequest", 2]};
    case "SHARED_WITHDRAW": {["SHARED_WITHDRAW", [_terminal, _accountId, _sharedAmount]] remoteExecCall ["FCash_fnc_serverRequest", 2]};
    case "SHARED_TRANSFER": {
        private _recipient = uiNamespace getVariable ["FCash_ui_sharedRecipient", []];
        if (count _recipient < 1) exitWith {["Select a recipient.", "ERROR"] call FCash_fnc_clientNotify};
        ["SHARED_TRANSFER", [_terminal, _accountId, _recipient select 0, _sharedAmount]] remoteExecCall ["FCash_fnc_serverRequest", 2];
    };
    case "SHARED_TOGGLE_PUBLIC": {["SHARED_TOGGLE_PUBLIC", [_terminal, _accountId]] remoteExecCall ["FCash_fnc_serverRequest", 2]};
    case "SHARED_INVITE": {
        private _playerCtrl = _display displayCtrl 61152;
        private _roleCtrl = _display displayCtrl 61153;
        private _p = lbCurSel _playerCtrl;
        private _r = lbCurSel _roleCtrl;
        if (_p < 0 || {_r < 0}) exitWith {["Select a player and role.", "ERROR"] call FCash_fnc_clientNotify};
        ["SHARED_INVITE", [_terminal, _accountId, _playerCtrl lbData _p, _roleCtrl lbData _r]] remoteExecCall ["FCash_fnc_serverRequest", 2];
    };
    case "SHARED_SET_ROLE": {
        private _memberCtrl = _display displayCtrl 61151;
        private _roleCtrl = _display displayCtrl 61153;
        private _m = lbCurSel _memberCtrl;
        private _r = lbCurSel _roleCtrl;
        if (_m < 0 || {_r < 0}) exitWith {["Select a member and role.", "ERROR"] call FCash_fnc_clientNotify};
        ["SHARED_SET_ROLE", [_terminal, _accountId, _memberCtrl lbData _m, _roleCtrl lbData _r]] remoteExecCall ["FCash_fnc_serverRequest", 2];
    };
    case "SHARED_REMOVE": {
        private _memberCtrl = _display displayCtrl 61151;
        private _m = lbCurSel _memberCtrl;
        if (_m < 0) exitWith {["Select a member.", "ERROR"] call FCash_fnc_clientNotify};
        ["SHARED_REMOVE", [_terminal, _accountId, _memberCtrl lbData _m]] remoteExecCall ["FCash_fnc_serverRequest", 2];
    };
    case "INVITE_ACCEPT": {
        private _ctrl = _display displayCtrl 61161;
        private _idx = lbCurSel _ctrl;
        if (_idx < 0) exitWith {["Select an invitation.", "ERROR"] call FCash_fnc_clientNotify};
        ["SHARED_INVITE_RESPONSE", [_terminal, _ctrl lbData _idx, true]] remoteExecCall ["FCash_fnc_serverRequest", 2];
    };
    case "INVITE_DECLINE": {
        private _ctrl = _display displayCtrl 61161;
        private _idx = lbCurSel _ctrl;
        if (_idx < 0) exitWith {["Select an invitation.", "ERROR"] call FCash_fnc_clientNotify};
        ["SHARED_INVITE_RESPONSE", [_terminal, _ctrl lbData _idx, false]] remoteExecCall ["FCash_fnc_serverRequest", 2];
    };
};
