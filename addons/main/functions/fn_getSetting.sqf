/*
 * Reads a Fuhrizen's Cash setting.
 * Precedence: CBA Addon Options -> mission CfgFCash -> addon CfgFCash -> supplied default.
 * Parameters: [name <STRING>, default <ANY>]
 * Returns: setting value or default
 */
params ["_name", "_default"];

private _settingVar = format ["FCash_setting_%1", _name];
if !(isNil {missionNamespace getVariable _settingVar}) exitWith {
    private _cbaValue = missionNamespace getVariable _settingVar;
    if (_name isEqualTo "atmClasses" && {_cbaValue isEqualType ""}) then {
        private _classes = _cbaValue splitString ",; \t\r\n";
        _classes select {_x != ""}
    } else {
        if (_cbaValue isEqualType true) then {[0, 1] select _cbaValue} else {_cbaValue}
    }
};

private _read = {
    params ["_cfg", "_fallback"];
    if (isNull _cfg) exitWith {_fallback};
    if (isNumber _cfg) exitWith {getNumber _cfg};
    if (isText _cfg) exitWith {getText _cfg};
    if (isArray _cfg) exitWith {getArray _cfg};
    _fallback
};

private _addonValue = [configFile >> "CfgFCash" >> _name, _default] call _read;
[missionConfigFile >> "CfgFCash" >> _name, _addonValue] call _read
