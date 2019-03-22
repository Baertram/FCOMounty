if FCOM == nil then FCOM = {} end
local FCOMounty = FCOM

--Return the zonedata
function FCOMounty.GetZoneData(zone, subzone)
    local zoneData = FCOMounty.ZoneData
    local zoneGiven     = zone ~= nil and type(zone) == "string" and zone ~= ""
    local subZoneGiven  = subzone ~= nil and subzone ~= "" and subzone ~= "zoneId" and subzone ~= FCOM_NONE_ENTRIES and subzone ~= FCOM_ALL_ENTRIES
    local subZoneNotOrALLGiven = subzone == nil or (subzone ~= nil and subzone == FCOM_ALL_ENTRIES)
--d("[FCOMounty.GetZoneData] zone: " .. tostring(zone) .. ", subZone: " ..tostring(subzone))
    local debugOutput = false
    if zoneGiven and subZoneGiven then
        if zoneData[zone] and zoneData[zone][subzone] then
            return zoneData[zone][subzone]
        else
            debugOutput = true
        end
    elseif zoneGiven and (subZoneGiven or subZoneNotOrALLGiven) then
        if zoneData[zone] then
            return zoneData[zone]
        else
            debugOutput = true
        end
    end
    --Show debug output about zone/subZone missing?
    local settings = FCOMounty.settingsVars.settings
    if debugOutput and settings.debug == true then
        local isInDungeon, isInDelve = FCOMounty.isPlayerInDungeon()
        if not isInDungeon and not isInDelve then
            local zoneIndex = GetCurrentMapZoneIndex()
            local zoneId, parentZoneId
            if zoneIndex ~= nil then
                zoneId = GetZoneId(zoneIndex)
                if zoneId ~= nil then parentZoneId = GetParentZoneId(zoneId) end
            end
            d(">========================================>")
            d("[FCOMounty] The current zone data is missing. Please contact @Baertram ingame (EU server, via mail) and write him a PM, or an addon comment.")
            d("\n->You are able to open the FCOMounty addon comment website at www.esoui.com via the FCOMounty settings: ESC->Settings->AddOn settings->FCO Mounty->Visit website! or via the chat command /fcoms.")
            d("\nTell him the following text line please:")
            if subzone ~= nil and subzone ~= "" then
                d(">Zone: " ..tostring(zone) .. " (id/parent: " .. tostring(zoneId) .. "/" .. tostring(parentZoneId) .. "), subZone: " ..tostring(subzone))
            else
                d(">Zone: " ..tostring(zone) .. " (id/parent: " .. tostring(zoneId) .. "/" .. tostring(parentZoneId) .. ")")
            end
            d("<========================================<")
        end
    end
    --Return nil if nothing relevant was found
    return nil
end

--Map the zone and subzone to a "better explanatory name" as zone "Darkbrotherhood" e.g. should be "Goldcoast"
function FCOMounty.MapZoneAndSubZoneNames(zone, subzone)
    --Zone or subzone are given?
    if zone == nil or zone == "" then return zone, subzone end
    local zones = FCOMounty.ZoneData
    if zones == nil then return zone, subzone end
    local subZones = zones[zone]
    if subZones == nil then return zone, subzone end
    local mappedSubZoneName = ""
    if subzone ~= nil then
        local mappedSubZoneNameTmp = subZones[subzone] or ""
        --The subzone vale is a true/false-> No mapping name is given
        if type(mappedSubZoneNameTmp) == "boolean" then
            --Reset the mapped subzone name to empty string so the subzone name will be used
            mappedSubZoneName = ""
            --The subzone vale is a String-> A mapping name is given
        elseif type(mappedSubZoneNameTmp) == "string" and mappedSubZoneNameTmp ~= "" then
            --Reset the mapped subzone name to empty string so the subzone name will be used
            mappedSubZoneName = mappedSubZoneNameTmp
        end
    end
    local mappedZoneName = subZones[FCOM_ZONE_MAPPING_STRING] or ""
    if mappedZoneName == "" then mappedZoneName = zone end
    if mappedSubZoneName == "" then mappedSubZoneName = subzone end
    --Check if a mapped zonename exists
    return mappedZoneName, mappedSubZoneName
end

--Get the zone and subZone string from libMapPins
function FCOMounty.GetZoneAndSubzone()
    --Single function code taken from library libMapPins, original authors: Garkin, Ayantir, Fyrakin, Sensi
    --> All credits go to them!
    -- Returns zone and subzone derived from map texture. Format: zone, subZone
    local zone, subzone =  select(3,(GetMapTileTexture()):lower():find("maps/([%w%-]+)/([%w%-]+_[%w%-]+)"))
    return zone, subzone
end

--Get the zone and subZone string from libMapPins and post them into the chat
function FCOMounty.zone2Chat()
    local zone, subZone = FCOMounty.GetZoneAndSubzone()
    if zone == nil then zone = "<n/a>" end
    if subZone == nil then subZone = "<n/a>" end
    d("[FCOMounty] Current zone: " .. tostring(zone) .. ", current subzone: " .. tostring(subZone))
end
