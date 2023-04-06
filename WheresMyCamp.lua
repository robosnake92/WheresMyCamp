--default to be replaced by stored variable
CampLocation = "Unknown";

--spell IDs
makeCampId = 312370;
returnToCampId = 312372;

--create the frame and register the events we care about
local frame = CreateFrame("FRAME", "");
frame:RegisterEvent("VARIABLES_LOADED");
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");

--add the location to the Return to Camp tooltip
local displayLocation = function(tooltip)
	local _, id = tooltip:GetSpell()
	if (id == returnToCampId) then
		tooltip:AddLine("Location: "..CampLocation, 1, 1, 1)
		tooltip:Show()
	end
end

--hook into the tooltips
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, displayLocation)

--handle the events
local function eventHandler(self, event, ...)
	--load the stored variable if it exists
	if (event == "VARIABLES_LOADED") then
		CampLocation = CampLocation;		
	end
	--a spell was cast
	if (event == "UNIT_SPELLCAST_SUCCEEDED") then
		--check if vulperia and if not unregister UNIT_SPELLCAST_SUCCEEDED since you can't ever return to camp
		local _, raceEN = UnitRace("player");
	
		if (raceEN ~= "Vulpera") then
			frame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
			return;
		end
	
		local _, _, spellID = ...;
		wheresMyCamp(spellID);
	end
end

--set the event handler
frame:SetScript("OnEvent", eventHandler);

--setup the slash command to print the camp location
SLASH_WHERESMYCAMP1 = "/wmc";
function SlashCmdList.WHERESMYCAMP(msg)
	print("Camp Location: "..CampLocation);
end

--we cast a spell, check if it's Make Camp and store the zone
function wheresMyCamp(spellID)	
	if (spellID == makeCampId) then
		--we're camping, figure out where we are
		local zoneName = GetZoneText();
		local subZoneName = GetSubZoneText();
		
		--check if we have a subzone, if so make the tooltip more accurate
		CampLocation = zoneName;
		if (subZoneName ~= "" and zoneName ~= subZoneName) then
			CampLocation = subZoneName..", "..zoneName;
		end
	end
end
