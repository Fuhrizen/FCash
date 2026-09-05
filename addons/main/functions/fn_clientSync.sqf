/* Remote target: owning client. Receives sanitized server snapshot. */
params ["_wallet", "_bank", ["_personalPin", ""], ["_shared", []], ["_invites", []], ["_recipients", []], ["_players", []]];
if (!hasInterface) exitWith {};

private _oldWallet = missionNamespace getVariable ["FCash_cache_wallet", 0];
private _oldBank = missionNamespace getVariable ["FCash_cache_bank", 0];
private _oldShared = missionNamespace getVariable ["FCash_cache_shared", []];
private _oldInvites = missionNamespace getVariable ["FCash_cache_invites", []];

missionNamespace setVariable ["FCash_cache_wallet", _wallet];
missionNamespace setVariable ["FCash_cache_bank", _bank];
missionNamespace setVariable ["FCash_cache_personalPin", _personalPin];
missionNamespace setVariable ["FCash_cache_shared", _shared];
missionNamespace setVariable ["FCash_cache_invites", _invites];
missionNamespace setVariable ["FCash_cache_recipients", _recipients];
missionNamespace setVariable ["FCash_cache_players", _players];

if (_oldWallet != _wallet) then {["balanceChanged", ["WALLET", _oldWallet, _wallet]] call FCash_fnc_emitEvent};
if (_oldBank != _bank) then {["balanceChanged", ["BANK", _oldBank, _bank]] call FCash_fnc_emitEvent};
if !(_oldShared isEqualTo _shared && {_oldInvites isEqualTo _invites}) then {
    ["sharedChanged", [_shared, _invites]] call FCash_fnc_emitEvent;
};
["snapshot", [_wallet, _bank, _personalPin, _shared, _invites, _recipients, _players]] call FCash_fnc_emitEvent;

if (!isNull (uiNamespace getVariable ["FCash_ui_bankDisplay", displayNull])) then {[] call FCash_fnc_bankingRefresh};
if (!isNull (uiNamespace getVariable ["FCash_ui_recipientDisplay", displayNull])) then {[] call FCash_fnc_recipientSearchRefresh};
