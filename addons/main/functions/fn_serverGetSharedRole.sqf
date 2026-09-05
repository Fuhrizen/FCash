/*
 * Gets a UID's role in a shared account.
 * Parameters: [account <HASHMAP>, uid <STRING>]
 * Returns: STRING: OWNER/MANAGER/MEMBER/VIEWER/NONE
 */
params ["_account", "_uid"];
if !(_account isEqualType createHashMap) exitWith {"NONE"};
if ((_account getOrDefault ["owner", ""]) isEqualTo _uid) exitWith {"OWNER"};
private _members = _account getOrDefault ["members", createHashMap];
_members getOrDefault [_uid, "NONE"]
