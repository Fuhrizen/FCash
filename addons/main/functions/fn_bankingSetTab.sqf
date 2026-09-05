/* Switches visible banking panel. Parameters: [PERSONAL|SHARED|INVITES] */
params ["_tab"];
disableSerialization;
private _display = uiNamespace getVariable ["FCash_ui_bankDisplay", displayNull];
if (isNull _display) exitWith {};
uiNamespace setVariable ["FCash_ui_tab", _tab];

private _personal = [61120,61121,61122,61131,61123,61124,61125,61126,61127,61128,61129,61130];
private _shared = [61140,61141,61142,61143,61144,61145,61146,61147,61148,61149,61150,61151,61152,61153,61154,61156,61157,61158,61159,61164];
private _invites = [61160,61161,61162,61163];

// The active tab is disabled intentionally. FCash_RscTabButton uses a steady
// olive disabled background, which gives a persistent selected state without
// the normal RscButton hover/focus flash.
{
    _x params ["_name", "_idc"];
    private _ctrl = _display displayCtrl _idc;
    _ctrl ctrlEnable (_name != _tab);
} forEach [["PERSONAL",61110],["SHARED",61111],["INVITES",61112]];
{(_display displayCtrl _x) ctrlShow (_tab == "PERSONAL")} forEach _personal;
{(_display displayCtrl _x) ctrlShow (_tab == "SHARED")} forEach _shared;
{(_display displayCtrl _x) ctrlShow (_tab == "INVITES")} forEach _invites;
[] call FCash_fnc_bankingRefresh;
