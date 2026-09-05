/* Sends a sanitized authoritative banking snapshot to a player. */
params ["_player", ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {};
if (!isServer || {isNull _player} || {!isPlayer _player}) exitWith {};

private _account = [_player, _token] call FCash_fnc_serverEnsureAccount;
_account params ["_uid", "_wallet", "_bank"];
if (_uid == "") exitWith {};

_player setVariable ["FCash_wallet", _wallet, true];
_player setVariable ["FCash_bank", _bank, true];

private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
private _names = missionNamespace getVariable ["FCash_server_names", createHashMap];
private _personalPins = missionNamespace getVariable ["FCash_server_personalPins", createHashMap];
private _personalPin = _personalPins getOrDefault [_uid, ""];
private _sharedOut = [];
private _invitesOut = [];
private _recipientOut = [];

{
    private _id = _x;
    private _shared = _sharedMap get _id;
    private _pin = [_shared getOrDefault ["pin", ""]] call FCash_fnc_formatAccountNumber;
    if (_pin == "") then {
        _pin = ["SHARED", _id, _token] call FCash_fnc_serverGeneratePin;
    };
    if (_pin != "") then {
        _shared set ["pin", _pin];
        _sharedMap set [_id, _shared];
        private _pinIndex = missionNamespace getVariable ["FCash_server_pinIndex", createHashMap];
        _pinIndex set [_pin, ["SHARED", _id]];
        missionNamespace setVariable ["FCash_server_pinIndex", _pinIndex];
    };
    private _public = _shared getOrDefault ["public", true];
    private _role = [_shared, _uid] call FCash_fnc_serverGetSharedRole;

    if (_role != "NONE") then {
        private _members = _shared getOrDefault ["members", createHashMap];
        private _memberRows = [];
        {
            private _memberUid = _x;
            // Internal 3DEN ownership markers are not exposed as account members.
            if ((_memberUid find "MISSION:") != 0) then {
                private _memberRole = _members get _memberUid;
                _memberRows pushBack [_memberUid, _names getOrDefault [_memberUid, _memberUid], _memberRole];
            };
        } forEach keys _members;
        _sharedOut pushBack [
            _id,
            _shared getOrDefault ["name", "Shared Account"],
            _shared getOrDefault ["balance", 0],
            _shared getOrDefault ["owner", ""],
            _role,
            _memberRows,
            _pin,
            _public
        ];
    };

    if (_public) then {
        _recipientOut pushBack [format ["S:%1", _id], _shared getOrDefault ["name", "Shared Bank"], _pin, "SHARED"];
    };

    private _invites = _shared getOrDefault ["invites", createHashMap];
    if !(isNil {_invites get _uid}) then {
        private _invite = _invites get _uid;
        _invite params [["_inviteRole", "MEMBER"], ["_inviterUid", ""], ["_inviterName", "Unknown"]];
        _invitesOut pushBack [_id, _shared getOrDefault ["name", "Shared Account"], _inviteRole, _inviterUid, _inviterName];
    };
} forEach keys _sharedMap;
missionNamespace setVariable ["FCash_server_shared", _sharedMap];

private _playersOut = [];
{
    if (isPlayer _x && {alive _x}) then {
        private _otherAccount = [_x, _token] call FCash_fnc_serverEnsureAccount;
        private _otherUid = _otherAccount select 0;
        if (_otherUid != "" && {_otherUid != _uid}) then {
            private _otherName = name _x;
            private _pin = (missionNamespace getVariable ["FCash_server_personalPins", createHashMap]) getOrDefault [_otherUid, ""];
            _playersOut pushBack [_otherUid, _otherName, side _x];
            _recipientOut pushBack [format ["P:%1", _otherUid], _otherName, _pin, "PERSONAL"];
        };
    };
} forEach allPlayers;

[_wallet, _bank, _personalPin, _sharedOut, _invitesOut, _recipientOut, _playersOut] remoteExecCall ["FCash_fnc_clientSync", owner _player];
