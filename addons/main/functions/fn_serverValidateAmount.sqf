/*
 * Validates client supplied currency input.
 * Parameters: [amount <ANY>]
 * Returns: [valid <BOOL>, normalizedAmount <NUMBER>, reason <STRING>]
 */
params ["_amount"];
if !(_amount isEqualType 0) exitWith {[false, 0, "Amount is not numeric."]};
if !(finite _amount) exitWith {[false, 0, "Amount is not finite."]};

private _value = round _amount;
private _max = round (["maxTransaction", 100000000] call FCash_fnc_getSetting);
if (_value <= 0) exitWith {[false, 0, "Amount must be greater than zero."]};
if (_value > _max) exitWith {[false, 0, "Amount exceeds the configured transaction limit."]};
[true, _value, ""]
