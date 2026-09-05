/*
 * Starts server and client runtime components.
 * Parameters: none
 * Returns: nothing
 */
if (isServer) then {
    [] call FCash_fnc_serverInit;
};

if (hasInterface) then {
    [] spawn {
        waitUntil { !isNull player && {getPlayerUID player != ""} };
        [] call FCash_fnc_clientInit;
    };
};
