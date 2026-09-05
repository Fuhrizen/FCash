/*
 * Initializes FCash local state. Runs on every machine before mission init.
 * Parameters: none
 * Returns: nothing
 */
[] call FCash_fnc_registerSettings;

missionNamespace setVariable ["FCash_eventHandlers", createHashMap];
missionNamespace setVariable ["FCash_eventCounter", 0];
missionNamespace setVariable ["FCash_cache_wallet", 0];
missionNamespace setVariable ["FCash_cache_bank", 0];
missionNamespace setVariable ["FCash_cache_personalPin", ""];
missionNamespace setVariable ["FCash_cache_shared", []];
missionNamespace setVariable ["FCash_cache_invites", []];
missionNamespace setVariable ["FCash_cache_players", []];
missionNamespace setVariable ["FCash_cache_recipients", []];
