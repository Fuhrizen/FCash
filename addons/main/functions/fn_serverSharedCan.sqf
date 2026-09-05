/*
 * Role permission helper for shared accounts.
 * Parameters: [role <STRING>, permission <STRING>]
 * Returns: BOOL
 */
params ["_role", "_permission"];
private _permissions = switch (_role) do {
    case "OWNER": { ["VIEW", "DEPOSIT", "WITHDRAW", "TRANSFER", "INVITE", "SET_ROLE", "REMOVE"] };
    case "MANAGER": { ["VIEW", "DEPOSIT", "WITHDRAW", "TRANSFER", "INVITE"] };
    case "MEMBER": { ["VIEW", "DEPOSIT", "WITHDRAW", "TRANSFER"] };
    case "VIEWER": { ["VIEW"] };
    default { [] };
};
_permission in _permissions
