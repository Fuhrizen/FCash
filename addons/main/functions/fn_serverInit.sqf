/*
 * Initializes authoritative server ledgers, death-cash handling and runtime registries.
 * Parameters: none
 * Returns: nothing
 */
if (!isServer || {isRemoteExecuted}) exitWith {};
if (missionNamespace getVariable ["FCash_serverInitialized", false]) exitWith {};
missionNamespace setVariable ["FCash_serverInitialized", true];
missionNamespace setVariable ["FCash_server_internalToken", format ["%1:%2:%3", random 1e12, diag_tickTime, serverTime]];

// Initialise independently so a persistence layer may preload only some stores before postInit.
{
    _x params ["_name", "_default"];
    if (isNil {missionNamespace getVariable _name}) then {
        missionNamespace setVariable [_name, _default];
    };
} forEach [
    ["FCash_server_wallets", createHashMap],
    ["FCash_server_banks", createHashMap],
    ["FCash_server_names", createHashMap],
    ["FCash_server_shared", createHashMap],
    ["FCash_server_storage", createHashMap],
    ["FCash_server_terminals", createHashMap],
    ["FCash_server_corpses", createHashMap],
    ["FCash_server_entityWallets", createHashMap],
    ["FCash_server_entityBanks", createHashMap],
    ["FCash_server_personalPins", createHashMap],
    ["FCash_server_pinIndex", createHashMap],
    ["FCash_server_promotedTerrainATMs", createHashMap],
    ["FCash_server_rate", createHashMap],
    ["FCash_server_audit", []],
    ["FCash_server_sharedCounter", 0]
];

// Apply FCash 3DEN object attributes to existing mission entities and objects created later.
// Registration happens on the server so starting scripts and stash/terminal state are authoritative.
["All", "InitPost", {
    params ["_entity"];
    private _token = missionNamespace getVariable ["FCash_server_internalToken", ""];
    [_entity, _token] call FCash_fnc_serverApply3DENObject;
}, true, [], true] call CBA_fnc_addClassEventHandler;

// When cash is configured to drop on death, transfer it atomically from the UID wallet
// into a transient corpse ledger. This keeps corpse looting valid even after respawn.
addMissionEventHandler ["EntityKilled", {
    params ["_unit"];
    if (!isServer || {!isPlayer _unit}) exitWith {};
    if ((["loseWalletOnDeath", 1] call FCash_fnc_getSetting) != 1) exitWith {};

    private _uid = getPlayerUID _unit;
    if (_uid == "") exitWith {};
    private _wallets = missionNamespace getVariable ["FCash_server_wallets", createHashMap];
    private _amount = _wallets getOrDefault [_uid, 0];
    if (_amount <= 0) exitWith {};

    private _corpseId = netId _unit;
    if (_corpseId == "") exitWith {};
    private _corpses = missionNamespace getVariable ["FCash_server_corpses", createHashMap];
    _corpses set [_corpseId, [_amount, _uid]];
    _wallets set [_uid, 0];
    missionNamespace setVariable ["FCash_server_corpses", _corpses];
    missionNamespace setVariable ["FCash_server_wallets", _wallets];

    _unit setVariable ["FCash_hasDeathCash", true, true];
    _unit setVariable ["FCash_deathCashId", _corpseId, true];
    _unit setVariable ["FCash_deathCashOwner", _uid, true];
    _unit setVariable ["FCash_deathCashBalance", _amount, true];

    private _token = missionNamespace getVariable ["FCash_server_internalToken", ""];
    [_unit, _token] call FCash_fnc_serverSyncPlayer;
    ["DEATH_DROP", _uid, _corpseId, _amount, [], _token] call FCash_fnc_serverAudit;
}];

// Transient corpse balances are discarded with the corpse; they are intentionally not persistent.
addMissionEventHandler ["EntityDeleted", {
    params ["_entity"];
    if (!isServer) exitWith {};
    private _entityId = netId _entity;
    if (_entityId != "") then {
        private _entityWallets = missionNamespace getVariable ["FCash_server_entityWallets", createHashMap];
        private _entityBanks = missionNamespace getVariable ["FCash_server_entityBanks", createHashMap];
        _entityWallets deleteAt _entityId;
        _entityBanks deleteAt _entityId;
        missionNamespace setVariable ["FCash_server_entityWallets", _entityWallets];
        missionNamespace setVariable ["FCash_server_entityBanks", _entityBanks];
    };

    private _corpseId = _entity getVariable ["FCash_deathCashId", ""];
    if (_corpseId != "") then {
        private _corpses = missionNamespace getVariable ["FCash_server_corpses", createHashMap];
        _corpses deleteAt _corpseId;
        missionNamespace setVariable ["FCash_server_corpses", _corpses];
    };
}];
