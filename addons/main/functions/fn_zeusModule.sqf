/* Entry point for the compact Fuhrizen's Cash Zeus module set. */
params [["_logic", objNull, [objNull]]];
if (isNull _logic) exitWith {};

private _operation = getText (configOf _logic >> "FCash_operation");
private _target = attachedTo _logic;
deleteVehicle _logic;

if (_operation == "") exitWith {};
if ((["zeusModulesEnabled", 1] call FCash_fnc_getSetting) != 1) exitWith {
    ["Cash administration modules are disabled.", "ERROR"] call FCash_fnc_clientNotify;
};

if (_operation in ["TERMINAL_SET", "TERMINAL_REMOVE"]) then {
    ["EXECUTE", [_operation, _target, "SET", 0, "", ""]] remoteExecCall ["FCash_fnc_serverZeusRequest", 2];
} else {
    ["OPEN", [_operation, _target]] remoteExecCall ["FCash_fnc_serverZeusRequest", 2];
};
