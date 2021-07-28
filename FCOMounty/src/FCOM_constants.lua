if FCOM == nil then FCOM = {} end
local FCOMounty = FCOM

FCOMounty.addonVars = {}
FCOMounty.addonVars.addonVersion		        = "0.2.3"
FCOMounty.addonVars.addonSavedVarsVersion	    = "0.01"
FCOMounty.addonVars.addonName				    = "FCOMounty"
FCOMounty.addonVars.addonNameMenu  		        = "FCO Mounty"
FCOMounty.addonVars.addonNameMenuDisplay	    = "|c00FF00FCO |cFFFF00 Mounty|r"
FCOMounty.addonVars.addonSavedVariablesName     = "FCOMounty_Settings"
FCOMounty.addonVars.settingsName   		        = "FCO Mounty"
FCOMounty.addonVars.addonAuthor			        = "Baertram"
FCOMounty.addonVars.addonWebsite                = "http://www.esoui.com/downloads/info1866-FCOMounty.html"
FCOMounty.addonVars.addonFeedback               = "https://www.esoui.com/downloads/info1866-FCOMounty.html#comments"
FCOMounty.addonVars.addonDonation               = "https://www.esoui.com/portal.php?id=136&a=faq&faqid=131"
FCOMounty.addonVars.bugReportURL                = "https://www.esoui.com/portal.php?id=136&a=bugreport&addonid=%s&title=%s&message=%s"
FCOMounty.addonVars.bugReportAddonId            = 1866 -- FCOMounty

--For the events EVENT_ACTION_LAYER_PUSHED|_POPPED
LAYER_MOUSE_UI_MODE = 7
--Constants for the zones and subzones dropdownboxes
FCOM_ALL_ENTRIES  = "-ALL-"
FCOM_NONE_ENTRIES = "-NONE-"
--Constants for the zone ID
FCOM_ZONE_ID_STRING = "_zoneId"
--Constants for the zone and subzone name mapping
FCOM_ZONE_MAPPING_STRING = "_mappedZoneName"

--The SavedVariables
FCOMounty.settingsVars = {}
FCOMounty.settingsVars.defaultSettings = {}
FCOMounty.settingsVars.settings = {}
FCOMounty.settingsVars.defaults = {}

--Prevent something
FCOMounty.preventerVars = {}
FCOMounty.preventerVars.doNotUpdateSubZoneValue = false
FCOMounty.preventerVars.doNotUpdateRandomMountsValue = false
FCOMounty.preventerVars.lastZone = FCOM_NONE_ENTRIES
FCOMounty.preventerVars.lastSubZone = FCOM_NONE_ENTRIES
FCOMounty.preventerVars.doNotChangePresetMount = false
FCOMounty.preventerVars.getMountFromSettingsNow = false
FCOMounty.preventerVars.updateMountInCombat = false
FCOMounty.preventerVars.manuallyMountChosen = false
FCOMounty.preventerVars.GetZoneDataCallActive =false
FCOMounty.preventerVars.ZoneDataWasUpdatedNowUpdateLAMDropdowns = false

--LAM settings menu dropdowns
FCOMounty.LAMDropdownSubZoneNames = {}
FCOMounty.LAMDropdownSubZoneValues = {}
FCOMounty.LAMSelectedZone       = FCOM_NONE_ENTRIES
FCOMounty.LAMSelectedSubZone    = FCOM_NONE_ENTRIES

--For the shown mount's enhancements
FCOMounty.gameSettings = {}
FCOMounty.gameSettings.settingsCategories = {}
FCOMounty.gameSettings.settingsCategories[RIDING_TRAIN_SPEED] = SETTING_TYPE_IN_WORLD
FCOMounty.gameSettings.settingsCategories[RIDING_TRAIN_STAMINA] = SETTING_TYPE_IN_WORLD
FCOMounty.gameSettings.settingsCategories[RIDING_TRAIN_CARRYING_CAPACITY] = SETTING_TYPE_IN_WORLD
FCOMounty.gameSettings.settingsIDs = {}
FCOMounty.gameSettings.settingsIDs[RIDING_TRAIN_SPEED] = IN_WORLD_UI_SETTING_HIDE_MOUNT_SPEED_UPGRADE
FCOMounty.gameSettings.settingsIDs[RIDING_TRAIN_STAMINA] = IN_WORLD_UI_SETTING_HIDE_MOUNT_STAMINA_UPGRADE
FCOMounty.gameSettings.settingsIDs[RIDING_TRAIN_CARRYING_CAPACITY] = IN_WORLD_UI_SETTING_HIDE_MOUNT_INVENTORY_UPGRADE

--Random mounts
FCOMounty.lastRandomMountId = 0

--Is in variables
FCOMounty.isInDungeon = false
FCOMounty.isInDelve = false


