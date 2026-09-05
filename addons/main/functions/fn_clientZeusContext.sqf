/* Opens the compact, dynamically adapting curator funds editor. */
params [
    ["_operation", "", [""]],
    ["_target", objNull, [objNull]],
    ["_targetInfo", [], [[]]],
    ["_shared", [], [[]]]
];
if (!hasInterface || {_operation == ""} || {isNull (getAssignedCuratorLogic player)}) exitWith {};

// A dedicated FCash dialog is used even when ZEN is loaded. It deliberately
// follows vanilla/ZEN proportions, while allowing controls to show/hide live
// when the curator changes the selected operation.
uiNamespace setVariable ["FCash_ui_zeusContext", [_operation, _target, _targetInfo, _shared]];
createDialog "FCash_ZeusModuleDialog";
