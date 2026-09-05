class RscText;
class RscStructuredText;
class RscButton;
class RscEdit;
class RscCombo;
class RscListbox;
class RscCheckbox;

class FCash_RscText: RscText {
    font = "PuristaMedium";
    sizeEx = 0.035;
    colorText[] = {0.92,0.91,0.87,1};
    colorBackground[] = {0,0,0,0};
};

class FCash_RscStructuredText: RscStructuredText {
    font = "PuristaMedium";
    size = 0.035;
    colorText[] = {0.92,0.91,0.87,1};
    colorBackground[] = {0,0,0,0};
};

class FCash_RscEdit: RscEdit {
    font = "PuristaMedium";
    sizeEx = 0.035;
    colorText[] = {0.94,0.94,0.92,1};
    colorBackground[] = {0.045,0.045,0.045,1};
    colorSelection[] = {0.76,0.60,0.19,1};
    autocomplete = "";
};

class FCash_RscButton: RscButton {
    font = "PuristaSemiBold";
    sizeEx = 0.032;
    colorText[] = {0.92,0.91,0.87,1};
    colorBackground[] = {0.08,0.08,0.08,0.96};
    colorBackgroundActive[] = {0.30,0.38,0.18,1};
    colorFocused[] = {0.30,0.38,0.18,1};
    colorDisabled[] = {0.45,0.45,0.45,0.8};
    colorShadow[] = {0,0,0,0};
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    borderSize = 0;
};


class FCash_RscTabButton: FCash_RscButton {
    colorText[] = {0.72,0.72,0.69,1};
    colorDisabled[] = {0.96,0.94,0.86,1};
    colorBackground[] = {0.055,0.055,0.052,0.96};
    colorBackgroundDisabled[] = {0.30,0.36,0.17,1};
    colorBackgroundActive[] = {0.12,0.13,0.09,1};
    colorFocused[] = {0.12,0.13,0.09,1};
};

class FCash_RscButtonAccent: FCash_RscButton {
    colorText[] = {0.96,0.94,0.86,1};
    colorBackground[] = {0.30,0.36,0.17,1};
    colorBackgroundActive[] = {0.55,0.48,0.20,1};
    colorFocused[] = {0.55,0.48,0.20,1};
};

class FCash_RscCombo: RscCombo {
    font = "PuristaMedium";
    sizeEx = 0.032;
    colorText[] = {0.94,0.94,0.92,1};
    colorBackground[] = {0.05,0.05,0.05,1};
    colorSelect[] = {0.05,0.05,0.05,1};
    colorSelectBackground[] = {0.78,0.63,0.18,1};
    colorDisabled[] = {0.45,0.45,0.45,0.8};
};

class FCash_RscListbox: RscListbox {
    font = "PuristaMedium";
    sizeEx = 0.032;
    colorText[] = {0.90,0.90,0.88,1};
    colorBackground[] = {0.04,0.04,0.04,1};
    colorSelect[] = {0.05,0.05,0.05,1};
    colorSelectBackground[] = {0.76,0.60,0.19,1};
};

class FCash_RscCheckbox: RscCheckbox {
    color[] = {0.82,0.69,0.30,1};
    colorFocused[] = {0.90,0.76,0.34,1};
    colorHover[] = {0.90,0.76,0.34,1};
    colorPressed[] = {0.72,0.60,0.25,1};
};
