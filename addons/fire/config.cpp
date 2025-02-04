#include "script_component.hpp"

#if __has_include("\z\ace\addons\nomedical\script_component.hpp")
#define PATCH_SKIP "No Medical"
#endif

#ifdef PATCH_SKIP
ACE_PATCH_NOT_LOADED(ADDON,PATCH_SKIP)
#else
class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ace_common", "ace_medical_engine"};
        author = ECSTRING(common,ACETeam);
        authors[] = {"commy2", "tcvm"};
        url = ECSTRING(main,URL);
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgSounds.hpp"
#include "ACE_Medical_Treatment_Actions.hpp"
#include "RscTitles.hpp"

#endif
