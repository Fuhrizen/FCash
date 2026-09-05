/*
 * Formats an integer currency amount for UI.
 * Parameters: [amount <NUMBER>]
 * Returns: STRING
 */
params [["_amount", 0, [0]]];
private _symbol = ["currencySymbol", "$"] call FCash_fnc_getSetting;
format ["%1%2", _symbol, [round _amount] call BIS_fnc_numberText]
