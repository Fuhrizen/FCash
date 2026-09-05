/* Refreshes the open banking dialog from the latest sanitized client snapshot. */
disableSerialization;
private _display = uiNamespace getVariable ["FCash_ui_bankDisplay", displayNull];
if (isNull _display) exitWith {};
if (uiNamespace getVariable ["FCash_ui_refreshing", false]) exitWith {};
uiNamespace setVariable ["FCash_ui_refreshing", true];

private _wallet = missionNamespace getVariable ["FCash_cache_wallet", 0];
private _bank = missionNamespace getVariable ["FCash_cache_bank", 0];
private _pin = [missionNamespace getVariable ["FCash_cache_personalPin", ""]] call FCash_fnc_formatAccountNumber;
private _shared = missionNamespace getVariable ["FCash_cache_shared", []];
private _invites = missionNamespace getVariable ["FCash_cache_invites", []];
private _players = missionNamespace getVariable ["FCash_cache_players", []];

(_display displayCtrl 61121) ctrlSetStructuredText parseText format ["<t color='#777A76'>WALLET</t><br/><t size='1.35' color='#E5DFC9'>%1</t>", [_wallet] call FCash_fnc_formatMoney];
(_display displayCtrl 61122) ctrlSetStructuredText parseText format ["<t color='#777A76'>BANK</t><br/><t size='1.35' color='#E5DFC9'>%1</t>", [_bank] call FCash_fnc_formatMoney];
(_display displayCtrl 61131) ctrlSetText format ["Account: %1", ["-------", _pin] select (_pin != "")];

private _personalRecipient = uiNamespace getVariable ["FCash_ui_personalRecipient", []];
(_display displayCtrl 61128) ctrlSetText (if (count _personalRecipient >= 2) then {_personalRecipient select 1} else {"No recipient selected"});

private _invitePlayer = _display displayCtrl 61152;
private _oldInvite = if ((lbCurSel _invitePlayer) >= 0) then {_invitePlayer lbData (lbCurSel _invitePlayer)} else {""};
lbClear _invitePlayer;
private _inviteSel = -1;
{
    _x params ["_uid", "_name"];
    private _i = _invitePlayer lbAdd _name;
    _invitePlayer lbSetData [_i, _uid];
    if (_uid == _oldInvite) then {_inviteSel = _i};
} forEach _players;
if (_inviteSel < 0 && {(lbSize _invitePlayer) > 0}) then {_inviteSel = 0};
if (_inviteSel >= 0) then {_invitePlayer lbSetCurSel _inviteSel};

private _accountCtrl = _display displayCtrl 61141;
private _selectedId = uiNamespace getVariable ["FCash_ui_sharedSelected", ""];
lbClear _accountCtrl;
private _selectedIndex = -1;
{
    _x params ["_id", "_name", "_balance", "_owner", "_role", "_members", "_accountPinRaw", "_public"];
    private _accountPin = [_accountPinRaw] call FCash_fnc_formatAccountNumber;
    private _i = _accountCtrl lbAdd format ["%1 | %2", _name, [_balance] call FCash_fnc_formatMoney];
    _accountCtrl lbSetData [_i, _id];
    if (_id == _selectedId) then {_selectedIndex = _i};
} forEach _shared;
if (_selectedIndex < 0 && {(lbSize _accountCtrl) > 0}) then {_selectedIndex = 0};
if (_selectedIndex >= 0) then {
    _accountCtrl lbSetCurSel _selectedIndex;
    _selectedId = _accountCtrl lbData _selectedIndex;
    uiNamespace setVariable ["FCash_ui_sharedSelected", _selectedId];
};

private _sharedRecipient = uiNamespace getVariable ["FCash_ui_sharedRecipient", []];
if (count _sharedRecipient >= 1 && {(_sharedRecipient select 0) == format ["S:%1", _selectedId]}) then {
    _sharedRecipient = [];
    uiNamespace setVariable ["FCash_ui_sharedRecipient", []];
};
(_display displayCtrl 61148) ctrlSetText (if (count _sharedRecipient >= 2) then {_sharedRecipient select 1} else {"No recipient selected"});

private _selectedRowIndex = _shared findIf {(_x select 0) isEqualTo _selectedId};
private _hasShared = _selectedRowIndex >= 0;
private _role = "NONE";
private _members = [];
if (_hasShared) then {
    private _row = _shared select _selectedRowIndex;
    _row params ["_id", "_name", "_balance", "_owner", "_rowRole", "_rowMembers", "_accountPinRaw", "_public"];
    private _accountPin = [_accountPinRaw] call FCash_fnc_formatAccountNumber;
    _role = _rowRole;
    _members = _rowMembers;
    (_display displayCtrl 61143) ctrlSetStructuredText parseText format ["<t color='#B59A52'>%1</t> <t color='#70736F'>| %2 | %3</t><br/><t size='1.35' color='#E5DFC9'>%4</t>", toUpper _name, ["-------", _accountPin] select (_accountPin != ""), ["PRIVATE", "PUBLIC"] select _public, [_balance] call FCash_fnc_formatMoney];
    (_display displayCtrl 61144) ctrlSetText format ["Role: %1", toLower _role];
    (_display displayCtrl 61159) ctrlSetText (["Private", "Public"] select _public);
} else {
    (_display displayCtrl 61143) ctrlSetStructuredText parseText "<t color='#777A76'>NO SHARED BANKS</t>";
    (_display displayCtrl 61144) ctrlSetText "Role: none";
    (_display displayCtrl 61159) ctrlSetText "Private";
};

private _memberCtrl = _display displayCtrl 61151;
private _oldMember = if ((lbCurSel _memberCtrl) >= 0) then {_memberCtrl lbData (lbCurSel _memberCtrl)} else {""};
lbClear _memberCtrl;
private _memberSel = -1;
{
    _x params ["_memberUid", "_memberName", "_memberRole"];
    private _i = _memberCtrl lbAdd format ["%1 | %2", _memberName, toLower _memberRole];
    _memberCtrl lbSetData [_i, _memberUid];
    if (_memberUid == _oldMember) then {_memberSel = _i};
} forEach _members;
if (_memberSel < 0 && {(lbSize _memberCtrl) > 0}) then {_memberSel = 0};
if (_memberSel >= 0) then {
    _memberCtrl lbSetCurSel _memberSel;
    [] call FCash_fnc_bankingMemberChanged;
};

private _canTransact = _role in ["OWNER", "MANAGER", "MEMBER"];
private _canInvite = _role in ["OWNER", "MANAGER"];
private _isOwner = _role == "OWNER";
{(_display displayCtrl _x) ctrlEnable (_hasShared && _canTransact)} forEach [61146,61147,61158];
(_display displayCtrl 61149) ctrlEnable (_hasShared && _canTransact && {count _sharedRecipient >= 1});
{(_display displayCtrl _x) ctrlEnable (_hasShared && _canInvite)} forEach [61152,61153,61154];
{(_display displayCtrl _x) ctrlEnable (_hasShared && _isOwner)} forEach [61156,61157,61159];
(_display displayCtrl 61164) ctrlEnable _hasShared;
(_display displayCtrl 61129) ctrlEnable (count _personalRecipient >= 1);

private _inviteCtrl = _display displayCtrl 61161;
lbClear _inviteCtrl;
{
    _x params ["_id", "_name", "_inviteRole", "_inviterUid", "_inviterName"];
    private _i = _inviteCtrl lbAdd format ["%1 | %2 | invited by %3", _name, toLower _inviteRole, _inviterName];
    _inviteCtrl lbSetData [_i, _id];
} forEach _invites;
if ((lbSize _inviteCtrl) > 0) then {_inviteCtrl lbSetCurSel 0};
{(_display displayCtrl _x) ctrlEnable ((lbSize _inviteCtrl) > 0)} forEach [61162,61163];

uiNamespace setVariable ["FCash_ui_refreshing", false];
