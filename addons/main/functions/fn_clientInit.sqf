/*
 * Installs FCash ACE interactions on the local client and requests initial state.
 * Parameters: none
 */
if (!hasInterface) exitWith {};
if (missionNamespace getVariable ["FCash_clientInitialized", false]) exitWith {};
missionNamespace setVariable ["FCash_clientInitialized", true];

private _walletAction = [
    "FCash_Wallet", "Check wallet", "\A3\ui_f\data\gui\Rsc\RscDisplayArsenal\cargoMisc_ca.paa",
    {[] call FCash_fnc_showWalletHud}, {alive _player}
] call ace_interact_menu_fnc_createAction;
["CAManBase", 1, ["ACE_SelfActions"], _walletAction, true] call ace_interact_menu_fnc_addActionToClass;

private _giveAction = [
    "FCash_Give", "Pay cash", "\A3\ui_f\data\gui\Rsc\RscDisplayArsenal\cargoPut_ca.paa",
    {[_target, "WALLET_GIVE"] call FCash_fnc_openAmountDialog},
    {alive _player && {alive _target} && {_target != _player} && {(["allowGive", 1] call FCash_fnc_getSetting) == 1}}
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, ["ACE_MainActions"], _giveAction, true] call ace_interact_menu_fnc_addActionToClass;

private _takeAction = [
    "FCash_Take", "Take cash", "",
    {[_target, "WALLET_TAKE"] call FCash_fnc_openAmountDialog},
    {
        private _available = if (!alive _target && {(_target getVariable ["FCash_deathCashId", ""]) != ""}) then {
            _target getVariable ["FCash_deathCashBalance", 0]
        } else {
            _target getVariable ["FCash_wallet", 0]
        };
        _target != _player && {_available > 0} && {
            (!alive _target && {(["allowTakeDead", 1] call FCash_fnc_getSetting) == 1}) ||
            (alive _target && {captive _target} && {(["allowTakeCaptive", 1] call FCash_fnc_getSetting) == 1})
        }
    },
    {}, [], {[0,0,0]}, 2, [false,false,false,false,false],
    {
        params ["_target", "_player", "_actionParams", "_actionData"];
        private _available = if (!alive _target && {(_target getVariable ["FCash_deathCashId", ""]) != ""}) then {
            _target getVariable ["FCash_deathCashBalance", 0]
        } else {
            _target getVariable ["FCash_wallet", 0]
        };
        _actionData set [1, format ["Take cash (%1)", [_available] call FCash_fnc_formatMoney]];
    }
] call ace_interact_menu_fnc_createAction;
["CAManBase", 0, ["ACE_MainActions"], _takeAction, true] call ace_interact_menu_fnc_addActionToClass;

private _nativeAtmClasses = ["Land_Atm_01_F", "Land_Atm_02_F", "Land_ATM_01_malden_F", "Land_ATM_02_malden_F"];
private _atmClasses = +_nativeAtmClasses;
{_atmClasses pushBackUnique _x} forEach (["atmClasses", _nativeAtmClasses] call FCash_fnc_getSetting);

// ATM access is installed at class level. Unlike object-local installation this also
// covers terrain-library ATMs and any matching ATM spawned after mission start.
{
    private _class = _x;
    if (isClass (configFile >> "CfgVehicles" >> _class)) then {
        private _action = [
            format ["FCash_OpenBanking_%1", _class], "Open banking", "\A3\ui_f\data\gui\Rsc\RscDisplayArsenal\cargoMisc_ca.paa",
            {[_target] call FCash_fnc_openBanking},
            {alive _player}
        ] call ace_interact_menu_fnc_createAction;
        [_class, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToClass;
    };
} forEach _atmClasses;

// Map-baked terrain ATMs are not ordinary mission objects and can have no
// CfgVehicles classname at all. Scan only a small radius every few seconds;
// matching ATM models are promoted by the server into their normal ATM class.
[] call FCash_fnc_clientScanTerrainATMs;
[{[] call FCash_fnc_clientScanTerrainATMs}, 3, []] call CBA_fnc_addPerFrameHandler;

// Repair/install runtime actions for objects that were registered before this client
// initialized (JIP, hosted server and mission-script registrations).
{
    private _object = _x;
    if (_object getVariable ["FCash_isTerminal", false]) then {
        [_object, "TERMINAL"] call FCash_fnc_clientInstallObjectActions;
    };
    if (_object getVariable ["FCash_isStorage", false]) then {
        [_object, "STORAGE"] call FCash_fnc_clientInstallObjectActions;
    };
} forEach (allMissionObjects "All");

[] call FCash_fnc_requestSync;
