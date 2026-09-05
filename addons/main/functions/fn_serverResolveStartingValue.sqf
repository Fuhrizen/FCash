/*
 * Resolves a 3DEN starting-value expression on the server.
 * Parameters: [entity <OBJECT>, raw <STRING|NUMBER>, fallback <NUMBER>, internalToken <STRING optional>]
 * A string wrapped in braces is compiled and called with [_entity] as _this.
 * Returns a non-negative rounded number.
 */
params ["_entity", "_raw", ["_fallback", 0], ["_token", ""]];
if (isRemoteExecuted && {_token != missionNamespace getVariable ["FCash_server_internalToken", "__invalid__"]}) exitWith {round _fallback max 0};
if (!isServer || {isNull _entity}) exitWith {round _fallback max 0};

private _result = _fallback;
if (_raw isEqualType 0) then {
    if (finite _raw) then {_result = _raw};
} else {
    if (_raw isEqualType "") then {
        private _text = trim _raw;
        if (_text != "") then {
            if ((count _text) >= 2 && {(_text select [0,1]) == "{"} && {(_text select [(count _text) - 1, 1]) == "}"}) then {
                private _body = _text select [1, (count _text) - 2];
                private _fn = compile _body;
                private _value = [_entity] call _fn;
                if (_value isEqualType 0 && {finite _value}) then {_result = _value};
            } else {
                private _value = parseNumber _text;
                if (finite _value) then {_result = _value};
            };
        };
    };
};
round _result max 0
