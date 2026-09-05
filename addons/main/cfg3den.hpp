class Cfg3DEN {
    class Object {
        class AttributeCategories {
            class FCash_Attributes {
                displayName = "Fuhrizen's Cash";
                collapsed = 1;
                class Attributes {
                    class FCash_StartingWallet {
                        displayName = "Starting Wallet";
                        tooltip = "Sets the amount of cash carried by this unit when the mission starts. A numeric value or SQF code returning a number can be used.";
                        property = "FCash_3denWalletRaw";
                        control = "EditShort";
                        expression = "_this setVariable ['FCash_3denWalletRaw', _value, true];";
                        defaultValue = "''";
                        typeName = "STRING";
                        condition = "objectBrain";
                    };

                    class FCash_StartingBank {
                        displayName = "Starting Bank Balance";
                        tooltip = "Sets the amount of money stored in this unit's personal bank account when the mission starts. A numeric value or SQF code returning a number can be used.";
                        property = "FCash_3denBankRaw";
                        control = "EditShort";
                        expression = "_this setVariable ['FCash_3denBankRaw', _value, true];";
                        defaultValue = "''";
                        typeName = "STRING";
                        condition = "objectBrain";
                    };

                    class FCash_IsStash {
                        displayName = "Cash Stash";
                        tooltip = "Enables this object as a cash stash. Players can store and withdraw physical cash from it using ACE interaction.";
                        property = "FCash_3denIsStorage";
                        control = "Checkbox";
                        expression = "_this setVariable ['FCash_3denIsStorage', _value, true];";
                        defaultValue = "false";
                        typeName = "BOOL";
                        condition = "1-objectBrain";
                    };

                    class FCash_StashStartingCash {
                        displayName = "Starting Stash Balance";
                        tooltip = "Sets the amount of cash stored in this stash when the mission starts. A numeric value or SQF code returning a number can be used.";
                        property = "FCash_3denStorageRaw";
                        control = "EditShort";
                        expression = "_this setVariable ['FCash_3denStorageRaw', _value, true];";
                        defaultValue = "'0'";
                        typeName = "STRING";
                        condition = "1-objectBrain";
                    };

                    class FCash_IsBankTerminal {
                        displayName = "Bank Terminal";
                        tooltip = "Enables this object as a bank terminal. Players can access personal and shared banking from it using ACE interaction.";
                        property = "FCash_3denIsTerminal";
                        control = "Checkbox";
                        expression = "_this setVariable ['FCash_3denIsTerminal', _value, true];";
                        defaultValue = "false";
                        typeName = "BOOL";
                        condition = "1-objectBrain";
                    };
                };
            };
        };
    };
};
