/*
 * Animates the current FCash dialog out before closing it.
 * Parameters: [display <DISPLAY optional>]
 */
disableSerialization;
params [["_display", displayNull, [displayNull]]];
if (isNull _display) then {
    {
        private _candidate = findDisplay _x;
        if (!isNull _candidate) exitWith {_display = _candidate};
    } forEach [61000,61100,61200,61300,61400,61500];
};
if (isNull _display) exitWith {closeDialog 0};

[_display] spawn {
    disableSerialization;
    params ["_display"];
    private _offset = safeZoneW * 0.010;
    {
        private _pos = ctrlPosition _x;
        _x ctrlSetFade 1;
        _x ctrlSetPosition [(_pos select 0) + _offset, _pos select 1, _pos select 2, _pos select 3];
        _x ctrlCommit 0.10;
    } forEach allControls _display;
    uiSleep 0.105;
    if (!isNull _display) then {closeDialog 0};
};
