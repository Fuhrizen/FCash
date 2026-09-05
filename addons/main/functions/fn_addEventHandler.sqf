/*
 * Adds a local FCash custom event handler.
 * Parameters: [eventName <STRING>, code <CODE>]
 * Returns: numeric handler id, or -1 on invalid input
 */
params ["_event", "_code"];
if !(_event isEqualType "") exitWith {-1};
if !(_code isEqualType {}) exitWith {-1};

private _registry = missionNamespace getVariable ["FCash_eventHandlers", createHashMap];
private _id = (missionNamespace getVariable ["FCash_eventCounter", 0]) + 1;
missionNamespace setVariable ["FCash_eventCounter", _id];
private _handlers = _registry getOrDefault [_event, []];
_handlers pushBack [_id, _code];
_registry set [_event, _handlers];
missionNamespace setVariable ["FCash_eventHandlers", _registry];
_id
