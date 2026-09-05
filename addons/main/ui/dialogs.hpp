#define FCASH_IDD_AMOUNT 61000
#define FCASH_IDD_BANK 61100
#define FCASH_IDD_CREATE 61200
#define FCASH_IDD_ZEUS 61300
#define FCASH_IDD_RECIPIENT 61400
#define FCASH_IDD_LOG 61500

class FCash_AmountDialog {
    idd = FCASH_IDD_AMOUNT;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "uiNamespace setVariable ['FCash_ui_amountDisplay', _this select 0]; [_this select 0] call FCash_fnc_uiAnimateIn";
    onUnload = "uiNamespace setVariable ['FCash_ui_amountDisplay', displayNull]";
    class controlsBackground {
        class Backdrop: FCash_RscText { x = "safeZoneX + safeZoneW * 0.765"; y = "safeZoneY + safeZoneH * 0.365"; w = "safeZoneW * 0.19"; h = "safeZoneH * 0.205"; colorBackground[] = {0,0,0,0.82}; };
        class Accent: FCash_RscText { x = "safeZoneX + safeZoneW * 0.765"; y = "safeZoneY + safeZoneH * 0.365"; w = "safeZoneW * 0.0025"; h = "safeZoneH * 0.205"; colorBackground[] = {0.78,0.63,0.18,0.95}; };
    };
    class controls {
        class Title: FCash_RscText { idc = 61001; text = "Wallet"; x = "safeZoneX + safeZoneW * 0.778"; y = "safeZoneY + safeZoneH * 0.383"; w = "safeZoneW * 0.16"; h = "safeZoneH * 0.032"; sizeEx = 0.032; colorText[] = {0.82,0.69,0.30,1}; };
        class Balance: FCash_RscText { idc = 61002; text = "Available"; x = "safeZoneX + safeZoneW * 0.778"; y = "safeZoneY + safeZoneH * 0.422"; w = "safeZoneW * 0.16"; h = "safeZoneH * 0.027"; sizeEx = 0.025; colorText[] = {0.63,0.64,0.61,1}; };
        class Amount: FCash_RscEdit { idc = 61003; text = "0"; x = "safeZoneX + safeZoneW * 0.778"; y = "safeZoneY + safeZoneH * 0.463"; w = "safeZoneW * 0.16"; h = "safeZoneH * 0.034"; };
        class Cancel: FCash_RscButton { text = "Cancel"; action = "[findDisplay 61000] call FCash_fnc_uiCloseDialog"; x = "safeZoneX + safeZoneW * 0.778"; y = "safeZoneY + safeZoneH * 0.516"; w = "safeZoneW * 0.074"; h = "safeZoneH * 0.031"; };
        class Confirm: FCash_RscButtonAccent { text = "Apply"; action = "[] call FCash_fnc_submitAmount"; x = "safeZoneX + safeZoneW * 0.864"; y = "safeZoneY + safeZoneH * 0.516"; w = "safeZoneW * 0.074"; h = "safeZoneH * 0.031"; };
    };
};

class FCash_BankingDialog {
    idd = FCASH_IDD_BANK;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "_this call FCash_fnc_bankingOnLoad";
    onUnload = "uiNamespace setVariable ['FCash_ui_bankDisplay', displayNull]";
    class controlsBackground {
        class Backdrop: FCash_RscText { x = "safeZoneX + safeZoneW * 0.26"; y = "safeZoneY + safeZoneH * 0.20"; w = "safeZoneW * 0.48"; h = "safeZoneH * 0.60"; colorBackground[] = {0,0,0,0.90}; };
        class Header: FCash_RscText { x = "safeZoneX + safeZoneW * 0.26"; y = "safeZoneY + safeZoneH * 0.20"; w = "safeZoneW * 0.48"; h = "safeZoneH * 0.038"; colorBackground[] = {0.11,0.11,0.10,0.98}; };
        class Accent: FCash_RscText { x = "safeZoneX + safeZoneW * 0.26"; y = "safeZoneY + safeZoneH * 0.20"; w = "safeZoneW * 0.0025"; h = "safeZoneH * 0.038"; colorBackground[] = {0.78,0.63,0.18,1}; };
    };
    class controls {
        class Brand: FCash_RscText { text = "Banking"; x = "safeZoneX + safeZoneW * 0.273"; y = "safeZoneY + safeZoneH * 0.205"; w = "safeZoneW * 0.15"; h = "safeZoneH * 0.028"; sizeEx = 0.030; };
        class Close: FCash_RscButton { text = "X"; action = "[findDisplay 61100] call FCash_fnc_uiCloseDialog"; x = "safeZoneX + safeZoneW * 0.708"; y = "safeZoneY + safeZoneH * 0.204"; w = "safeZoneW * 0.022"; h = "safeZoneH * 0.028"; };
        class PersonalTab: FCash_RscTabButton { idc = 61110; text = "Personal"; action = "['PERSONAL'] call FCash_fnc_bankingSetTab"; x = "safeZoneX + safeZoneW * 0.273"; y = "safeZoneY + safeZoneH * 0.251"; w = "safeZoneW * 0.085"; h = "safeZoneH * 0.032"; };
        class SharedTab: FCash_RscTabButton { idc = 61111; text = "Shared"; action = "['SHARED'] call FCash_fnc_bankingSetTab"; x = "safeZoneX + safeZoneW * 0.363"; y = "safeZoneY + safeZoneH * 0.251"; w = "safeZoneW * 0.085"; h = "safeZoneH * 0.032"; };
        class InvitesTab: FCash_RscTabButton { idc = 61112; text = "Invites"; action = "['INVITES'] call FCash_fnc_bankingSetTab"; x = "safeZoneX + safeZoneW * 0.453"; y = "safeZoneY + safeZoneH * 0.251"; w = "safeZoneW * 0.085"; h = "safeZoneH * 0.032"; };

        // PERSONAL
        class PersonalTitle: FCash_RscText { idc = 61120; text = "Personal bank"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.305"; w = "safeZoneW * 0.16"; h = "safeZoneH * 0.030"; colorText[] = {0.82,0.69,0.30,1}; };
        class WalletBalance: FCash_RscStructuredText { idc = 61121; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.345"; w = "safeZoneW * 0.20"; h = "safeZoneH * 0.075"; };
        class BankBalance: FCash_RscStructuredText { idc = 61122; x = "safeZoneX + safeZoneW * 0.51"; y = "safeZoneY + safeZoneH * 0.345"; w = "safeZoneW * 0.20"; h = "safeZoneH * 0.075"; };
        class PersonalPin: FCash_RscText { idc = 61131; text = "Account: -------"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.423"; w = "safeZoneW * 0.20"; h = "safeZoneH * 0.027"; sizeEx = 0.025; colorText[] = {0.60,0.61,0.59,1}; };
        class PersonalAmountLabel: FCash_RscText { idc = 61123; text = "Amount"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.468"; w = "safeZoneW * 0.10"; h = "safeZoneH * 0.026"; };
        class PersonalAmount: FCash_RscEdit { idc = 61124; text = "0"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.498"; w = "safeZoneW * 0.18"; h = "safeZoneH * 0.034"; };
        class Deposit: FCash_RscButtonAccent { idc = 61125; text = "Deposit"; action = "['PERSONAL_DEPOSIT'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.485"; y = "safeZoneY + safeZoneH * 0.498"; w = "safeZoneW * 0.105"; h = "safeZoneH * 0.034"; };
        class Withdraw: FCash_RscButton { idc = 61126; text = "Withdraw"; action = "['PERSONAL_WITHDRAW'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.605"; y = "safeZoneY + safeZoneH * 0.498"; w = "safeZoneW * 0.105"; h = "safeZoneH * 0.034"; };
        class RecipientLabel: FCash_RscText { idc = 61127; text = "Transfer to"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.562"; w = "safeZoneW * 0.12"; h = "safeZoneH * 0.026"; };
        class Recipient: FCash_RscText { idc = 61128; text = "No recipient selected"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.592"; w = "safeZoneW * 0.25"; h = "safeZoneH * 0.034"; sizeEx = 0.026; colorText[] = {0.70,0.70,0.67,1}; colorBackground[] = {0.035,0.035,0.033,0.95}; };
        class RecipientSearch: FCash_RscButton { idc = 61130; text = "Search"; action = "['PERSONAL'] call FCash_fnc_openRecipientSearch"; x = "safeZoneX + safeZoneW * 0.545"; y = "safeZoneY + safeZoneH * 0.592"; w = "safeZoneW * 0.075"; h = "safeZoneH * 0.034"; };
        class Transfer: FCash_RscButtonAccent { idc = 61129; text = "Transfer"; action = "['PERSONAL_TRANSFER'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.63"; y = "safeZoneY + safeZoneH * 0.592"; w = "safeZoneW * 0.08"; h = "safeZoneH * 0.034"; };

        // SHARED
        class SharedTitle: FCash_RscText { idc = 61140; text = "Shared bank"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.305"; w = "safeZoneW * 0.14"; h = "safeZoneH * 0.030"; colorText[] = {0.82,0.69,0.30,1}; };
        class SharedAccounts: FCash_RscCombo { idc = 61141; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.342"; w = "safeZoneW * 0.25"; h = "safeZoneH * 0.034"; onLBSelChanged = "uiNamespace setVariable ['FCash_ui_sharedSelected', (_this select 0) lbData (_this select 1)]; [] call FCash_fnc_bankingRefresh"; };
        class CreateShared: FCash_RscButton { idc = 61142; text = "Create"; action = "['SHARED_CREATE'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.545"; y = "safeZoneY + safeZoneH * 0.342"; w = "safeZoneW * 0.075"; h = "safeZoneH * 0.034"; };
        class SharedLog: FCash_RscButton { idc = 61164; text = "Log"; action = "[] call FCash_fnc_bankingShowLog"; x = "safeZoneX + safeZoneW * 0.63"; y = "safeZoneY + safeZoneH * 0.342"; w = "safeZoneW * 0.08"; h = "safeZoneH * 0.034"; };
        class SharedBalance: FCash_RscStructuredText { idc = 61143; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.388"; w = "safeZoneW * 0.31"; h = "safeZoneH * 0.072"; };
        class SharedRole: FCash_RscText { idc = 61144; text = "Role: none"; x = "safeZoneX + safeZoneW * 0.605"; y = "safeZoneY + safeZoneH * 0.395"; w = "safeZoneW * 0.105"; h = "safeZoneH * 0.026"; sizeEx = 0.025; };
        class SharedVisibility: FCash_RscButton { idc = 61159; text = "Public"; action = "['SHARED_TOGGLE_PUBLIC'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.605"; y = "safeZoneY + safeZoneH * 0.426"; w = "safeZoneW * 0.105"; h = "safeZoneH * 0.030"; };
        class SharedAmount: FCash_RscEdit { idc = 61145; text = "0"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.475"; w = "safeZoneW * 0.16"; h = "safeZoneH * 0.034"; };
        class SharedDeposit: FCash_RscButtonAccent { idc = 61146; text = "Deposit"; action = "['SHARED_DEPOSIT'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.46"; y = "safeZoneY + safeZoneH * 0.475"; w = "safeZoneW * 0.115"; h = "safeZoneH * 0.034"; };
        class SharedWithdraw: FCash_RscButton { idc = 61147; text = "Withdraw"; action = "['SHARED_WITHDRAW'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.59"; y = "safeZoneY + safeZoneH * 0.475"; w = "safeZoneW * 0.12"; h = "safeZoneH * 0.034"; };
        class SharedTransferRecipient: FCash_RscText { idc = 61148; text = "No recipient selected"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.525"; w = "safeZoneW * 0.25"; h = "safeZoneH * 0.034"; sizeEx = 0.026; colorText[] = {0.70,0.70,0.67,1}; colorBackground[] = {0.035,0.035,0.033,0.95}; };
        class SharedSearch: FCash_RscButton { idc = 61158; text = "Search"; action = "['SHARED'] call FCash_fnc_openRecipientSearch"; x = "safeZoneX + safeZoneW * 0.545"; y = "safeZoneY + safeZoneH * 0.525"; w = "safeZoneW * 0.075"; h = "safeZoneH * 0.034"; };
        class SharedTransfer: FCash_RscButtonAccent { idc = 61149; text = "Transfer"; action = "['SHARED_TRANSFER'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.63"; y = "safeZoneY + safeZoneH * 0.525"; w = "safeZoneW * 0.08"; h = "safeZoneH * 0.034"; };
        class MembersLabel: FCash_RscText { idc = 61150; text = "Members"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.575"; w = "safeZoneW * 0.10"; h = "safeZoneH * 0.026"; };
        class Members: FCash_RscListbox { idc = 61151; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.605"; w = "safeZoneW * 0.21"; h = "safeZoneH * 0.135"; onLBSelChanged = "[] call FCash_fnc_bankingMemberChanged"; };
        class InvitePlayer: FCash_RscCombo { idc = 61152; x = "safeZoneX + safeZoneW * 0.51"; y = "safeZoneY + safeZoneH * 0.605"; w = "safeZoneW * 0.20"; h = "safeZoneH * 0.032"; };
        class SharedMemberRole: FCash_RscCombo { idc = 61153; x = "safeZoneX + safeZoneW * 0.51"; y = "safeZoneY + safeZoneH * 0.644"; w = "safeZoneW * 0.095"; h = "safeZoneH * 0.032"; };
        class Invite: FCash_RscButtonAccent { idc = 61154; text = "Invite"; action = "['SHARED_INVITE'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.615"; y = "safeZoneY + safeZoneH * 0.644"; w = "safeZoneW * 0.095"; h = "safeZoneH * 0.032"; };
        class SetRole: FCash_RscButton { idc = 61156; text = "Set role"; action = "['SHARED_SET_ROLE'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.51"; y = "safeZoneY + safeZoneH * 0.684"; w = "safeZoneW * 0.095"; h = "safeZoneH * 0.032"; };
        class RemoveMember: FCash_RscButton { idc = 61157; text = "Remove"; action = "['SHARED_REMOVE'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.615"; y = "safeZoneY + safeZoneH * 0.684"; w = "safeZoneW * 0.095"; h = "safeZoneH * 0.032"; };

        // INVITES
        class InvitesTitle: FCash_RscText { idc = 61160; text = "Invitations"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.305"; w = "safeZoneW * 0.14"; h = "safeZoneH * 0.030"; colorText[] = {0.82,0.69,0.30,1}; };
        class InviteList: FCash_RscListbox { idc = 61161; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.35"; w = "safeZoneW * 0.425"; h = "safeZoneH * 0.30"; };
        class AcceptInvite: FCash_RscButtonAccent { idc = 61162; text = "Accept"; action = "['INVITE_ACCEPT'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.285"; y = "safeZoneY + safeZoneH * 0.67"; w = "safeZoneW * 0.20"; h = "safeZoneH * 0.034"; };
        class DeclineInvite: FCash_RscButton { idc = 61163; text = "Decline"; action = "['INVITE_DECLINE'] call FCash_fnc_bankingAction"; x = "safeZoneX + safeZoneW * 0.51"; y = "safeZoneY + safeZoneH * 0.67"; w = "safeZoneW * 0.20"; h = "safeZoneH * 0.034"; };
    };
};

class FCash_CreateSharedDialog {
    idd = FCASH_IDD_CREATE;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "[_this select 0] call FCash_fnc_uiAnimateIn";
    class controlsBackground {
        class Backdrop: FCash_RscText { x = "safeZoneX + safeZoneW * 0.39"; y = "safeZoneY + safeZoneH * 0.39"; w = "safeZoneW * 0.22"; h = "safeZoneH * 0.19"; colorBackground[] = {0,0,0,0.90}; };
        class Accent: FCash_RscText { x = "safeZoneX + safeZoneW * 0.39"; y = "safeZoneY + safeZoneH * 0.39"; w = "safeZoneW * 0.0025"; h = "safeZoneH * 0.19"; colorBackground[] = {0.78,0.63,0.18,1}; };
    };
    class controls {
        class Title: FCash_RscText { text = "Create shared bank"; x = "safeZoneX + safeZoneW * 0.405"; y = "safeZoneY + safeZoneH * 0.408"; w = "safeZoneW * 0.18"; h = "safeZoneH * 0.030"; colorText[] = {0.82,0.69,0.30,1}; };
        class Name: FCash_RscEdit { idc = 61201; text = ""; x = "safeZoneX + safeZoneW * 0.405"; y = "safeZoneY + safeZoneH * 0.455"; w = "safeZoneW * 0.18"; h = "safeZoneH * 0.034"; };
        class Cancel: FCash_RscButton { text = "Cancel"; action = "[findDisplay 61200] call FCash_fnc_uiCloseDialog"; x = "safeZoneX + safeZoneW * 0.405"; y = "safeZoneY + safeZoneH * 0.515"; w = "safeZoneW * 0.082"; h = "safeZoneH * 0.032"; };
        class Create: FCash_RscButtonAccent { text = "Create"; action = "[] call FCash_fnc_createSharedSubmit"; x = "safeZoneX + safeZoneW * 0.503"; y = "safeZoneY + safeZoneH * 0.515"; w = "safeZoneW * 0.082"; h = "safeZoneH * 0.032"; };
    };
};

class FCash_ZeusModuleDialog {
    idd = FCASH_IDD_ZEUS;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "uiNamespace setVariable ['FCash_ui_zeusDisplay', _this select 0]; [] call FCash_fnc_zeusDialogOnLoad; [_this select 0] call FCash_fnc_uiAnimateIn";
    onUnload = "uiNamespace setVariable ['FCash_ui_zeusDisplay', displayNull]";
    class controlsBackground {
        class Backdrop: FCash_RscText { x = "safeZoneX + safeZoneW * 0.38"; y = "safeZoneY + safeZoneH * 0.33"; w = "safeZoneW * 0.24"; h = "safeZoneH * 0.34"; colorBackground[] = {0,0,0,0.90}; };
        class Header: FCash_RscText { x = "safeZoneX + safeZoneW * 0.38"; y = "safeZoneY + safeZoneH * 0.33"; w = "safeZoneW * 0.24"; h = "safeZoneH * 0.038"; colorBackground[] = {0.11,0.11,0.10,0.98}; };
    };
    class controls {
        class Title: FCash_RscText { idc = 61301; text = "Wallet"; x = "safeZoneX + safeZoneW * 0.395"; y = "safeZoneY + safeZoneH * 0.335"; w = "safeZoneW * 0.21"; h = "safeZoneH * 0.028"; };
        class Summary: FCash_RscText { idc = 61302; text = ""; x = "safeZoneX + safeZoneW * 0.395"; y = "safeZoneY + safeZoneH * 0.385"; w = "safeZoneW * 0.21"; h = "safeZoneH * 0.026"; sizeEx = 0.025; colorText[] = {0.62,0.62,0.60,1}; };
        class ModeLabel: FCash_RscText { idc = 61303; text = "Operation"; x = "safeZoneX + safeZoneW * 0.395"; y = "safeZoneY + safeZoneH * 0.425"; w = "safeZoneW * 0.08"; h = "safeZoneH * 0.026"; };
        class Mode: FCash_RscCombo { idc = 61304; onLBSelChanged = "[] call FCash_fnc_zeusDialogModeChanged"; x = "safeZoneX + safeZoneW * 0.485"; y = "safeZoneY + safeZoneH * 0.422"; w = "safeZoneW * 0.12"; h = "safeZoneH * 0.032"; };
        class AccountLabel: FCash_RscText { idc = 61305; text = "Account"; x = "safeZoneX + safeZoneW * 0.395"; y = "safeZoneY + safeZoneH * 0.465"; w = "safeZoneW * 0.08"; h = "safeZoneH * 0.026"; };
        class Account: FCash_RscCombo { idc = 61306; x = "safeZoneX + safeZoneW * 0.485"; y = "safeZoneY + safeZoneH * 0.462"; w = "safeZoneW * 0.12"; h = "safeZoneH * 0.032"; };
        class NameLabel: FCash_RscText { idc = 61307; text = "Name"; x = "safeZoneX + safeZoneW * 0.395"; y = "safeZoneY + safeZoneH * 0.505"; w = "safeZoneW * 0.08"; h = "safeZoneH * 0.026"; };
        class Name: FCash_RscEdit { idc = 61308; text = ""; x = "safeZoneX + safeZoneW * 0.485"; y = "safeZoneY + safeZoneH * 0.502"; w = "safeZoneW * 0.12"; h = "safeZoneH * 0.032"; };
        class AmountLabel: FCash_RscText { idc = 61309; text = "Value"; x = "safeZoneX + safeZoneW * 0.395"; y = "safeZoneY + safeZoneH * 0.545"; w = "safeZoneW * 0.08"; h = "safeZoneH * 0.026"; };
        class Amount: FCash_RscEdit { idc = 61310; text = "0"; x = "safeZoneX + safeZoneW * 0.485"; y = "safeZoneY + safeZoneH * 0.542"; w = "safeZoneW * 0.12"; h = "safeZoneH * 0.032"; };
        class Cancel: FCash_RscButton { idc = 61311; text = "Cancel"; action = "[findDisplay 61300] call FCash_fnc_uiCloseDialog"; x = "safeZoneX + safeZoneW * 0.395"; y = "safeZoneY + safeZoneH * 0.605"; w = "safeZoneW * 0.095"; h = "safeZoneH * 0.032"; };
        class Confirm: FCash_RscButtonAccent { idc = 61312; text = "Apply"; action = "[] call FCash_fnc_zeusSubmit"; x = "safeZoneX + safeZoneW * 0.51"; y = "safeZoneY + safeZoneH * 0.605"; w = "safeZoneW * 0.095"; h = "safeZoneH * 0.032"; };
    };
};

class FCash_RecipientSearchDialog {
    idd = FCASH_IDD_RECIPIENT;
    movingEnable = 0;
    enableSimulation = 1;
    onLoad = "_this call FCash_fnc_recipientSearchOnLoad";
    onUnload = "uiNamespace setVariable ['FCash_ui_recipientDisplay', displayNull]";
    class controlsBackground {
        class Backdrop: FCash_RscText { x = "safeZoneX + safeZoneW * 0.34"; y = "safeZoneY + safeZoneH * 0.25"; w = "safeZoneW * 0.32"; h = "safeZoneH * 0.50"; colorBackground[] = {0,0,0,0.92}; };
        class Header: FCash_RscText { x = "safeZoneX + safeZoneW * 0.34"; y = "safeZoneY + safeZoneH * 0.25"; w = "safeZoneW * 0.32"; h = "safeZoneH * 0.038"; colorBackground[] = {0.11,0.11,0.10,0.98}; };
        class Accent: FCash_RscText { x = "safeZoneX + safeZoneW * 0.34"; y = "safeZoneY + safeZoneH * 0.25"; w = "safeZoneW * 0.0025"; h = "safeZoneH * 0.038"; colorBackground[] = {0.78,0.63,0.18,1}; };
    };
    class controls {
        class Title: FCash_RscText { text = "Select recipient"; x = "safeZoneX + safeZoneW * 0.355"; y = "safeZoneY + safeZoneH * 0.255"; w = "safeZoneW * 0.20"; h = "safeZoneH * 0.028"; };
        class Search: FCash_RscEdit { idc = 61401; text = ""; x = "safeZoneX + safeZoneW * 0.355"; y = "safeZoneY + safeZoneH * 0.31"; w = "safeZoneW * 0.29"; h = "safeZoneH * 0.034"; onKeyUp = "[] call FCash_fnc_recipientSearchRefresh"; };
        class PersonalFilter: FCash_RscCheckbox { idc = 61403; x = "safeZoneX + safeZoneW * 0.355"; y = "safeZoneY + safeZoneH * 0.355"; w = "safeZoneW * 0.018"; h = "safeZoneH * 0.026"; onCheckedChanged = "[] call FCash_fnc_recipientSearchRefresh"; };
        class PersonalFilterLabel: FCash_RscText { text = "Personal"; x = "safeZoneX + safeZoneW * 0.377"; y = "safeZoneY + safeZoneH * 0.354"; w = "safeZoneW * 0.075"; h = "safeZoneH * 0.026"; sizeEx = 0.024; };
        class SharedFilter: FCash_RscCheckbox { idc = 61404; x = "safeZoneX + safeZoneW * 0.465"; y = "safeZoneY + safeZoneH * 0.355"; w = "safeZoneW * 0.018"; h = "safeZoneH * 0.026"; onCheckedChanged = "[] call FCash_fnc_recipientSearchRefresh"; };
        class SharedFilterLabel: FCash_RscText { text = "Shared"; x = "safeZoneX + safeZoneW * 0.487"; y = "safeZoneY + safeZoneH * 0.354"; w = "safeZoneW * 0.075"; h = "safeZoneH * 0.026"; sizeEx = 0.024; };
        class Results: FCash_RscListbox { idc = 61402; x = "safeZoneX + safeZoneW * 0.355"; y = "safeZoneY + safeZoneH * 0.397"; w = "safeZoneW * 0.29"; h = "safeZoneH * 0.263"; onLBDblClick = "[] call FCash_fnc_recipientSearchSelect"; };
        class Hint: FCash_RscText { text = "7-digit account numbers always work, including private shared banks"; x = "safeZoneX + safeZoneW * 0.355"; y = "safeZoneY + safeZoneH * 0.668"; w = "safeZoneW * 0.29"; h = "safeZoneH * 0.025"; sizeEx = 0.021; colorText[] = {0.58,0.59,0.57,1}; };
        class Cancel: FCash_RscButton { text = "Cancel"; action = "[findDisplay 61400] call FCash_fnc_uiCloseDialog"; x = "safeZoneX + safeZoneW * 0.355"; y = "safeZoneY + safeZoneH * 0.705"; w = "safeZoneW * 0.135"; h = "safeZoneH * 0.032"; };
        class Select: FCash_RscButtonAccent { text = "Select"; action = "[] call FCash_fnc_recipientSearchSelect"; x = "safeZoneX + safeZoneW * 0.51"; y = "safeZoneY + safeZoneH * 0.705"; w = "safeZoneW * 0.135"; h = "safeZoneH * 0.032"; };
    };
};

class FCash_SharedLogDialog {
    idd = FCASH_IDD_LOG;
    movingEnable = 0;
    enableSimulation = 1;
    class controlsBackground {
        class Backdrop: FCash_RscText { x = "safeZoneX + safeZoneW * 0.30"; y = "safeZoneY + safeZoneH * 0.22"; w = "safeZoneW * 0.40"; h = "safeZoneH * 0.56"; colorBackground[] = {0,0,0,0.92}; };
        class Header: FCash_RscText { x = "safeZoneX + safeZoneW * 0.30"; y = "safeZoneY + safeZoneH * 0.22"; w = "safeZoneW * 0.40"; h = "safeZoneH * 0.038"; colorBackground[] = {0.11,0.11,0.10,0.98}; };
        class Accent: FCash_RscText { x = "safeZoneX + safeZoneW * 0.30"; y = "safeZoneY + safeZoneH * 0.22"; w = "safeZoneW * 0.0025"; h = "safeZoneH * 0.038"; colorBackground[] = {0.78,0.63,0.18,1}; };
    };
    class controls {
        class Title: FCash_RscText { text = "Shared bank log"; x = "safeZoneX + safeZoneW * 0.315"; y = "safeZoneY + safeZoneH * 0.225"; w = "safeZoneW * 0.20"; h = "safeZoneH * 0.028"; };
        class Account: FCash_RscText { idc = 61503; text = ""; x = "safeZoneX + safeZoneW * 0.315"; y = "safeZoneY + safeZoneH * 0.275"; w = "safeZoneW * 0.37"; h = "safeZoneH * 0.028"; colorText[] = {0.82,0.69,0.30,1}; };
        class Log: FCash_RscListbox { idc = 61501; x = "safeZoneX + safeZoneW * 0.315"; y = "safeZoneY + safeZoneH * 0.315"; w = "safeZoneW * 0.37"; h = "safeZoneH * 0.39"; };
        class Close: FCash_RscButton { text = "Close"; action = "[findDisplay 61500] call FCash_fnc_uiCloseDialog"; x = "safeZoneX + safeZoneW * 0.315"; y = "safeZoneY + safeZoneH * 0.72"; w = "safeZoneW * 0.37"; h = "safeZoneH * 0.032"; };
    };
};
