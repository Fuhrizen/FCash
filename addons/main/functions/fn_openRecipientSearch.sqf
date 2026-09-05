/* Opens the filterable bank recipient selector. Parameters: [PERSONAL|SHARED] */
params [["_source", "PERSONAL", [""]]];
if (!hasInterface) exitWith {};
uiNamespace setVariable ["FCash_ui_recipientSource", toUpper _source];
createDialog "FCash_RecipientSearchDialog";
