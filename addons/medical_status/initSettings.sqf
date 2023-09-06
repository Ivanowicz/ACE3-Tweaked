[
    QEGVAR(medical,bleedingCoefficient),
    "SLIDER",
    [LSTRING(BleedingCoefficient_DisplayName), LSTRING(BleedingCoefficient_Description)],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    [0, 25, 1, 1],
    true
] call CBA_fnc_addSetting;

[
    QEGVAR(medical,painCoefficient),
    "SLIDER",
    [LSTRING(PainCoefficient_DisplayName), LSTRING(PainCoefficient_Description)],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    [0, 25, 1, 1],
    true
] call CBA_fnc_addSetting;

[
    QEGVAR(medical,ivFlowRate),
    "SLIDER",
    [LSTRING(IvFlowRate_DisplayName), LSTRING(IvFlowRate_Description)],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    [0, 25, 1, 1],
    true
] call CBA_fnc_addSetting;

[
    QEGVAR(medical,stableVitalsMaxHemorrhageLevel),
    "LIST",
    [LSTRING(StableVitalsMaxHemorrhageLevel_DisplayName), LSTRING(StableVitalsMaxHemorrhageLevel_Description)],
    [ELSTRING(medical,Category), LSTRING(SubCategory)],
    [
        [BLOOD_VOLUME_CLASS_2_HEMORRHAGE, BLOOD_VOLUME_CLASS_3_HEMORRHAGE, BLOOD_VOLUME_CLASS_4_HEMORRHAGE], 
        [ELSTRING(medical_gui,Lost_Blood1), ELSTRING(medical_gui,Lost_Blood2), ELSTRING(medical_gui,Lost_Blood3)], 
        0
    ],
    true
] call CBA_fnc_addSetting;