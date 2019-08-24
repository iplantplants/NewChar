characterAge = characterAge or nil;
newCharacter = newChar or true;
addonState = addonState or true;

function cleanBars() --exactly what Litzzik posted

    for i = 1,120 do 
        PickupAction(i);
        ClearCursor() 
    end


end

commandHelp = {
    ["CLEAN"] = 
    {
        ["bags"] = "Empty bags.",
        ["bars"] = "Empty action bars.",
        ["gear"] = "Remove currently equipped items.",
    },
    ["TOGGLE"] = 
    {
        ["ON"] = "Enables automatic cleaning of new characters.",
        ["OFF"] = "Disables automatic cleaning of new characters.",
    },
    ["HELP"] =
    {
        [""] = "Displays list of available commands."
    },
    --["RESET"] = "{DEBUG} Reset variables."
}

function helpMessage()
    local helpMessage = "|cff00ccff[NewChar]|r";
    for k,v in pairs(commandHelp) do
        if type(v) == "table" then
            --helpMessage = helpMessage .. "• |cff00ccff/nc "..k.." ";
            for k1,v1 in pairs(v) do
                helpMessage = helpMessage .. "\n• |cff00ccff/nc "..k:lower().." "..k1:lower().."|r - "..v1;
            end
        end
    end
    return helpMessage;
end

function cleanGear()

    local slots =
    {   1,  --head
        2,  --neck
        3,  --shoulder
        4,  --shirt
        5,  --chest
        6,  --belt
        7,  --legs
        8,  --feet
        9,  --wrist
        10, --gloves
        11, --ring1
        12, --ring2
        13, --trinket1
        14, --trinket2
        15, --back
        16, --main hand
        17, --off hand
        19  }; --tabard

    for k,v in pairs(slots) do 
        PickupInventoryItem(v); 
        PutItemInBackpack(); 
    end

end

function cleanBags()

    for bag=0,4 do 
        for slot=1, GetContainerNumSlots(bag) do 
            PickupContainerItem(bag,slot); 
            DeleteCursorItem(); 
        end 
    end

end


--Character age verification so the addon doesn't wipe things from old characters
function getAge()

    if characterAge == nil then
        RequestTimePlayed();
    end

    if characterAge < 1 then
        newCharacter = true;
    else
        newCharacter = false;
    end
    return newCharacter;
end

--Get played time
newCharTimer = CreateFrame("Frame");
newCharTimer:RegisterEvent("TIME_PLAYED_MSG")
newCharTimer:SetScript("OnEvent", function(self, event, timePlayed)
    
    characterAge = timePlayed / 60; --stored as minutes
    print(event, timePlayed, characterAge)
    
end)

newChar = CreateFrame("Frame");
newChar:RegisterEvent("PLAYER_ENTERING_WORLD")

newChar:SetScript("OnEvent", function(self, event, addon)       
        --First check to see if the character is new by putting in a request to get time played message.
    RequestTimePlayed();

        --Timer to ensure characterAge variable is populated.

        C_Timer.NewTicker(3, function(self)

            --print("GET AGE",characterAge, "New Character?", getAge())
            if addonState == true then
                if getAge() == true then
                    print("|cff00ccffNew character? No problem.|r")
                    cleanGear();
                    cleanBars();
                    C_Timer.NewTicker(1, function(self)
                    cleanBags();
                    end,1)
                    newCharacter = false;
                end
            end

        end,1)
end)


SLASH_NC1, SLASH_NC2 = '/nc', '/NC';
local function handler(message, editBox)

    if message:match("reset") then

    characterAge = nil;
    newCharacter = nil;
    print("Reset variables", characterAge, newChar)

    
    elseif message:match("toggle") then
        if addonState == true or message:match("off") then
            addonState = false;
            print("|cff00ccff[NewChar]|r is now |cffff0000Off|r.")
        elseif addonState == false or message:match("on") then
            addonState = true;
            print("|cff00ccff[NewChar]|r is now |cff00ff00On|r.")
        end

    elseif message:match("test") then
        RequestTimePlayed();
        C_Timer.NewTicker(3, function(self)

            getAge();
            --print("GET AGE",characterAge, "New Character?", getAge())

        end,1)

    elseif message:match("help") then
        print(helpMessage())
        print("|cff00ccff[/NewChar]|r")

    elseif message:match("clean") then

        if message:match("bags") then
            cleanBags();
            print("|cff00ccff[NewChar]|r Emptied bags.")
        elseif message:match("bars") then
            cleanBars();
            print("|cff00ccff[NewChar]|r Cleaned action bars.")
        elseif message:match("gear") then
            cleanGear();
            print("|cff00ccff[NewChar]|r Unequipped items.")
            
        end
        return true
    else

    end


end
SlashCmdList["NC"] = handler;
