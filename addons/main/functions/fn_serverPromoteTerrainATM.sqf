/*
 * Converts one nearby map-baked ATM terrain object into a networked ATM object.
 * Called by clients only after local model detection. The server validates caller
 * distance, class and model before changing terrain state.
 */
params [
    ["_position", [], [[]], 3],
    ["_class", "", [""]],
    ["_modelLeaf", "", [""]]
];
if (!isServer || {_position isEqualTo []}) exitWith {false};

private _allowed = ["Land_Atm_01_F", "Land_Atm_02_F", "Land_ATM_01_malden_F", "Land_ATM_02_malden_F"];
if !(_class in _allowed) exitWith {false};

private _caller = [remoteExecutedOwner] call FCash_fnc_serverFindCaller;
if (isNull _caller || {_caller distance2D _position > 25}) exitWith {false};

private _cfgModel = toLower getText (configFile >> "CfgVehicles" >> _class >> "model");
private _parts = _cfgModel splitString "\\/";
private _expectedLeaf = if (_parts isEqualTo []) then {_cfgModel} else {_parts select ((count _parts) - 1)};
if (_expectedLeaf == "" || {toLower _modelLeaf != _expectedLeaf}) exitWith {false};

private _promoted = missionNamespace getVariable ["FCash_server_promotedTerrainATMs", createHashMap];
private _key = format ["%1:%2:%3", _class, round ((_position select 0) * 10), round ((_position select 1) * 10)];
if (_promoted getOrDefault [_key, false]) exitWith {true};

private _terrain = objNull;
{
    private _info = getModelInfo _x;
    if (toLower (_info param [0, ""]) == _expectedLeaf && {_x distance2D _position < 1.5}) exitWith {
        _terrain = _x;
    };
} forEach nearestTerrainObjects [_position, [], 2.5, false, true];

if (isNull _terrain) exitWith {false};
private _posATL = getPosATL _terrain;
if ((_posATL select 2) < 0) then {_posATL set [2, 0]};
private _dirUp = [vectorDir _terrain, vectorUp _terrain];

hideObjectGlobal _terrain;
_terrain setDamage [1, false];

private _atm = createVehicle [_class, [0,0,0], [], 0, "CAN_COLLIDE"];
_atm setVectorDirAndUp _dirUp;
_atm setPosATL _posATL;
_atm setVariable ["FCash_promotedTerrainATM", true, true];

_promoted set [_key, true];
missionNamespace setVariable ["FCash_server_promotedTerrainATMs", _promoted];
true
