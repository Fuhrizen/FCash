/*
 * Returns a copy of the bounded server audit log. Server only.
 * Parameters: none
 * Returns: ARRAY
 */
if (isRemoteExecuted) exitWith {[]};
if (!isServer) exitWith {[]};
+(missionNamespace getVariable ["FCash_server_audit", []])
