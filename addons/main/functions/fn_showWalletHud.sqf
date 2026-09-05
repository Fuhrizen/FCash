/* Shows a small vanilla-friendly wallet tab that slides in from the right. */
if (!hasInterface) exitWith {};
private _wallet = missionNamespace getVariable ["FCash_cache_wallet", 0];
private _money = [_wallet] call FCash_fnc_formatMoney;

[_money] spawn {
    disableSerialization;
    params ["_money"];
    private _display = findDisplay 46;
    if (isNull _display) exitWith {};
    private _old = uiNamespace getVariable ["FCash_ui_walletHud", []];
    {if (!isNull _x) then {ctrlDelete _x}} forEach _old;

    private _w = safeZoneW * 0.115;
    private _h = safeZoneH * 0.046;
    private _y = safeZoneY + safeZoneH * 0.82;
    private _targetX = safeZoneX + safeZoneW * 0.865;
    private _startX = safeZoneX + safeZoneW + _w;
    private _bg = _display ctrlCreate ["RscText", -1];
    private _accent = _display ctrlCreate ["RscText", -1];
    private _text = _display ctrlCreate ["RscStructuredText", -1];
    uiNamespace setVariable ["FCash_ui_walletHud", [_bg,_accent,_text]];

    _bg ctrlSetPosition [_startX, _y, _w, _h];
    _bg ctrlSetBackgroundColor [0,0,0,0.72];
    _accent ctrlSetPosition [_startX, _y, safeZoneW * 0.0022, _h];
    _accent ctrlSetBackgroundColor [0.78,0.63,0.18,0.95];
    _text ctrlSetPosition [_startX + safeZoneW * 0.008, _y + safeZoneH * 0.0035, _w - safeZoneW * 0.012, _h - safeZoneH * 0.004];
    _text ctrlSetBackgroundColor [0,0,0,0];
    _text ctrlSetStructuredText parseText format ["<t font='PuristaMedium' size='0.68' color='#BFA450'>Wallet</t><br/><t font='PuristaMedium' size='0.94' color='#E8E3D4'>%1</t>", _money];
    {_x ctrlCommit 0} forEach [_bg,_accent,_text];

    _bg ctrlSetPosition [_targetX, _y, _w, _h];
    _accent ctrlSetPosition [_targetX, _y, safeZoneW * 0.0022, _h];
    _text ctrlSetPosition [_targetX + safeZoneW * 0.008, _y + safeZoneH * 0.0035, _w - safeZoneW * 0.012, _h - safeZoneH * 0.004];
    {_x ctrlCommit 0.14} forEach [_bg,_accent,_text];
    uiSleep 1.25;
    {
        if (!isNull _x) then {
            private _pos = ctrlPosition _x;
            _x ctrlSetFade 1;
            _x ctrlSetPosition [(_pos select 0) + safeZoneW * 0.012, _pos select 1, _pos select 2, _pos select 3];
            _x ctrlCommit 0.18;
        };
    } forEach [_bg,_accent,_text];
    uiSleep 0.2;
    {if (!isNull _x) then {ctrlDelete _x}} forEach [_bg,_accent,_text];
};
[] call FCash_fnc_requestSync;
