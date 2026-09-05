/*
 * Opens a compact amount-entry dialog for physical cash/storage actions.
 * Parameters: [target <OBJECT>, mode <STRING>]
 */
params ["_target", "_mode"];
if (!hasInterface || {isNull _target}) exitWith {};

uiNamespace setVariable ["FCash_ui_amountTarget", _target];
uiNamespace setVariable ["FCash_ui_amountMode", _mode];
createDialog "FCash_AmountDialog";

disableSerialization;
private _display = findDisplay 61000;
if (isNull _display) exitWith {};
private _title = _display displayCtrl 61001;
private _balance = _display displayCtrl 61002;

private _titleText = switch (_mode) do {
    case "WALLET_GIVE": {format ["Pay cash - %1", name _target]};
    case "WALLET_TAKE": {format ["Take cash - %1", name _target]};
    case "STORAGE_DEPOSIT": {"Stash deposit"};
    case "STORAGE_WITHDRAW": {"Stash withdrawal"};
    case "DIRECT_SEND": {format ["Pay cash - %1", name _target]};
    default {"Wallet"};
};
_title ctrlSetText _titleText;
private _balanceText = switch (_mode) do {
    case "WALLET_TAKE": {
        private _available = if (!alive _target && {(_target getVariable ["FCash_deathCashId", ""]) != ""}) then {
            _target getVariable ["FCash_deathCashBalance", 0]
        } else {
            _target getVariable ["FCash_wallet", 0]
        };
        format ["Available to take: %1", [_available] call FCash_fnc_formatMoney]
    };
    case "STORAGE_WITHDRAW": {
        format ["Stash available: %1", [_target getVariable ["FCash_storageBalance", 0]] call FCash_fnc_formatMoney]
    };
    default {
        format ["Wallet available: %1", [missionNamespace getVariable ["FCash_cache_wallet", 0]] call FCash_fnc_formatMoney]
    };
};
_balance ctrlSetText _balanceText;
