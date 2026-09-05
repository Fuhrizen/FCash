/*
 * Registers mission/server configurable CBA Addon Options for Fuhrizen's Cash.
 * Runs during preInit on every machine. All gameplay settings are global so
 * server/mission values remain authoritative in multiplayer.
 * Parameters: none
 * Returns: nothing
 */
if (missionNamespace getVariable ["FCash_settingsRegistered", false]) exitWith {};
missionNamespace setVariable ["FCash_settingsRegistered", true];

private _readConfig = {
    params ["_name", "_fallback"];
    private _read = {
        params ["_cfg", "_default"];
        if (isNull _cfg) exitWith {_default};
        if (isNumber _cfg) exitWith {getNumber _cfg};
        if (isText _cfg) exitWith {getText _cfg};
        if (isArray _cfg) exitWith {getArray _cfg};
        _default
    };
    private _addon = [configFile >> "CfgFCash" >> _name, _fallback] call _read;
    [missionConfigFile >> "CfgFCash" >> _name, _addon] call _read
};

private _category = "Fuhrizen's Cash";
private _global = true;

[
    "FCash_setting_startWallet", "SLIDER",
    ["Starting wallet cash", "Cash assigned when a Steam UID is first created in the authoritative FCash ledger."],
    [_category, "Starting Balances"],
    [0, 1000000, ["startWallet", 0] call _readConfig, 0],
    _global, {}, true
] call CBA_fnc_addSetting;

[
    "FCash_setting_startBank", "SLIDER",
    ["Starting personal-bank balance", "Bank balance assigned when a Steam UID is first created in the authoritative FCash ledger."],
    [_category, "Starting Balances"],
    [0, 10000000, ["startBank", 0] call _readConfig, 0],
    _global, {}, true
] call CBA_fnc_addSetting;

[
    "FCash_setting_loseWalletOnDeath", "CHECKBOX",
    ["Drop wallet cash on death", "Moves wallet cash into the corpse ledger so it can be looted. Disabled keeps the UID wallet intact."],
    [_category, "Cash"],
    ((["loseWalletOnDeath", 1] call _readConfig) == 1),
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_allowGive", "CHECKBOX",
    ["Allow giving cash", "Allows nearby players to hand wallet cash directly to another living player."],
    [_category, "Cash"],
    ((["allowGive", 1] call _readConfig) == 1),
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_allowTakeDead", "CHECKBOX",
    ["Allow looting dead players", "Allows wallet cash placed on a corpse to be taken by nearby players."],
    [_category, "Cash"],
    ((["allowTakeDead", 1] call _readConfig) == 1),
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_allowTakeCaptive", "CHECKBOX",
    ["Allow taking cash from captives", "Allows cash to be taken from living captive/surrendered players."],
    [_category, "Cash"],
    ((["allowTakeCaptive", 1] call _readConfig) == 1),
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_allowDirectSend", "CHECKBOX",
    ["Allow direct wallet send", "Enables direct wallet-to-wallet sending without physical handover when exposed by mission/UI integrations."],
    [_category, "Cash"],
    ((["allowDirectSend", 0] call _readConfig) == 1),
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_interactionDistance", "SLIDER",
    ["Cash interaction distance", "Maximum server-validated distance in metres for direct cash interactions."],
    [_category, "Cash"],
    [1, 10, ["interactionDistance", 3.5] call _readConfig, 1],
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_allowBankTransferAnySide", "CHECKBOX",
    ["Allow bank transfers across sides", "When disabled, personal-bank transfers are limited to players on the same side."],
    [_category, "Banking"],
    ((["allowBankTransferAnySide", 1] call _readConfig) == 1),
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_terminalDistance", "SLIDER",
    ["Bank terminal distance", "Maximum server-validated distance in metres from a configured/registered terminal."],
    [_category, "Banking"],
    [1, 20, ["terminalDistance", 5] call _readConfig, 1],
    _global
] call CBA_fnc_addSetting;

private _atmDefault = (["atmClasses", ["Land_Atm_01_F", "Land_Atm_02_F", "Land_ATM_01_malden_F", "Land_ATM_02_malden_F"]] call _readConfig) joinString ",";
[
    "FCash_setting_atmClasses", "EDITBOX",
    ["ATM object classes", "Comma-separated CfgVehicles class names that act as native FCash bank terminals. Custom objects can also be registered by Zeus or code."],
    [_category, "Banking"],
    _atmDefault,
    _global, {}, true
] call CBA_fnc_addSetting;

[
    "FCash_setting_sharedBankEnabled", "CHECKBOX",
    ["Enable shared banking", "Enables creation and use of shared bank accounts."],
    [_category, "Shared Banking"],
    ((["sharedBankEnabled", 1] call _readConfig) == 1),
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_sharedCreateFee", "SLIDER",
    ["Shared account creation fee", "Amount removed from the creator's personal bank for normal player-created shared accounts."],
    [_category, "Shared Banking"],
    [0, 1000000, ["sharedCreateFee", 0] call _readConfig, 0],
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_sharedMaxOwned", "SLIDER",
    ["Maximum owned shared accounts", "Maximum number of shared accounts one UID can own through normal player creation."],
    [_category, "Shared Banking"],
    [1, 25, ["sharedMaxOwned", 5] call _readConfig, 0],
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_sharedMaxMembers", "SLIDER",
    ["Maximum shared members", "Maximum members (including owner) in one shared account."],
    [_category, "Shared Banking"],
    [2, 128, ["sharedMaxMembers", 32] call _readConfig, 0],
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_sharedNameMin", "SLIDER",
    ["Minimum shared-account name length", "Minimum accepted shared-account name length."],
    [_category, "Shared Banking"],
    [1, 16, ["sharedNameMin", 3] call _readConfig, 0],
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_sharedNameMax", "SLIDER",
    ["Maximum shared-account name length", "Maximum accepted shared-account name length."],
    [_category, "Shared Banking"],
    [3, 64, ["sharedNameMax", 32] call _readConfig, 0],
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_sharedLogLimit", "SLIDER",
    ["Shared-bank log length", "Maximum activity/transaction records retained per shared bank."],
    [_category, "Shared Banking"],
    [10, 1000, ["sharedLogLimit", 150] call _readConfig, 0],
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_zeusModulesEnabled", "CHECKBOX",
    ["Enable Zeus administration modules", "Allows assigned Zeus curators to use the Fuhrizen's Cash module suite. Server validation is still enforced."],
    [_category, "Zeus"],
    ((["zeusModulesEnabled", 1] call _readConfig) == 1),
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_zeusNotifyAffectedPlayers", "CHECKBOX",
    ["Notify players of Zeus balance changes", "Shows an FCash notice to a player when Zeus changes their wallet or personal-bank balance."],
    [_category, "Zeus"],
    ((["zeusNotifyAffectedPlayers", 1] call _readConfig) == 1),
    _global
] call CBA_fnc_addSetting;

[
    "FCash_setting_currencySymbol", "EDITBOX",
    ["Currency symbol / prefix", "Short prefix used when FCash formats currency values, for example $, GBP, EUR or Cr."],
    [_category, "Display"],
    ["currencySymbol", "$"] call _readConfig,
    _global
] call CBA_fnc_addSetting;
