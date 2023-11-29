#include "..\script_component.hpp"
/*
 * Author: commy2
 * Called by repair action / progress bar. Raise events to set the new hitpoint damage.
 *
 * Arguments:
 * 0: Unit that does the repairing <OBJECT>
 * 1: Vehicle to repair <OBJECT>
 * 2: Selected hitpointIndex <NUMBER>
 * 3: Repair action classname <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * [unit, vehicle, 6, "MiscRepair"] call ace_repair_fnc_doRepair
 *
 * Public: No
 */

params ["_unit", "_vehicle", "_hitPointIndex", "_action"];
TRACE_4("params",_unit,_vehicle,_hitPointIndex,_action);

// override minimum damage if doing full repair
private _postRepairDamageMin = [_unit, _action isEqualTo "fullRepair"] call FUNC(getPostRepairDamage);

(getAllHitPointsDamage _vehicle) params ["_allHitPoints"];
private _hitPointClassname = _allHitPoints select _hitPointIndex;
private _initializedDepends = missionNamespace getVariable [QGVAR(dependsHitPointsInitializedClasses), createHashMap];
private _repairedHitpoints = [];

// get current hitpoint damage
private _hitPointCurDamage = _vehicle getHitIndex _hitPointIndex;

// repair a max of 0.5, don't use negative values for damage
private _hitPointNewDamage = (_hitPointCurDamage - 0.5) max _postRepairDamageMin;

if (_hitPointNewDamage < _hitPointCurDamage) then {
    // raise event to set the new hitpoint damage
    TRACE_3("repairing main point", _vehicle, _hitPointIndex, _hitPointNewDamage);
    [QGVAR(setVehicleHitPointDamage), [_vehicle, _hitPointIndex, _hitPointNewDamage], _vehicle] call CBA_fnc_targetEvent;
    _hitPointCurDamage = _hitPointNewDamage;
};

// Get hitpoint groups if available
private _hitpointGroupConfig = configOf _vehicle >> QGVAR(hitpointGroups);
if (isArray _hitpointGroupConfig) then {
    // Retrieve hitpoint subgroup if current hitpoint is main hitpoint of a group
    {
        _x params ["_masterHitpoint", "_subHitArray"];
        // Exit using found hitpoint group if this hitpoint is leader of any
        if (_masterHitpoint == _hitPointClassname) exitWith {
            {
                private _subHitpoint = _x;
                private _subHitIndex = _allHitPoints findIf {_x == _subHitpoint}; //convert hitpoint classname to index
                if (_subHitIndex == -1) then {
                    ERROR_2("Invalid hitpoint %1 in hitpointGroups of %2",_subHitpoint,_vehicle);
                } else {
                    private _subPointCurDamage = _vehicle getHitIndex _hitPointIndex;
                    private _subPointNewDamage = (_subPointCurDamage - 0.5) max _postRepairDamageMin;
                    if (_subPointNewDamage < _subPointCurDamage) then {
                        TRACE_3("repairing sub point", _vehicle, _subHitIndex, _subPointNewDamage);
                        _repairedHitpoints pushBack _subHitIndex;
                        [QGVAR(setVehicleHitPointDamage), [_vehicle, _subHitIndex, _subPointNewDamage], _vehicle] call CBA_fnc_targetEvent;
                    };
                };
            } forEach _subHitArray;
        };
    } forEach (getArray _hitpointGroupConfig);
};

// Fix damagable depends hitpoints with ignored parent
private _type = typeOf _vehicle;
private _vehicleDependsArray = _initializedDepends get _type;
{ 
    _x params ["_parentHitpoint","_dependsHitpoint"];
    if (_hitPointClassname == _dependsHitpoint) exitWith {
        private _dependsIndex = _allHitPoints findIf {_x == _dependsHitpoint};
        private _parentIndex = _allHitPoints findIf {_x == _parentHitpoint};
        if (_parentIndex in _repairedHitpoints) then {
            TRACE_2("Skipping repair, depends parent fixed in hitpoint groups",_parentHitpoint,_vehicle);
            continue;
        } else {
            private _parentHitpointCurDamage = _vehicle getHitIndex _parentIndex;
            private _parentHitpointNewDamage = (_parentHitpointCurDamage - 0.5) max _postRepairDamageMin;
            private _dependsHitpointCurDamage = _vehicle getHitIndex _dependsIndex;
            private _dependsHitpointNewDamage = (_dependsHitpointCurDamage - 0.5) max _postRepairDamageMin;
            if (_parentHitpointNewDamage < _parentHitpointCurDamage 
            || _dependsHitpointNewDamage < _dependsHitpointCurDamage) then {
                TRACE_4("Repairing depends parent", _vehicle, _dependsIndex, _parentIndex, _parentHitpointNewDamage);
                [QGVAR(setVehicleHitPointDamage), [_vehicle, _parentIndex, _parentHitpointNewDamage], _vehicle] call CBA_fnc_targetEvent;
            };
        };
    };
} forEach _vehicleDependsArray;

// display text message if enabled
if (GVAR(DisplayTextOnRepair)) then {
    // Find localized string
    private _textLocalized = localize ([LSTRING(RepairedHitPointFully), LSTRING(RepairedHitPointPartially)] select (_hitPointCurDamage > 0));
    private _textDefault = localize ([LSTRING(RepairedFully), LSTRING(RepairedPartially)] select (_hitPointCurDamage > 0));
    ([_hitPointClassname, _textLocalized, _textDefault] call FUNC(getHitPointString)) params ["_text"];

    // Display text
    [_text] call EFUNC(common,displayTextStructured);
};
