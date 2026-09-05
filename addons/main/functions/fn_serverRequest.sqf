/*
 * Remote request dispatcher. All client money mutations enter through this function.
 * The caller is derived from remoteExecutedOwner; no client-provided UID is trusted as sender identity.
 * Parameters: [operation <STRING>, data <ARRAY>]
 * Returns: nothing (responses are pushed to clients)
 */
params ["_operation", ["_data", []]];
if (!isServer) exitWith {};
if !(_operation isEqualType "") exitWith {};
if !(_data isEqualType []) exitWith {};

private _ownerId = remoteExecutedOwner;
private _token = missionNamespace getVariable ["FCash_server_internalToken", ""];
private _caller = [_ownerId] call FCash_fnc_serverFindCaller;
if (isNull _caller) exitWith {};
if !([_ownerId, _token] call FCash_fnc_serverRateLimit) exitWith {
    [_caller, "Too many FCash requests. Try again shortly.", "ERROR", _token] call FCash_fnc_serverNotify;
};

private _callerAccount = [_caller, _token] call FCash_fnc_serverEnsureAccount;
_callerAccount params ["_uid", "_callerWallet", "_callerBank"];
if (_uid == "") exitWith {};

private _wallets = missionNamespace getVariable ["FCash_server_wallets", createHashMap];
private _banks = missionNamespace getVariable ["FCash_server_banks", createHashMap];
private _sharedMap = missionNamespace getVariable ["FCash_server_shared", createHashMap];
private _storageMap = missionNamespace getVariable ["FCash_server_storage", createHashMap];
private _names = missionNamespace getVariable ["FCash_server_names", createHashMap];

private _reject = {
    params ["_message"];
    [_caller, _message, "ERROR", _token] call FCash_fnc_serverNotify;
};
private _success = {
    params ["_message"];
    [_caller, _message, "SUCCESS", _token] call FCash_fnc_serverNotify;
};
private _syncByUid = {
    params ["_targetUid"];
    private _idx = allPlayers findIf {getPlayerUID _x isEqualTo _targetUid};
    if (_idx >= 0) then {private _p = allPlayers select _idx; [_p, _token] call FCash_fnc_serverSyncPlayer};
};
private _validateAmount = {
    params ["_raw"];
    [_raw] call FCash_fnc_serverValidateAmount
};
private _sameSideAllowed = {
    params ["_targetPlayer"];
    if ((["allowBankTransferAnySide", 1] call FCash_fnc_getSetting) == 1) exitWith {true};
    side _caller isEqualTo side _targetPlayer
};

switch (_operation) do {
    case "SYNC": {
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
    };

    case "WALLET_GIVE": {
        _data params [["_target", objNull, [objNull]], ["_rawAmount", 0]];
        if ((["allowGive", 1] call FCash_fnc_getSetting) != 1) exitWith {["Cash giving is disabled."] call _reject};
        if (isNull _target || {_target isEqualTo _caller} || {!(_target isKindOf "CAManBase")} || {!alive _target}) exitWith {["Invalid cash recipient."] call _reject};
        if ((_caller distance _target) > (["interactionDistance", 3.5] call FCash_fnc_getSetting)) exitWith {["Recipient is too far away."] call _reject};

        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};
        private _balance = _wallets getOrDefault [_uid, 0];
        if (_balance < _amount) exitWith {["Insufficient wallet funds."] call _reject};

        private _targetRef = "";
        private _targetPlayer = objNull;
        private _recipientValid = true;
        private _deathCashId = _target getVariable ["FCash_deathCashId", ""];

        if (!alive _target && {_deathCashId != ""}) then {
            private _corpses = missionNamespace getVariable ["FCash_server_corpses", createHashMap];
            private _ownerUid = _target getVariable ["FCash_deathCashOwner", ""];
            private _record = _corpses getOrDefault [_deathCashId, [0, _ownerUid]];
            private _corpseBalance = _record param [0, 0];
            private _deadUid = _record param [1, _ownerUid];
            _corpses set [_deathCashId, [_corpseBalance + _amount, _deadUid]];
            missionNamespace setVariable ["FCash_server_corpses", _corpses];
            _target setVariable ["FCash_hasDeathCash", true, true];
            _target setVariable ["FCash_deathCashBalance", _corpseBalance + _amount, true];
            _targetRef = _deathCashId;
        } else {
            if (isPlayer _target && {alive _target}) then {
                private _targetAccount = [_target, _token] call FCash_fnc_serverEnsureAccount;
                private _targetUid = _targetAccount select 0;
                if (_targetUid == "") then {
                    _recipientValid = false;
                } else {
                    _wallets set [_targetUid, (_wallets getOrDefault [_targetUid, 0]) + _amount];
                    _targetRef = _targetUid;
                    _targetPlayer = _target;
                };
            } else {
                private _entityId = netId _target;
                if (_entityId == "") then {
                    _recipientValid = false;
                } else {
                    private _entityWallets = missionNamespace getVariable ["FCash_server_entityWallets", createHashMap];
                    private _new = (_entityWallets getOrDefault [_entityId, 0]) + _amount;
                    _entityWallets set [_entityId, _new];
                    missionNamespace setVariable ["FCash_server_entityWallets", _entityWallets];
                    _target setVariable ["FCash_wallet", _new, true];
                    _targetRef = _entityId;
                };
            };
        };
        if (!_recipientValid || {_targetRef == ""}) exitWith {["Recipient is not networked or available."] call _reject};

        _wallets set [_uid, _balance - _amount];
        missionNamespace setVariable ["FCash_server_wallets", _wallets];
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
        if (!isNull _targetPlayer) then {
            [_targetPlayer, _token] call FCash_fnc_serverSyncPlayer;
            [_targetPlayer, format ["Received %1 from %2.", [_amount] call FCash_fnc_formatMoney, name _caller], "SUCCESS", _token] call FCash_fnc_serverNotify;
        };
        [format ["Transferred %1 to %2.", [_amount] call FCash_fnc_formatMoney, name _target]] call _success;
        ["WALLET_GIVE", _uid, _targetRef, _amount, [typeOf _target, alive _target], _token] call FCash_fnc_serverAudit;
    };

    case "WALLET_TAKE": {
        _data params [["_target", objNull, [objNull]], ["_rawAmount", 0]];
        if (isNull _target || {_target isEqualTo _caller} || {!(_target isKindOf "CAManBase")}) exitWith {["Invalid cash source."] call _reject};
        if ((_caller distance _target) > (["interactionDistance", 3.5] call FCash_fnc_getSetting)) exitWith {["Target is too far away."] call _reject};

        private _deathCashId = _target getVariable ["FCash_deathCashId", ""];
        private _isPlayerCorpse = !alive _target && {_deathCashId != ""} && {(["allowTakeDead", 1] call FCash_fnc_getSetting) == 1};
        private _isCaptivePlayer = isPlayer _target && {alive _target} && {captive _target} && {(["allowTakeCaptive", 1] call FCash_fnc_getSetting) == 1};
        private _isNpcSource = !isPlayer _target && {
            (!alive _target && {(["allowTakeDead", 1] call FCash_fnc_getSetting) == 1}) ||
            (alive _target && {captive _target} && {(["allowTakeCaptive", 1] call FCash_fnc_getSetting) == 1})
        };
        if !(_isPlayerCorpse || _isCaptivePlayer || _isNpcSource) exitWith {["Cash cannot be taken from this target."] call _reject};

        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};

        private _targetRef = "";
        private _sourceBalance = 0;
        private _sourceKind = "";
        private _sourceUid = "";
        private _sourceMap = createHashMap;

        if (_isPlayerCorpse) then {
            private _corpses = missionNamespace getVariable ["FCash_server_corpses", createHashMap];
            private _record = _corpses getOrDefault [_deathCashId, []];
            if (count _record >= 2) then {
                _sourceBalance = _record select 0;
                _sourceUid = _record select 1;
                _sourceKind = "CORPSE";
                _sourceMap = _corpses;
                _targetRef = _deathCashId;
            };
        } else {
            if (_isCaptivePlayer) then {
                private _targetAccount = [_target, _token] call FCash_fnc_serverEnsureAccount;
                _sourceUid = _targetAccount select 0;
                _sourceBalance = _wallets getOrDefault [_sourceUid, 0];
                _sourceKind = "PLAYER";
                _targetRef = _sourceUid;
            } else {
                private _entityId = netId _target;
                private _entityWallets = missionNamespace getVariable ["FCash_server_entityWallets", createHashMap];
                _sourceBalance = _entityWallets getOrDefault [_entityId, 0];
                _sourceKind = "ENTITY";
                _sourceMap = _entityWallets;
                _targetRef = _entityId;
            };
        };

        if (_targetRef == "") exitWith {["Cash source is unavailable."] call _reject};
        if (_sourceBalance < _amount) exitWith {["Target does not have that much cash."] call _reject};
        private _remaining = _sourceBalance - _amount;

        switch (_sourceKind) do {
            case "CORPSE": {
                if (_remaining > 0) then {
                    _sourceMap set [_deathCashId, [_remaining, _sourceUid]];
                    _target setVariable ["FCash_deathCashBalance", _remaining, true];
                } else {
                    _sourceMap deleteAt _deathCashId;
                    _target setVariable ["FCash_hasDeathCash", false, true];
                    _target setVariable ["FCash_deathCashBalance", 0, true];
                };
                missionNamespace setVariable ["FCash_server_corpses", _sourceMap];
            };
            case "PLAYER": {
                _wallets set [_sourceUid, _remaining];
                [_target, _token] call FCash_fnc_serverSyncPlayer;
                [_target, format ["%1 took %2 from you.", name _caller, [_amount] call FCash_fnc_formatMoney], "ERROR", _token] call FCash_fnc_serverNotify;
            };
            case "ENTITY": {
                _sourceMap set [_targetRef, _remaining];
                missionNamespace setVariable ["FCash_server_entityWallets", _sourceMap];
                _target setVariable ["FCash_wallet", _remaining, true];
            };
        };

        _wallets set [_uid, (_wallets getOrDefault [_uid, 0]) + _amount];
        missionNamespace setVariable ["FCash_server_wallets", _wallets];
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
        [format ["Took %1.", [_amount] call FCash_fnc_formatMoney]] call _success;
        ["WALLET_TAKE", _uid, _targetRef, _amount, [_sourceKind, typeOf _target, alive _target], _token] call FCash_fnc_serverAudit;
    };

    case "STORAGE_DEPOSIT": {
        _data params [["_storage", objNull, [objNull]], ["_rawAmount", 0]];
        if (isNull _storage || {!(_storage getVariable ["FCash_isStorage", false])}) exitWith {["Invalid FCash storage."] call _reject};
        if ((_caller distance _storage) > (["interactionDistance", 3.5] call FCash_fnc_getSetting)) exitWith {["Storage is too far away."] call _reject};
        private _id = netId _storage;
        private _record = _storageMap getOrDefault [_id, []];
        if (count _record < 2) exitWith {["Storage is not registered on the server."] call _reject};
        _record params ["_stored", "_ownerUid"];
        if (_ownerUid != "" && {_ownerUid != _uid}) exitWith {["This storage is secured."] call _reject};
        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};
        private _balance = _wallets getOrDefault [_uid, 0];
        if (_balance < _amount) exitWith {["Insufficient wallet funds."] call _reject};

        _wallets set [_uid, _balance - _amount];
        _storageMap set [_id, [_stored + _amount, _ownerUid]];
        _storage setVariable ["FCash_storageBalance", _stored + _amount, true];
        missionNamespace setVariable ["FCash_server_wallets", _wallets];
        missionNamespace setVariable ["FCash_server_storage", _storageMap];
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
        [format ["Stored %1.", [_amount] call FCash_fnc_formatMoney]] call _success;
        ["STORAGE_DEPOSIT", _uid, _id, _amount, [], _token] call FCash_fnc_serverAudit;
    };

    case "STORAGE_WITHDRAW": {
        _data params [["_storage", objNull, [objNull]], ["_rawAmount", 0]];
        if (isNull _storage || {!(_storage getVariable ["FCash_isStorage", false])}) exitWith {["Invalid FCash storage."] call _reject};
        if ((_caller distance _storage) > (["interactionDistance", 3.5] call FCash_fnc_getSetting)) exitWith {["Storage is too far away."] call _reject};
        private _id = netId _storage;
        private _record = _storageMap getOrDefault [_id, []];
        if (count _record < 2) exitWith {["Storage is not registered on the server."] call _reject};
        _record params ["_stored", "_ownerUid"];
        if (_ownerUid != "" && {_ownerUid != _uid}) exitWith {["This storage is secured."] call _reject};
        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};
        if (_stored < _amount) exitWith {["Storage does not contain that much cash."] call _reject};

        _storageMap set [_id, [_stored - _amount, _ownerUid]];
        _storage setVariable ["FCash_storageBalance", _stored - _amount, true];
        _wallets set [_uid, (_wallets getOrDefault [_uid, 0]) + _amount];
        missionNamespace setVariable ["FCash_server_storage", _storageMap];
        missionNamespace setVariable ["FCash_server_wallets", _wallets];
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
        [format ["Withdrew %1 from storage.", [_amount] call FCash_fnc_formatMoney]] call _success;
        ["STORAGE_WITHDRAW", _uid, _id, _amount, [], _token] call FCash_fnc_serverAudit;
    };

    case "PERSONAL_DEPOSIT": {
        _data params [["_terminal", objNull, [objNull]], ["_rawAmount", 0]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};
        private _wallet = _wallets getOrDefault [_uid, 0];
        if (_wallet < _amount) exitWith {["Insufficient wallet funds."] call _reject};

        _wallets set [_uid, _wallet - _amount];
        _banks set [_uid, (_banks getOrDefault [_uid, 0]) + _amount];
        missionNamespace setVariable ["FCash_server_wallets", _wallets];
        missionNamespace setVariable ["FCash_server_banks", _banks];
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
        [format ["Deposited %1.", [_amount] call FCash_fnc_formatMoney]] call _success;
        ["BANK_DEPOSIT", _uid, _uid, _amount, [], _token] call FCash_fnc_serverAudit;
    };

    case "PERSONAL_WITHDRAW": {
        _data params [["_terminal", objNull, [objNull]], ["_rawAmount", 0]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};
        private _bank = _banks getOrDefault [_uid, 0];
        if (_bank < _amount) exitWith {["Insufficient bank funds."] call _reject};

        _banks set [_uid, _bank - _amount];
        _wallets set [_uid, (_wallets getOrDefault [_uid, 0]) + _amount];
        missionNamespace setVariable ["FCash_server_wallets", _wallets];
        missionNamespace setVariable ["FCash_server_banks", _banks];
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
        [format ["Withdrew %1.", [_amount] call FCash_fnc_formatMoney]] call _success;
        ["BANK_WITHDRAW", _uid, _uid, _amount, [], _token] call FCash_fnc_serverAudit;
    };

    case "PERSONAL_TRANSFER": {
        _data params [["_terminal", objNull, [objNull]], ["_targetRef", "", [""]], ["_rawAmount", 0]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _resolved = [_targetRef] call FCash_fnc_serverResolveBankTarget;
        _resolved params ["_targetKind", "_targetId", "_targetLabel", "_targetPlayer"];
        if (_targetKind == "NONE") exitWith {["Recipient account was not found."] call _reject};
        if (_targetKind == "PERSONAL" && {_targetId == _uid}) exitWith {["You cannot transfer to your own personal bank."] call _reject};
        if (_targetKind == "PERSONAL" && {!isNull _targetPlayer} && {!([_targetPlayer] call _sameSideAllowed)}) exitWith {["Transfers to that side are disabled."] call _reject};
        if (_targetKind == "PERSONAL" && {isNull _targetPlayer} && {(["allowBankTransferAnySide", 1] call FCash_fnc_getSetting) != 1}) exitWith {["Offline transfers require cross-side transfers to be enabled."] call _reject};
        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};
        private _bank = _banks getOrDefault [_uid, 0];
        if (_bank < _amount) exitWith {["Insufficient bank funds."] call _reject};

        _banks set [_uid, _bank - _amount];
        if (_targetKind == "PERSONAL") then {
            _banks set [_targetId, (_banks getOrDefault [_targetId, 0]) + _amount];
            missionNamespace setVariable ["FCash_server_banks", _banks];
            if (!isNull _targetPlayer) then {
                [_targetPlayer, _token] call FCash_fnc_serverSyncPlayer;
                [_targetPlayer, format ["%1 transferred %2 to your bank.", name _caller, [_amount] call FCash_fnc_formatMoney], "SUCCESS", _token] call FCash_fnc_serverNotify;
            };
        } else {
            private _targetShared = _sharedMap getOrDefault [_targetId, createHashMap];
            if (count _targetShared == 0) exitWith {["Recipient shared bank was not found."] call _reject};
            _targetShared set ["balance", (_targetShared getOrDefault ["balance", 0]) + _amount];
            _sharedMap set [_targetId, _targetShared];
            missionNamespace setVariable ["FCash_server_banks", _banks];
            missionNamespace setVariable ["FCash_server_shared", _sharedMap];
            {[_x] call _syncByUid} forEach keys (_targetShared getOrDefault ["members", createHashMap]);
            [_targetId, "SHARED_RECEIVE", _uid, _amount, name _caller, ["PERSONAL"], _token] call FCash_fnc_serverSharedLog;
        };
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
        [format ["Transferred %1 to %2.", [_amount] call FCash_fnc_formatMoney, _targetLabel]] call _success;
        ["BANK_TRANSFER", _uid, _targetId, _amount, [_targetKind, _targetLabel], _token] call FCash_fnc_serverAudit;
    };

    case "DIRECT_SEND": {
        _data params [["_targetUid", "", [""]], ["_rawAmount", 0]];
        if ((["allowDirectSend", 0] call FCash_fnc_getSetting) != 1) exitWith {["Direct wallet transfers are disabled."] call _reject};
        private _targetIndex = allPlayers findIf {getPlayerUID _x isEqualTo _targetUid};
        if (_targetIndex < 0 || {_targetUid == _uid}) exitWith {["Recipient is unavailable."] call _reject};
        private _target = allPlayers select _targetIndex;
        [_target, _token] call FCash_fnc_serverEnsureAccount;
        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};
        private _wallet = _wallets getOrDefault [_uid, 0];
        if (_wallet < _amount) exitWith {["Insufficient wallet funds."] call _reject};

        _wallets set [_uid, _wallet - _amount];
        _wallets set [_targetUid, (_wallets getOrDefault [_targetUid, 0]) + _amount];
        missionNamespace setVariable ["FCash_server_wallets", _wallets];
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
        [_target, _token] call FCash_fnc_serverSyncPlayer;
        [format ["Sent %1 to %2.", [_amount] call FCash_fnc_formatMoney, name _target]] call _success;
        [_target, format ["Received %1 from %2.", [_amount] call FCash_fnc_formatMoney, name _caller], "SUCCESS", _token] call FCash_fnc_serverNotify;
        ["DIRECT_SEND", _uid, _targetUid, _amount, [], _token] call FCash_fnc_serverAudit;
    };

    case "SHARED_CREATE": {
        _data params [["_terminal", objNull, [objNull]], ["_name", "", [""]]];
        if ((["sharedBankEnabled", 1] call FCash_fnc_getSetting) != 1) exitWith {["Shared banking is disabled."] call _reject};
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _owned = 0;
        {if (((_sharedMap get _x) getOrDefault ["owner", ""]) isEqualTo _uid) then {_owned = _owned + 1}} forEach keys _sharedMap;
        if (_owned >= round (["sharedMaxOwned", 5] call FCash_fnc_getSetting)) exitWith {["Shared account ownership limit reached."] call _reject};
        private _fee = round (["sharedCreateFee", 0] call FCash_fnc_getSetting) max 0;
        private _bank = _banks getOrDefault [_uid, 0];
        if (_bank < _fee) exitWith {["Insufficient bank funds for the account creation fee."] call _reject};
        private _id = [_uid, _name, 0, "PLAYER", _token, true] call FCash_fnc_serverCreateShared;
        if (_id == "") exitWith {["Could not create shared bank. Check the account name."] call _reject};
        if (_fee > 0) then {
            _banks set [_uid, _bank - _fee];
            missionNamespace setVariable ["FCash_server_banks", _banks];
        };
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
        private _created = (missionNamespace getVariable ["FCash_server_shared", createHashMap]) get _id;
        [format ["Created shared bank '%1' (%2).", _name, [(_created getOrDefault ["pin", ""])] call FCash_fnc_formatAccountNumber]] call _success;
        ["SHARED_CREATE", _uid, _id, _fee, [_name], _token] call FCash_fnc_serverAudit;
    };

    case "SHARED_INVITE": {
        _data params [["_terminal", objNull, [objNull]], ["_id", "", [""]], ["_targetUid", "", [""]], ["_role", "MEMBER", [""]]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _shared = _sharedMap getOrDefault [_id, createHashMap];
        if (count _shared == 0) exitWith {["Shared account not found."] call _reject};
        private _callerRole = [_shared, _uid] call FCash_fnc_serverGetSharedRole;
        if !([_callerRole, "INVITE"] call FCash_fnc_serverSharedCan) exitWith {["You cannot invite members to this account."] call _reject};
        if !(_role in ["MANAGER", "MEMBER", "VIEWER"]) exitWith {["Invalid shared-bank role."] call _reject};
        private _targetIndex = allPlayers findIf {getPlayerUID _x isEqualTo _targetUid};
        if (_targetIndex < 0 || {_targetUid == _uid}) exitWith {["Invite target is unavailable."] call _reject};
        private _target = allPlayers select _targetIndex;
        [_target, _token] call FCash_fnc_serverEnsureAccount;
        if (([_shared, _targetUid] call FCash_fnc_serverGetSharedRole) != "NONE") exitWith {["That player is already a member."] call _reject};
        private _members = _shared getOrDefault ["members", createHashMap];
        if ((count _members) >= round (["sharedMaxMembers", 32] call FCash_fnc_getSetting)) exitWith {["Shared account member limit reached."] call _reject};
        private _invites = _shared getOrDefault ["invites", createHashMap];
        _invites set [_targetUid, [_role, _uid, name _caller]];
        _shared set ["invites", _invites];
        _sharedMap set [_id, _shared];
        missionNamespace setVariable ["FCash_server_shared", _sharedMap];
        [_caller, _token] call FCash_fnc_serverSyncPlayer;
        [_target, _token] call FCash_fnc_serverSyncPlayer;
        [format ["Invited %1 as %2.", name _target, toLower _role]] call _success;
        [_target, format ["%1 invited you to '%2'.", name _caller, _shared get "name"], "INFO", _token] call FCash_fnc_serverNotify;
        ["SHARED_INVITE", _uid, _targetUid, 0, [_id, _role], _token] call FCash_fnc_serverAudit;
        [_id, "SHARED_INVITE", _uid, 0, name _target, [_role], _token] call FCash_fnc_serverSharedLog;
    };

    case "SHARED_INVITE_RESPONSE": {
        _data params [["_terminal", objNull, [objNull]], ["_id", "", [""]], ["_accept", false, [false]]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _shared = _sharedMap getOrDefault [_id, createHashMap];
        if (count _shared == 0) exitWith {["Shared account not found."] call _reject};
        private _invites = _shared getOrDefault ["invites", createHashMap];
        if (isNil {_invites get _uid}) exitWith {["Invitation no longer exists."] call _reject};
        private _invite = _invites get _uid;
        private _role = _invite select 0;
        private _members = _shared getOrDefault ["members", createHashMap];
        if (_accept && {(count _members) >= round (["sharedMaxMembers", 32] call FCash_fnc_getSetting)}) exitWith {["Shared account member limit reached."] call _reject};
        _invites deleteAt _uid;
        if (_accept) then {
            _members set [_uid, _role];
            _shared set ["members", _members];
        };
        _shared set ["invites", _invites];
        _sharedMap set [_id, _shared];
        missionNamespace setVariable ["FCash_server_shared", _sharedMap];
        if (_accept) then {
            {private _memberUid = _x; [_memberUid] call _syncByUid} forEach keys _members;
        } else {
            [_caller, _token] call FCash_fnc_serverSyncPlayer;
        };
        [format ["Invitation %1.", ["declined", "accepted"] select _accept]] call _success;
        ["SHARED_INVITE_RESPONSE", _uid, _id, 0, [_accept, _role], _token] call FCash_fnc_serverAudit;
        [_id, "SHARED_MEMBER", _uid, 0, ["Invitation declined", "Invitation accepted"] select _accept, [_role], _token] call FCash_fnc_serverSharedLog;
    };

    case "SHARED_DEPOSIT": {
        _data params [["_terminal", objNull, [objNull]], ["_id", "", [""]], ["_rawAmount", 0]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _shared = _sharedMap getOrDefault [_id, createHashMap];
        if (count _shared == 0) exitWith {["Shared account not found."] call _reject};
        private _role = [_shared, _uid] call FCash_fnc_serverGetSharedRole;
        if !([_role, "DEPOSIT"] call FCash_fnc_serverSharedCan) exitWith {["You cannot deposit to this account."] call _reject};
        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};
        private _bank = _banks getOrDefault [_uid, 0];
        if (_bank < _amount) exitWith {["Insufficient personal bank funds."] call _reject};

        _banks set [_uid, _bank - _amount];
        _shared set ["balance", (_shared getOrDefault ["balance", 0]) + _amount];
        _sharedMap set [_id, _shared];
        missionNamespace setVariable ["FCash_server_banks", _banks];
        missionNamespace setVariable ["FCash_server_shared", _sharedMap];
        {private _memberUid = _x; [_memberUid] call _syncByUid} forEach keys (_shared get "members");
        [format ["Deposited %1 to '%2'.", [_amount] call FCash_fnc_formatMoney, _shared get "name"]] call _success;
        ["SHARED_DEPOSIT", _uid, _id, _amount, [], _token] call FCash_fnc_serverAudit;
        [_id, "SHARED_DEPOSIT", _uid, _amount, "Personal bank", [], _token] call FCash_fnc_serverSharedLog;
    };

    case "SHARED_WITHDRAW": {
        _data params [["_terminal", objNull, [objNull]], ["_id", "", [""]], ["_rawAmount", 0]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _shared = _sharedMap getOrDefault [_id, createHashMap];
        if (count _shared == 0) exitWith {["Shared account not found."] call _reject};
        private _role = [_shared, _uid] call FCash_fnc_serverGetSharedRole;
        if !([_role, "WITHDRAW"] call FCash_fnc_serverSharedCan) exitWith {["You cannot withdraw from this account."] call _reject};
        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};
        private _balance = _shared getOrDefault ["balance", 0];
        if (_balance < _amount) exitWith {["Insufficient shared-bank funds."] call _reject};

        _shared set ["balance", _balance - _amount];
        _banks set [_uid, (_banks getOrDefault [_uid, 0]) + _amount];
        _sharedMap set [_id, _shared];
        missionNamespace setVariable ["FCash_server_banks", _banks];
        missionNamespace setVariable ["FCash_server_shared", _sharedMap];
        {private _memberUid = _x; [_memberUid] call _syncByUid} forEach keys (_shared get "members");
        [format ["Withdrew %1 from '%2'.", [_amount] call FCash_fnc_formatMoney, _shared get "name"]] call _success;
        ["SHARED_WITHDRAW", _uid, _id, _amount, [], _token] call FCash_fnc_serverAudit;
        [_id, "SHARED_WITHDRAW", _uid, -_amount, "Personal bank", [], _token] call FCash_fnc_serverSharedLog;
    };

    case "SHARED_TRANSFER": {
        _data params [["_terminal", objNull, [objNull]], ["_id", "", [""]], ["_targetRef", "", [""]], ["_rawAmount", 0]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _shared = _sharedMap getOrDefault [_id, createHashMap];
        if (count _shared == 0) exitWith {["Shared account not found."] call _reject};
        private _role = [_shared, _uid] call FCash_fnc_serverGetSharedRole;
        if !([_role, "TRANSFER"] call FCash_fnc_serverSharedCan) exitWith {["You cannot transfer from this account."] call _reject};
        private _resolved = [_targetRef] call FCash_fnc_serverResolveBankTarget;
        _resolved params ["_targetKind", "_targetId", "_targetLabel", "_targetPlayer"];
        if (_targetKind == "NONE") exitWith {["Recipient account was not found."] call _reject};
        if (_targetKind == "SHARED" && {_targetId == _id}) exitWith {["You cannot transfer to the same shared bank."] call _reject};
        if (_targetKind == "PERSONAL" && {!isNull _targetPlayer} && {!([_targetPlayer] call _sameSideAllowed)}) exitWith {["Transfers to that side are disabled."] call _reject};
        if (_targetKind == "PERSONAL" && {isNull _targetPlayer} && {(["allowBankTransferAnySide", 1] call FCash_fnc_getSetting) != 1}) exitWith {["Offline transfers require cross-side transfers to be enabled."] call _reject};
        private _validated = [_rawAmount] call _validateAmount;
        _validated params ["_ok", "_amount", "_reason"];
        if (!_ok) exitWith {[_reason] call _reject};
        private _balance = _shared getOrDefault ["balance", 0];
        if (_balance < _amount) exitWith {["Insufficient shared-bank funds."] call _reject};

        _shared set ["balance", _balance - _amount];
        _sharedMap set [_id, _shared];
        if (_targetKind == "PERSONAL") then {
            _banks set [_targetId, (_banks getOrDefault [_targetId, 0]) + _amount];
            missionNamespace setVariable ["FCash_server_banks", _banks];
            if (!isNull _targetPlayer) then {
                [_targetPlayer, _token] call FCash_fnc_serverSyncPlayer;
                [_targetPlayer, format ["'%1' transferred %2 to your bank.", _shared get "name", [_amount] call FCash_fnc_formatMoney], "SUCCESS", _token] call FCash_fnc_serverNotify;
            };
        } else {
            private _targetShared = _sharedMap getOrDefault [_targetId, createHashMap];
            if (count _targetShared == 0) exitWith {["Recipient shared bank was not found."] call _reject};
            _targetShared set ["balance", (_targetShared getOrDefault ["balance", 0]) + _amount];
            _sharedMap set [_targetId, _targetShared];
        };
        missionNamespace setVariable ["FCash_server_shared", _sharedMap];
        if (_targetKind == "SHARED") then {
            private _targetShared = _sharedMap get _targetId;
            [_targetId, "SHARED_RECEIVE", _uid, _amount, _shared getOrDefault ["name", "Shared Bank"], [_id], _token] call FCash_fnc_serverSharedLog;
            {[_x] call _syncByUid} forEach keys (_targetShared getOrDefault ["members", createHashMap]);
        };
        [_id, "SHARED_TRANSFER", _uid, -_amount, _targetLabel, [_targetKind, _targetId], _token] call FCash_fnc_serverSharedLog;
        {[_x] call _syncByUid} forEach keys (_shared getOrDefault ["members", createHashMap]);
        [format ["Transferred %1 from '%2' to %3.", [_amount] call FCash_fnc_formatMoney, _shared get "name", _targetLabel]] call _success;
        ["SHARED_TRANSFER", _uid, _targetId, _amount, [_id, _targetKind], _token] call FCash_fnc_serverAudit;
    };

    case "SHARED_TOGGLE_PUBLIC": {
        _data params [["_terminal", objNull, [objNull]], ["_id", "", [""]]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _shared = _sharedMap getOrDefault [_id, createHashMap];
        if (count _shared == 0) exitWith {["Shared account not found."] call _reject};
        if ((_shared getOrDefault ["owner", ""]) != _uid) exitWith {["Only the owner can change bank visibility."] call _reject};
        private _public = !(_shared getOrDefault ["public", true]);
        _shared set ["public", _public];
        _sharedMap set [_id, _shared];
        missionNamespace setVariable ["FCash_server_shared", _sharedMap];
        {[_x, _token] call FCash_fnc_serverSyncPlayer} forEach allPlayers;
        [_id, "SHARED_VISIBILITY", _uid, 0, ["Private", "Public"] select _public, [], _token] call FCash_fnc_serverSharedLog;
        [format ["Shared bank is now %1.", toLower (["private", "public"] select _public)]] call _success;
    };

    case "SHARED_LOG_REQUEST": {
        _data params [["_terminal", objNull, [objNull]], ["_id", "", [""]]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _shared = _sharedMap getOrDefault [_id, createHashMap];
        if (count _shared == 0) exitWith {["Shared account not found."] call _reject};
        if (([_shared, _uid] call FCash_fnc_serverGetSharedRole) == "NONE") exitWith {["You are not a member of this shared bank."] call _reject};
        [_shared getOrDefault ["name", "Shared Bank"], [(_shared getOrDefault ["pin", ""])] call FCash_fnc_formatAccountNumber, _shared getOrDefault ["log", []]] remoteExecCall ["FCash_fnc_clientSharedLog", owner _caller];
    };

    case "SHARED_SET_ROLE": {
        _data params [["_terminal", objNull, [objNull]], ["_id", "", [""]], ["_targetUid", "", [""]], ["_newRole", "MEMBER", [""]]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _shared = _sharedMap getOrDefault [_id, createHashMap];
        if (count _shared == 0) exitWith {["Shared account not found."] call _reject};
        private _role = [_shared, _uid] call FCash_fnc_serverGetSharedRole;
        if !([_role, "SET_ROLE"] call FCash_fnc_serverSharedCan) exitWith {["Only the account owner can change roles."] call _reject};
        if (_targetUid == (_shared getOrDefault ["owner", ""])) exitWith {["The owner role cannot be changed."] call _reject};
        if !(_newRole in ["MANAGER", "MEMBER", "VIEWER"]) exitWith {["Invalid role."] call _reject};
        private _members = _shared getOrDefault ["members", createHashMap];
        if (isNil {_members get _targetUid}) exitWith {["Member not found."] call _reject};
        _members set [_targetUid, _newRole];
        _shared set ["members", _members];
        _sharedMap set [_id, _shared];
        missionNamespace setVariable ["FCash_server_shared", _sharedMap];
        {private _memberUid = _x; [_memberUid] call _syncByUid} forEach keys _members;
        ["Role updated."] call _success;
        ["SHARED_ROLE", _uid, _targetUid, 0, [_id, _newRole], _token] call FCash_fnc_serverAudit;
        [_id, "SHARED_MEMBER", _uid, 0, _names getOrDefault [_targetUid, _targetUid], ["ROLE", _newRole], _token] call FCash_fnc_serverSharedLog;
    };

    case "SHARED_REMOVE": {
        _data params [["_terminal", objNull, [objNull]], ["_id", "", [""]], ["_targetUid", "", [""]]];
        if !([_caller, _terminal] call FCash_fnc_serverValidateTerminal) exitWith {["You are not at a valid bank terminal."] call _reject};
        private _shared = _sharedMap getOrDefault [_id, createHashMap];
        if (count _shared == 0) exitWith {["Shared account not found."] call _reject};
        private _role = [_shared, _uid] call FCash_fnc_serverGetSharedRole;
        if !([_role, "REMOVE"] call FCash_fnc_serverSharedCan) exitWith {["Only the account owner can remove members."] call _reject};
        if (_targetUid == (_shared getOrDefault ["owner", ""])) exitWith {["The account owner cannot be removed."] call _reject};
        private _members = _shared getOrDefault ["members", createHashMap];
        if (isNil {_members get _targetUid}) exitWith {["Member not found."] call _reject};
        _members deleteAt _targetUid;
        _shared set ["members", _members];
        _sharedMap set [_id, _shared];
        missionNamespace setVariable ["FCash_server_shared", _sharedMap];
        {private _memberUid = _x; [_memberUid] call _syncByUid} forEach keys _members;
        [_targetUid] call _syncByUid;
        ["Member removed."] call _success;
        ["SHARED_REMOVE", _uid, _targetUid, 0, [_id], _token] call FCash_fnc_serverAudit;
        [_id, "SHARED_MEMBER", _uid, 0, _names getOrDefault [_targetUid, _targetUid], ["REMOVE"], _token] call FCash_fnc_serverSharedLog;
    };

    default {
        ["Unknown FCash request."] call _reject;
    };
};
