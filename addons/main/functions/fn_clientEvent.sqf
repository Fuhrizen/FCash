/* Remote target: clients only. */
params ["_event", ["_payload", []]];
[_event, _payload] call FCash_fnc_emitEvent;
