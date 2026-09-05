/*
 * Opens the full banking UI at a terminal.
 * Parameters: [terminal <OBJECT>]
 */
params ["_terminal"];
if (!hasInterface || {isNull _terminal}) exitWith {};
uiNamespace setVariable ["FCash_ui_terminal", _terminal];
uiNamespace setVariable ["FCash_ui_sharedSelected", ""];
createDialog "FCash_BankingDialog";
[] call FCash_fnc_requestSync;
