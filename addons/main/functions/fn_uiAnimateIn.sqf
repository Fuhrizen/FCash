/*
 * Applies the common FCash vanilla-friendly slide/fade animation to a display.
 * Parameters: [display <DISPLAY>]
 */
disableSerialization;
params ["_display"];
if (isNull _display) exitWith {};

private _offset = safeZoneW * 0.012;
{
    private _ctrl = _x;
    private _pos = ctrlPosition _ctrl;
    _ctrl ctrlSetFade 1;
    _ctrl ctrlSetPosition [(_pos select 0) + _offset, _pos select 1, _pos select 2, _pos select 3];
    _ctrl ctrlCommit 0;
    _ctrl ctrlSetFade 0;
    _ctrl ctrlSetPosition _pos;
    _ctrl ctrlCommit 0.13;
} forEach allControls _display;
