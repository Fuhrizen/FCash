/*
 * Discovers map-baked ATM terrain objects near the local player.
 * Terrain objects often have no CfgVehicles identity, so class-level ACE actions
 * cannot attach to them. Matching ATMs are promoted server-side to the same
 * CfgVehicles class at the same transform, after which normal FCash/ACE handling applies.
 */
if (!hasInterface || {isNull player}) exitWith {};

private _classes = ["Land_Atm_01_F", "Land_Atm_02_F", "Land_ATM_01_malden_F", "Land_ATM_02_malden_F"];
private _models = [];
{
    private _cfgModel = toLower getText (configFile >> "CfgVehicles" >> _x >> "model");
    if (_cfgModel != "") then {
        private _parts = _cfgModel splitString "\\/";
        private _leaf = if (_parts isEqualTo []) then {_cfgModel} else {_parts select ((count _parts) - 1)};
        _models pushBack [_leaf, _x];
    };
} forEach _classes;
if (_models isEqualTo []) exitWith {};

private _seen = uiNamespace getVariable ["FCash_ui_terrainAtmSeen", createHashMap];
{
    private _terrain = _x;
    if (isObjectHidden _terrain) then {continue};
    private _info = getModelInfo _terrain;
    private _leaf = toLower (_info param [0, ""]);
    private _match = _models findIf {(_x select 0) == _leaf};
    if (_match < 0) then {continue};
    private _class = (_models select _match) select 1;

    // nearestTerrainObjects returns map-baked terrain objects rather than normal
    // mission entities. Promote every matching ATM model, even when typeOf happens
    // to expose a classname, so ACE always receives a normal networked target.
    private _pos = getPosATL _terrain;
    private _key = format ["%1:%2:%3", _class, round ((_pos select 0) * 10), round ((_pos select 1) * 10)];
    private _lastTry = _seen getOrDefault [_key, -1000];
    if ((diag_tickTime - _lastTry) < 10) then {continue};
    _seen set [_key, diag_tickTime];
    [_pos, _class, _leaf] remoteExecCall ["FCash_fnc_serverPromoteTerrainATM", 2];
} forEach nearestTerrainObjects [player, [], 12, false, true];
uiNamespace setVariable ["FCash_ui_terrainAtmSeen", _seen];
