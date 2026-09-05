/*
 * Emits a local FCash event. Handler code receives the event payload as _this.
 * Parameters: [eventName <STRING>, payload <ANY>]
 * Returns: number of handlers invoked
 */
params ["_event", ["_payload", []]];
private _registry = missionNamespace getVariable ["FCash_eventHandlers", createHashMap];
private _handlers = +(_registry getOrDefault [_event, []]);
{
    _payload call (_x select 1);
} forEach _handlers;
count _handlers
