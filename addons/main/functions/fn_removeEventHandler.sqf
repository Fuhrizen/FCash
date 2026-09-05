/*
 * Removes a local FCash custom event handler.
 * Parameters: [eventName <STRING>, handlerId <NUMBER>]
 * Returns: BOOL
 */
params ["_event", "_id"];
private _registry = missionNamespace getVariable ["FCash_eventHandlers", createHashMap];
private _handlers = _registry getOrDefault [_event, []];
private _index = _handlers findIf {(_x select 0) isEqualTo _id};
if (_index < 0) exitWith {false};
_handlers deleteAt _index;
_registry set [_event, _handlers];
missionNamespace setVariable ["FCash_eventHandlers", _registry];
true
