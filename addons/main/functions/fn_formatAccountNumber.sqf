/*
 * Normalizes an FCash account number to an exact seven digit string.
 * Accepts a string or number and returns a normalized seven-digit account identifier.
 * Returns "" when the value cannot represent a seven-digit account number.
 */
params [["_value", "", ["", 0]]];

private _number = -1;
if (_value isEqualType 0) then {
    if (finite _value) then {_number = floor _value};
} else {
    private _text = trim _value;
    if (_text != "") then {
        private _parsed = parseNumber _text;
        if (finite _parsed) then {_number = floor _parsed};
    };
};

if (_number < 1000000 || {_number > 9999999}) exitWith {""};
private _digits = [];
{
    private _digit = floor (_number / _x) mod 10;
    _digits pushBack str _digit;
} forEach [1000000,100000,10000,1000,100,10,1];
_digits joinString ""
