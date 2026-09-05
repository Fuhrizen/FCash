class CBA_Extended_EventHandlers_base;

class CfgFactionClasses {
    class NO_CATEGORY;
    class FCash_Zeus: NO_CATEGORY { displayName = "Fuhrizen's Cash"; };
    class FCash_3DEN: NO_CATEGORY { displayName = "Fuhrizen's Cash"; };
};

class CfgVehicles {
    class Logic;
    class Module_F: Logic {
        class AttributesBase {
            class Edit;
            class Combo;
            class Checkbox;
            class ModuleDescription;
        };
        class ModuleDescription;
    };

    // Zeus modules. Keep this surface deliberately small.
    class FCash_ModuleBase: Module_F {
        author = "Fuhrizen";
        category = "FCash_Zeus";
        function = "FCash_fnc_zeusModule";
        scope = 1;
        scopeCurator = 1;
        curatorCanAttach = 1;
        icon = "\A3\ui_f\data\gui\Rsc\RscDisplayArsenal\cargoMisc_ca.paa";
        class EventHandlers {
            init = "_this call FCash_fnc_zeusInitModule";
            class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers_base {};
        };
    };

    class FCash_Module_ManageFunds: FCash_ModuleBase {
        scopeCurator = 2;
        displayName = "Manage Funds";
        FCash_operation = "FUNDS_MANAGE";
    };

    class FCash_Module_ManageSharedBanks: FCash_ModuleBase {
        scopeCurator = 2;
        displayName = "Manage Shared Banks";
        FCash_operation = "SHARED_MANAGE";
        curatorCanAttach = 0;
    };

    class FCash_Module_ManageStash: FCash_ModuleBase {
        scopeCurator = 2;
        displayName = "Manage Stash";
        FCash_operation = "STASH_MANAGE";
    };

    class FCash_Module_SetBankTerminal: FCash_ModuleBase {
        scopeCurator = 2;
        displayName = "Set Bank Terminal";
        FCash_operation = "TERMINAL_SET";
    };

    class FCash_Module_RemoveBankTerminal: FCash_ModuleBase {
        scopeCurator = 2;
        displayName = "Remove Bank Terminal";
        FCash_operation = "TERMINAL_REMOVE";
    };

    // 3DEN shared-bank authoring module. Object/unit setup lives in Cfg3DEN attributes.
    class FCash_Module_3DENSharedBank: Module_F {
        author = "Fuhrizen";
        category = "FCash_3DEN";
        scope = 2;
        scopeCurator = 0;
        displayName = "Shared Bank";
        icon = "\A3\ui_f\data\gui\Rsc\RscDisplayArsenal\cargoMisc_ca.paa";
        function = "FCash_fnc_module3DENSharedBank";
        isGlobal = 1;
        isTriggerActivated = 0;
        class Attributes: AttributesBase {
            class Name: Edit {
                displayName = "Shared Bank Name";
                property = "FCash_sharedName";
                control = "Edit";
                typeName = "STRING";
                defaultValue = "'Shared Bank'";
                expression = "_this setVariable ['FCash_sharedName', _value, true];";
            };
            class Value: Edit {
                displayName = "Starting Balance";
                tooltip = "Sets the initial balance of the shared bank account. A numeric value or SQF code returning a number can be used.";
                property = "FCash_sharedValue";
                control = "Edit";
                typeName = "STRING";
                defaultValue = "'0'";
                expression = "_this setVariable ['FCash_sharedValue', _value, true];";
            };
            class Public: Checkbox {
                displayName = "Public Account";
                tooltip = "Controls whether this shared bank appears in recipient searches. Private accounts can still receive transfers when their account number is known.";
                property = "FCash_sharedPublic";
                control = "Checkbox";
                typeName = "BOOL";
                defaultValue = "true";
                expression = "_this setVariable ['FCash_sharedPublic', _value, true];";
            };
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = "Units synchronized to this module are added as members of the shared bank. The first synchronized playable unit is assigned as the account owner.";
        };
    };
};
