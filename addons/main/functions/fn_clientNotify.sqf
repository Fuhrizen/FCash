/*
 * Displays a short notification. Curator mode uses Zeus feedback immediately;
 * normal gameplay uses the same slim slide-in visual language as the wallet tab.
 */
params ["_message", ["_kind", "INFO"]];
if (!hasInterface) exitWith {};
private _safeMessage = toString ((toArray _message) apply {[_x, 63] select (_x in [60,62])});
private _kindUpper = toUpper _kind;

if (!isNull (findDisplay 312)) exitWith {
    private _prefix = ["", "Warning: "] select (_kindUpper == "ERROR");
    private _curatorMessage = _prefix + _safeMessage;
    if (!isNil "zen_common_fnc_showMessage") then {[_curatorMessage] call zen_common_fnc_showMessage} else {[objNull, _curatorMessage] call BIS_fnc_showCuratorFeedbackMessage};
};

[_safeMessage, _kindUpper] spawn {
    disableSerialization;
    params ["_safeMessage", "_kindUpper"];
    private _display = findDisplay 46;
    if (isNull _display) exitWith {};
    private _old = uiNamespace getVariable ["FCash_ui_noticeCtrls", []];
    {if (!isNull _x) then {ctrlDelete _x}} forEach _old;

    private _accentColor = switch (_kindUpper) do {
        case "SUCCESS": {[0.43,0.58,0.25,1]};
        case "ERROR": {[0.78,0.45,0.14,1]};
        default {[0.78,0.63,0.18,1]};
    };
    private _headerHex = switch (_kindUpper) do {case "SUCCESS": {"#7FA853"}; case "ERROR": {"#C77A2B"}; default {"#C8A040"}};
    private _header = switch (_kindUpper) do {case "ERROR": {"Warning"}; case "SUCCESS": {"Done"}; default {"Notice"}};

    private _w = safeZoneW * 0.225;
    private _h = safeZoneH * 0.062;
    private _targetX = safeZoneX + safeZoneW * 0.745;
    private _startX = safeZoneX + safeZoneW + _w;
    private _y = safeZoneY + safeZoneH * 0.865;
    private _bg = _display ctrlCreate ["RscText", -1];
    private _accent = _display ctrlCreate ["RscText", -1];
    private _text = _display ctrlCreate ["RscStructuredText", -1];
    uiNamespace setVariable ["FCash_ui_noticeCtrls", [_bg,_accent,_text]];

    _bg ctrlSetPosition [_startX, _y, _w, _h];
    _bg ctrlSetBackgroundColor [0,0,0,0.84];
    _accent ctrlSetPosition [_startX, _y, safeZoneW * 0.0026, _h];
    _accent ctrlSetBackgroundColor _accentColor;
    _text ctrlSetPosition [_startX + safeZoneW * 0.009, _y + safeZoneH * 0.0045, _w - safeZoneW * 0.014, _h - safeZoneH * 0.006];
    _text ctrlSetBackgroundColor [0,0,0,0];
    _text ctrlSetStructuredText parseText format ["<t font='PuristaMedium' size='0.70' color='%1'>%2</t><br/><t font='PuristaMedium' size='0.80' color='#E8E3D4'>%3</t>", _headerHex, _header, _safeMessage];
    {_x ctrlCommit 0} forEach [_bg,_accent,_text];

    _bg ctrlSetPosition [_targetX, _y, _w, _h];
    _accent ctrlSetPosition [_targetX, _y, safeZoneW * 0.0026, _h];
    _text ctrlSetPosition [_targetX + safeZoneW * 0.009, _y + safeZoneH * 0.0045, _w - safeZoneW * 0.014, _h - safeZoneH * 0.006];
    {_x ctrlCommit 0.14} forEach [_bg,_accent,_text];
    uiSleep 2.0;
    {
        if (!isNull _x) then {
            private _pos = ctrlPosition _x;
            _x ctrlSetFade 1;
            _x ctrlSetPosition [(_pos select 0) + safeZoneW * 0.012, _pos select 1, _pos select 2, _pos select 3];
            _x ctrlCommit 0.2;
        };
    } forEach [_bg,_accent,_text];
    uiSleep 0.22;
    {if (!isNull _x) then {ctrlDelete _x}} forEach [_bg,_accent,_text];
};
