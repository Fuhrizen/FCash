class CfgPatches {
    class FCash_Main {
        name = "Fuhrizen's Cash";
        author = "Fuhrizen";
        requiredVersion = 2.18;
        requiredAddons[] = {"A3_Modules_F", "A3_Modules_F_Curator", "cba_main", "cba_settings", "cba_xeh", "ace_interact_menu"};
        units[] = {
            "FCash_Module_ManageFunds",
            "FCash_Module_ManageSharedBanks",
            "FCash_Module_ManageStash",
            "FCash_Module_SetBankTerminal",
            "FCash_Module_RemoveBankTerminal",
            "FCash_Module_3DENSharedBank"
        };
        weapons[] = {};
        version = "1.0.0";
    };
};

class CfgFCash {
    startWallet = 0;
    startBank = 0;
    loseWalletOnDeath = 1;

    allowGive = 1;
    allowTakeDead = 1;
    allowTakeCaptive = 1;
    allowDirectSend = 0;
    allowBankTransferAnySide = 1;

    interactionDistance = 3.5;
    terminalDistance = 5.0;
    maxTransaction = 100000000;

    sharedBankEnabled = 1;
    sharedCreateFee = 0;
    sharedMaxOwned = 5;
    sharedMaxMembers = 32;
    sharedNameMin = 3;
    sharedNameMax = 32;
    sharedLogLimit = 150;

    requestBurst = 10;
    requestWindow = 1.0;
    auditLimit = 250;

    zeusModulesEnabled = 1;
    zeusNotifyAffectedPlayers = 1;

    currencySymbol = "$";
    atmClasses[] = {"Land_Atm_01_F", "Land_Atm_02_F", "Land_ATM_01_malden_F", "Land_ATM_02_malden_F"};
};

class CfgFunctions {
    class FCash {
        tag = "FCash";

        class Init {
            file = "\x\fcash\addons\main\functions";
            class preInit { preInit = 1; };
            class postInit { postInit = 1; };
            class clientInit {};
            class serverInit {};
            class registerSettings {};
        };

        class Common {
            file = "\x\fcash\addons\main\functions";
            class getSetting {};
            class formatMoney {};
            class addEventHandler {};
            class removeEventHandler {};
            class emitEvent {};
            class clientEvent {};
            class requestSync {};
            class getWallet {};
            class getBank {};
            class formatAccountNumber {};
        };

        class Client {
            file = "\x\fcash\addons\main\functions";
            class clientSync {};
            class clientNotify {};
            class clientInstallObjectActions {};
            class clientScanTerrainATMs {};
            class showWalletHud {};
            class openAmountDialog {};
            class submitAmount {};
            class openBanking {};
            class bankingOnLoad {};
            class bankingSetTab {};
            class bankingRefresh {};
            class bankingMemberChanged {};
            class bankingAction {};
            class createSharedSubmit {};
            class uiAnimateIn {};
            class uiCloseDialog {};
            class openRecipientSearch {};
            class recipientSearchOnLoad {};
            class recipientSearchRefresh {};
            class recipientSearchSelect {};
            class bankingShowLog {};
            class clientSharedLog {};
            class clientZeusContext {};
            class zeusInitModule {};
            class zeusModule {};
            class zeusDialogOnLoad {};
            class zeusDialogModeChanged {};
            class zeusSubmit {};
        };

        class Server {
            file = "\x\fcash\addons\main\functions";
            class serverRequest {};
            class serverFindCaller {};
            class serverEnsureAccount {};
            class serverValidateAmount {};
            class serverValidateTerminal {};
            class serverPromoteTerrainATM {};
            class serverRateLimit {};
            class serverSyncPlayer {};
            class serverNotify {};
            class serverAudit {};
            class serverGeneratePin {};
            class serverResolveBankTarget {};
            class serverSharedLog {};
            class serverResolveStartingValue {};
            class serverApply3DENObject {};
            class serverGetSharedRole {};
            class serverSharedCan {};
            class serverAdjustWallet {};
            class serverAdjustBank {};
            class serverAdjustStorage {};
            class serverCreateShared {};
            class serverAdjustShared {};
            class serverRenameShared {};
            class serverSetSharedMember {};
            class serverDeleteShared {};
            class serverZeusRequest {};
            class registerStorage {};
            class registerTerminal {};
            class unregisterStorage {};
            class unregisterTerminal {};
            class exportState {};
            class importState {};
            class getAuditLog {};
            class module3DENSharedBank {};
        };
    };
};

class CfgRemoteExec {
    class Functions {
        class FCash_fnc_serverRequest { allowedTargets = 2; };
        class FCash_fnc_serverZeusRequest { allowedTargets = 2; };
        class FCash_fnc_serverPromoteTerrainATM { allowedTargets = 2; };
        class FCash_fnc_clientSync { allowedTargets = 1; };
        class FCash_fnc_clientNotify { allowedTargets = 1; };
        class FCash_fnc_clientEvent { allowedTargets = 1; };
        class FCash_fnc_clientInstallObjectActions { allowedTargets = 0; };
        class FCash_fnc_clientZeusContext { allowedTargets = 1; };
        class FCash_fnc_clientSharedLog { allowedTargets = 1; };
    };
};

class Extended_PreInit_EventHandlers {
    class FCash_Main {
        init = "call compile preprocessFileLineNumbers '\x\fcash\addons\main\XEH_preInit.sqf'";
    };
};

#include "zeus.hpp"
#include "cfg3den.hpp"
#include "ui\controls.hpp"
#include "ui\dialogs.hpp"
