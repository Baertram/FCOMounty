if FCOM == nil then FCOM = {} end
local FCOMounty = FCOM

--Check the collectibles and build the mount data
--> Taken this code to check collectibles from addon PimpMyride by Ayantir:
--http://www.esoui.com/downloads/info1140-PimpmyRide-CollectibleRandomizerOutfitter.html
function FCOMounty.BuildMountData()
    FCOMounty.MountData = {}
    local MountData = {}

    for categoryIndex=1, GetNumCollectibleCategories() do

        local name, numSubCatgories, numCollectibles, unlockedCollectibles = GetCollectibleCategoryInfo(categoryIndex)

        for subCategoryIndex=1, numSubCatgories do

            local subCategoryName, subCategoryNumCollectibles, subCategoryUnlockedCollectibles = GetCollectibleSubCategoryInfo(categoryIndex, subCategoryIndex)

            for collectibleIndex=1, subCategoryNumCollectibles do

                local collectibleId = GetCollectibleId(categoryIndex, subCategoryIndex, collectibleIndex)
                local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
                --Only mounts
                if categoryType == COLLECTIBLE_CATEGORY_TYPE_MOUNT then
                    local mountsAreEnabled = subCategoryUnlockedCollectibles > 0
                    if mountsAreEnabled then
                        if unlocked and not IsCollectibleBlocked(collectibleId) then
                            if not MountData[collectibleId] then
                                local mountName = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName)
                                MountData[collectibleId] = mountName
                            end
                        end
                    end
                end
            end
        end

        for collectibleIndex=1, numCollectibles do

            local collectibleId = GetCollectibleId(categoryIndex, nil, collectibleIndex)
            local collectibleName, _, _, _, unlocked, _, _, categoryType = GetCollectibleInfo(collectibleId)
            if categoryType == COLLECTIBLE_CATEGORY_TYPE_MOUNT then
                if unlocked and not IsCollectibleBlocked(collectibleId) then
                    if not MountData[collectibleId] then
                        local mountName = zo_strformat(SI_COLLECTIBLE_NAME_FORMATTER, collectibleName)
                        MountData[collectibleId] = mountName
                    end
                end
            end

        end

    end
    FCOMounty.MountData = MountData
end

--Get the mount from the settings by help of the zone name, and subzone name
--Get the mount from the settings by help of the zone name, and subzone name
function FCOMounty.GetMountByZone(zone, subZone)
--d("[FCOMounty.GetMountByZone]1) zone: " .. tostring(zone) .. ", subZone: " .. tostring(subZone))
    local mountToUse = 0
    if GetMapType() <= MAPTYPE_ZONE  then
        local settings = FCOMounty.settingsVars.settings
        local settingsZone2Mount = settings.zone2Mount
        --Use the -ALL- entry mount for all the subZone mounts?
        if subZone == nil and settings.useSubzoneALLMountInAllSubzones then
            subZone = FCOM_ALL_ENTRIES
        end
        if zone == nil or subZone == nil then
            zone, subZone = FCOMounty.GetZoneAndSubzone()
        end
--d("[FCOMounty.GetMountByZone]2) zone: " .. tostring(zone) .. ", subZone: " .. tostring(subZone))
        if zone == FCOM_ALL_ENTRIES or zone == FCOM_NONE_ENTRIES then
            return 0 -- No zone specified: Abort
        end
        if subZone == FCOM_ALL_ENTRIES or subZone == FCOM_NONE_ENTRIES then
            --Do not use the -ALL- entry mount for all the subZone mounts? Or is no subzone selected? Then clear it. Else keep it.
            if subZone ~= FCOM_ALL_ENTRIES or (subZone == FCOM_ALL_ENTRIES and not settings.useSubzoneALLMountInAllSubzones) then
                subZone = nil
            end
        end
        local zoneData = FCOMounty.GetZoneData(zone, subZone)
        if zoneData ~= nil then
--d(">found zoneData, subZone: " ..tostring(subZone))
            --Use the zone or subZone name to get the saved mount for it
            local tryZoneAndSubZoneMount = false
            if zone ~= nil and settingsZone2Mount[zone] ~= nil then
                --Subzone is -ALL-?
                if subZone ~= nil and subZone == FCOM_ALL_ENTRIES then
                    --Use the subZones -ALL- mount for all subzones, even if another mount was set for the current subzone
                    if settings.useSubzoneALLMountInAllSubzones then
                        --Use the zone.mountId (the -ALL- subZone mountId will be saved to the zone.mountId)
                        if settingsZone2Mount[zone] ~= nil then
                            mountToUse = settingsZone2Mount[zone].mountId
                        end
                    else
                        tryZoneAndSubZoneMount = true
                    end
                else
                    tryZoneAndSubZoneMount = true
                end
                --Try to use the saved zone AND subZone mount Id?
                if tryZoneAndSubZoneMount then
                    --Use the zone and subZone mountId
                    if subZone ~= nil and settingsZone2Mount[zone] ~= nil and settingsZone2Mount[zone][subZone] ~= nil then
                        mountToUse = settingsZone2Mount[zone][subZone].mountId
                    --Use the zone mountId (-ALL subZone) as subZone mountId is not set yet
                    elseif settingsZone2Mount[zone] ~= nil then
                        mountToUse = settingsZone2Mount[zone].mountId
                    end
                end
                --[[
                --Mount couldn't be determined yet? Use only the zone data
                if mountToUse == 0 then
                    if settingsZone2Mount[zone].mountId ~= nil then
                        mountToUse = settingsZone2Mount[zone].mountId
                    end
                end
                ]]
            end
        end
    end
--d("<mountToUse: " ..tostring(mountToUse))
    return mountToUse
end

--Get the currently active/used mount ID from the collectibles
function FCOMounty.GetActiveMount()
    local activeMoundId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
    if activeMoundId == nil or activeMoundId == 0 then
        -- * GetCollectibleInfo(*integer* _collectibleId_)
        -- ** _Returns:_ *string* _name_, *string* _description_, *textureName* _icon_, *textureName* _deprecatedLockedIcon_, *bool* _unlocked_, *bool* _purchasable_, *bool* _isActive_, *[CollectibleCategoryType|#CollectibleCategoryType]* _categoryType_, *string* _hint_, *bool* _isPlaceholder_
        for _, mountId in ipairs(FCOMounty.DropdownMountValues) do
            local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint, isPlaceholder = GetCollectibleInfo(mountId)
            --d(">name: " .. tostring(name) .. ", unlocked: " ..tostring(unlocked) .. ", isActive: " .. tostring(isActive))
            if isActive then
                return mountId
            end
        end
    end
    return activeMoundId
end

--Set the visible enhancements of the mount now
function FCOMounty.SetMountVisibleEnhancements(mountEnhancementData)
    if mountEnhancementData == nil then return nil end
    --Get the data to set now
    local speedData = mountEnhancementData[RIDING_TRAIN_SPEED]
    local staminaData = mountEnhancementData[RIDING_TRAIN_STAMINA]
    local inventoryData = mountEnhancementData[RIDING_TRAIN_CARRYING_CAPACITY]
    --Get the keys for the settings function now
    local gameSettingsShowMountEnhancement = FCOMounty.gameSettings
    local settingsCategory = gameSettingsShowMountEnhancement.settingsCategories
    local settingsId = gameSettingsShowMountEnhancement.settingsIDs
    --Set the data now
    FCOMounty.setGameSettings(settingsCategory[RIDING_TRAIN_SPEED], settingsId[RIDING_TRAIN_SPEED], speedData)
    FCOMounty.setGameSettings(settingsCategory[RIDING_TRAIN_STAMINA], settingsId[RIDING_TRAIN_STAMINA], staminaData)
    FCOMounty.setGameSettings(settingsCategory[RIDING_TRAIN_CARRYING_CAPACITY], settingsId[RIDING_TRAIN_CARRYING_CAPACITY], inventoryData)
end

--Mount on the mount now
function FCOMounty.ChooseMountNow(mountId, mountEnhancementData, onlyMountEnhancementDataUpdate)
    if mountId == nil or mountId == 0 then return false end
    onlyMountEnhancementDataUpdate = onlyMountEnhancementDataUpdate or false
--d("FCOMounty.ChooseMountNow - mountId: " .. tostring(mountId) .. ", onlyMountEnhancementDataUpdate: " .. tostring(onlyMountEnhancementDataUpdate))
    --Is the mouse enhancement data given?
    if mountEnhancementData ~= nil then
        --Set the visible mount enhancements for the zone now
        FCOMounty.SetMountVisibleEnhancements(mountEnhancementData)
    end
    --Only update the mount enhancement data and do not change te collectible?
    if onlyMountEnhancementDataUpdate then return false end
    FCOMounty.preventerVars.doNotChangePresetMount = true
    UseCollectible(mountId)
    return true
end

--Get a single mount enhancement types for a zone and subzone
function FCOMounty.getMountEnhancementForZone(mountEnhancementType, zone, subZone)
    local gameSettingsShowMountEnhancement = FCOMounty.gameSettings
    local settingsCategory = gameSettingsShowMountEnhancement.settingsCategories
    local settingsId = gameSettingsShowMountEnhancement.settingsIDs
    local settings = FCOMounty.settingsVars.settings
    --No subzone or ALL: Use zone only
    if subZone == nil or (subZone ~= nil and subZone == FCOM_ALL_ENTRIES) then
        if settings.zone2Mount[zone] == nil or settings.zone2Mount[zone].mountEnhancements == nil then return nil end
        return settings.zone2Mount[zone].mountEnhancements[mountEnhancementType]
    --Subzone given: Use zone and subZone
    else
        if settings.zone2Mount[zone] == nil or settings.zone2Mount[zone][subZone] == nil or settings.zone2Mount[zone][subZone].mountEnhancements == nil then return nil end
        return settings.zone2Mount[zone][subZone].mountEnhancements[mountEnhancementType]
    end
    return nil
end

--Get all the mount's enhancement types for a zone and subzone
function FCOMounty.getMountEnhancementsForZone(zone, subZone)
    local gameSettingsShowMountEnhancement = FCOMounty.gameSettings
    local settingsCategory = gameSettingsShowMountEnhancement.settingsCategories
    local settingsId = gameSettingsShowMountEnhancement.settingsIDs
    local mountEnhancementData = {}
    mountEnhancementData[RIDING_TRAIN_SPEED]             = FCOMounty.getMountEnhancementForZone(RIDING_TRAIN_SPEED, zone, subZone)
    mountEnhancementData[RIDING_TRAIN_STAMINA]           = FCOMounty.getMountEnhancementForZone(RIDING_TRAIN_STAMINA, zone, subZone)
    mountEnhancementData[RIDING_TRAIN_CARRYING_CAPACITY] = FCOMounty.getMountEnhancementForZone(RIDING_TRAIN_CARRYING_CAPACITY, zone, subZone)
    return mountEnhancementData
end

--Check the zone & subzone mount settings and set the collectible as active now, if already set for the zone & subzone
function FCOMounty.ActivateMountForZone(zone, subZone, override, onlyUpdateMountVisibleEnhancements, updateMountEnh)
    onlyUpdateMountVisibleEnhancements = onlyUpdateMountVisibleEnhancements or false
    updateMountEnh = updateMountEnh or false
    override = override or false
    --Should the current zone info not be relevant and the update to the mount from the settings is needed?
    --e.g. if turning off the settings for the "preset mount from collectibles" and changing the mount in the collectibles
    --afterwards
    if FCOMounty.preventerVars.getMountFromSettingsNow or FCOMounty.preventerVars.manuallyMountChosen or onlyUpdateMountVisibleEnhancements then
        override = true
        if FCOMounty.preventerVars.getMountFromSettingsNow then FCOMounty.preventerVars.getMountFromSettingsNow = false end
        if FCOMounty.preventerVars.manuallyMountChosen then FCOMounty.preventerVars.manuallyMountChosen = false end
    end
    --Get the chosen mount for this zone and subzone
    if zone == nil then
        zone, subZone = FCOMounty.GetZoneAndSubzone()
    end
    local settings = FCOMounty.settingsVars.settings
    --Subzone is found but the setting to use the ALL subZone mount is activated: Use zone only
    --Use the -ALL- entry mount for all the subZone mounts? Or is no subZone selected? Then clear it. Else keep it.
    if settings.useSubzoneALLMountInAllSubzones then
        --Set the subZone to "-ALL-"
        subZone = FCOM_ALL_ENTRIES
        --Is a mount specified for the zone + subZone -ALL-?
        --Mount was set for the zone + subZone -ALL-, so clear the subZone and use the zone's -ALL- mount like enabled in the settings
        local chosenMountId = FCOMounty.LoadMountIdFromSettings(zone, subZone)
        if chosenMountId == nil or chosenMountId == 0 then subZone = nil end
    end
--d("ActivateMountForZone - zone: " .. tostring(zone) .. ", subZone: " .. tostring(subZone) .. ", override: " ..tostring(override))
    if override or (FCOMounty.preventerVars.lastZone ~= zone or (FCOMounty.preventerVars.lastZone == zone and FCOMounty.preventerVars.lastSubZone ~= subZone)) then
        FCOMounty.preventerVars.lastZone = zone
        FCOMounty.preventerVars.lastSubZone = subZone
    else
--d("<<ABORTED: Same zone / subzone")
        return false
    end
    --Get the mount from the settings by help of the zone name, and subzone name
    local mountId = FCOMounty.GetMountByZone(zone, subZone)
    --Get the mounts shown enhancements, if mount was chosen
    local mountEnhancementData
    if mountId ~= 0 then
        if updateMountEnh == true then
            mountEnhancementData = {}
            mountEnhancementData = FCOMounty.getMountEnhancementsForZone(zone, subZone)
        end
    end
--d(">mountId: " .. tostring(mountId) .. ", mountName:  " .. ZO_CachedStrFormat("<<C:1>>", GetCollectibleInfo(mountId)) .. ", mountEnhancementUpdate: " ..tostring(onlyUpdateMountVisibleEnhancements))
    --Was a mount chosen? Then activate it now
    if mountId ~= nil and mountId ~= 0 then
        return FCOMounty.ChooseMountNow(mountId, mountEnhancementData, onlyUpdateMountVisibleEnhancements)
    end
    return false
end

--Check if the currently active mount is the one to be used for the zone & subzone, and if not set the active mount as
--the one for the zone & subzone now!
function FCOMounty.checkAndPresetMountForZone()
    local presetMount = false
    --Get the chosen mount for this zone and subzone
    local zone, subZone = FCOMounty.GetZoneAndSubzone()
    --Get the mount from the settings by help of the zone name, and subzone name
    local savedMountIdForZone = FCOMounty.GetMountByZone(zone, subZone)
    --Get the actively used mount
    local activeMountId = FCOMounty.GetActiveMount()

--d("[FCOMounty.checkAndPresetMountForZone] zone: " .. tostring(zone) ..", subZone: " .. tostring(subZone) .. ", savedMountIdForZone: " ..tostring(savedMountIdForZone) .. ", activeMountId: " .. tostring(activeMountId))

    --Is any mount set for the current zone and subzone yet?
    if savedMountIdForZone == nil or savedMountIdForZone == 0 then
        --No mount set yet so just set it now
        presetMount = true
    else
        --The mount set in the settings for the current zone & subzone is not the actively chosen mount?
        if savedMountIdForZone ~= activeMountId then
            presetMount = true
        end
    end
    --Should the mount be saved as preset mount for the zone & subzone now?
--d(">presetMount: " ..tostring(presetMount))
    if presetMount then
        --Get the current game settings for the visible mount enhancements
        local mouseEnhancementData = {}
        --Use addon setings
        mouseEnhancementData = FCOMounty.getMountEnhancementsForZone(zone, subZone)
        --No addon settings given so use the game settings
        if mouseEnhancementData == nil then
            mouseEnhancementData = FCOMounty.GetGameSettingsMountVisibleEnhancements()
        end
        --Set the current active mount as new mount now
        FCOMounty.SaveMountIdToSettings(activeMountId, false, zone, subZone, mouseEnhancementData)
    end
end