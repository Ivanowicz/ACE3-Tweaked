#include "script_component.hpp"
/*
 * Author: SilentSpike
 * Flips the unconscious state of the unit the module is placed on.
 *
 * Arguments:
 * 0: The module logic <OBJECT>
 * 1: Synchronized units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [LOGIC, [bob, kevin], true] call ace_zeus_fnc_moduleUnconscious
 *
 * Public: No
 */

params ["_logic"];

if !(local _logic) exitWith {};

if (isNil QEFUNC(medical,setUnconscious)) then {
    [LSTRING(RequiresAddon)] call FUNC(showMessage);
} else {
    private _mouseOver = GETMVAR(bis_fnc_curatorObjectPlaced_mouseOver,[""]);

    if ((_mouseOver select 0) != "OBJECT") then {
        [LSTRING(NothingSelected)] call FUNC(showMessage);
    } else {
        private _unit = effectiveCommander (_mouseOver select 1);

        if !(_unit isKindOf "CAManBase") then {
            [LSTRING(OnlyInfantry)] call FUNC(showMessage);
        } else {
            private _cardiacArrest = (EFUNC(medical,IN_CRDC_ARRST(unit)));
            if (!(alive _unit) and (!_cardiacArrest)) then {
                [LSTRING(OnlyAlive)] call FUNC(showMessage);
            } else {
                if (_cardiacArrest) then {
                    TRACE_1("Exiting cardiac arrest",_unit);
                    [QEGVAR(medical,CPRSucceeded), _unit] call CBA_fnc_localEvent;
                    /*_state = GET_SM_STATE(_unit)
                    TRACE_1("after CPRSucceeded",_state);*/
                };
                private _unconscious = GETVAR(_unit,ACE_isUnconscious,false);
                if (_unconscious) then {
                    _unit setVariable [QEGVAR(medical_statemachine,AIUnconsciousness), nil, true];
                } else {
                    _unit setVariable [QEGVAR(medical_statemachine,AIUnconsciousness), true, true];
                };
                // Function handles locality for me
                [_unit, !_unconscious, 10e10] call EFUNC(medical,setUnconscious);
            };
        };
    };
};

deleteVehicle _logic;
