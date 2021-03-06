------------------------------------------------------
-- # Title : Base Butler 
------------------------------------------------------
-- # Description : A Modded-Minecraft Automation Assistant 
-- #             - built in 'Computer Craft'/'CC: Tweaked' and 'Advanced Peripherals'.
------------------------------------------------------


---------------------------
-- # Member Variable Declarations 
---------------------------

Monitor = nil --peripheral.find("monitor")
ChatBox = nil --peripheral.find("chatBox")

Scale = 1

PosX = Scale
PosY = Scale
    
CommandUser = "Broomfields"     --Change to your user name
CommandPhrase = "BB"       --Change to your assistant name

CommandPhraseLength = string.len(CommandPhrase)

Programs = {};
table.insert(Programs, "Information")
table.insert(Programs, "Update")            -- Set And Get
table.insert(Programs, "Reboot")
table.insert(Programs, "Message")
table.insert(Programs, "Message")
table.insert(Programs, "Speak")
table.insert(Programs, "CommandUser")       -- Set And Get
table.insert(Programs, "CommandPhrase")     -- Set And Get
table.insert(Programs, "Label")             -- Set And Get
table.insert(Programs, "MonitorColour")     -- Set And Get
table.insert(Programs, "MonitorTextColour") -- Set And Get
table.insert(Programs, "MonitorScale")      -- Set And Get
table.insert(Programs, "Mute")              -- Set And Get

-- Set And Get Power Networks (Network is defined with ID and has configurable ports)
table.insert(Programs, "Power")  -- Network{On, Off}, Network{Set, Edit, Remove [Input, Output] ports}, Network{List [Input, Output, All] ports and networks}, Network{Measure (Total Difference, Active Difference, Active Rate)}, Network{Ratio}


os.loadAPI("BaseButler/utility.lua")
os.loadAPI("BaseButler/peripherals.lua")
os.loadAPI("BaseButler/interaction.lua")


---------------------------
-- # Assistant Core Functions 
---------------------------


-- Asserts that a command is present in the given text
function AssertCommand(text)

    if (text ~= nil) then

        if (string.len(text) >= CommandPhraseLength) then

            local comparison = string.sub(text, 1, CommandPhraseLength)
            print("### Command Assertion ###")
            print("Text: '" .. text .. "'")
            print("Subbed Comparison: '" .. comparison .. "'")
            print("Command Phrase: '" .. CommandPhrase .. "'")
            print("### End Command Assertion ###")

            if (string.upper(comparison) == string.upper(CommandPhrase)) then
                -- Command Found
                return true
            end 

        end

    else

        print("Error - AssertCommand(text) - text == nil")

    end

    -- Command Not Found
    return false
end


-- Parses identified command line in chat and calls relevant program
function ParseCommand(text)
    
    if (text ~= nil) then
        local parts = utility.Split(text)
        local commandPhraseIndex = -1
        local commandProgramIndex = -1
        local matchedProgram = nil
        
        local programsCount = utility.Count(Programs)
        local partsCount = utility.Count(parts)
        
        print("[DEBUG] Parts Count = " .. partsCount)

        local partIndex = 0 -- lua indexes start at 1, so increment at start
        while (partIndex < partsCount) do

            partIndex = partIndex + 1

            local part = parts[partIndex]

            print("[DEBUG] Parts Index = " .. partsCount .. " | Part = " .. part)

            -- Identify Command Phrase
            if (commandPhraseIndex == -1) then
                
                if (string.upper(part) == string.upper(CommandPhrase)) then
                    commandPhraseIndex = partIndex
                end

            -- Identify Command / Program
            elseif (commandProgramIndex == -1) then

                print("[DEBUG] Program Count = " .. programsCount)

                local programIndex = 1 -- lua indexes start at 1, so increment at start      
                while (programIndex < programsCount) do
                    programIndex = programIndex + 1

                    local program = Programs[programIndex]

                    print("[DEBUG] Program Index = " .. programIndex .. " | Program = " .. program)

                    if (string.upper(part) == string.upper(program)) then
                        commandProgramIndex = programIndex
                        matchedProgram = Programs[programIndex]
                        print("[DEBUG] Program Matched!")
                        break
                    end

                    os.sleep(0) -- Allow for thread to yield
                end

                if (matchedProgram ~= nil) then
                    break
                end

            end

            -- Run Identified Program
            if (matchedProgram ~= nil) then -- Maybe add option for searching args later
                print("[DEBUG] Running Program: " .. Programs[programIndex])
                RunProgram(Programs[programIndex])
                return true
            end

        end

        os.sleep(0) -- Allow for thread to yield
    end

    return false
end


-- Runs given program
function RunProgram(text)

    if (text ~= nil) then
        -- ToDo
        -- Find Program Location (Probably just a programs folder)
        -- Run Program
    end

end



-- Main Process Function (TODO : Turn in to State Machine)
function MainProcess()

    interaction.ComputerLine("Waiting for messages...", Monitor)
    interaction.NewLine(Monitor)

    local inError = false
    while inError == false do

        ChatBox = peripherals.AssertChatBoxPresent(ChatBox)
        Monitor = peripherals.AssertMonitorPresent(Monitor)
        interaction.RefreshDisplay(Monitor)

        local eventData = {os.pullEvent("chat")}
        local event = eventData[1]
        local username = eventData[2]
        local message = eventData[3]
            
        local monitorChatLine = ("<" .. username .. "> " .. message)
        interaction.ChatLine(monitorChatLine, Monitor)

        if (username == CommandUser) then
            if (AssertCommand(message)) then
                
                interaction.ComputerLine("~ Command Identified", Monitor)
                
                if (ParseCommand(message)) then
                    interaction.ComputerLine("~ Command Parsed", Monitor)
                else
                    interaction.ComputerLine("~ Command Not Parsed", Monitor)
                end
            end
        end

        os.sleep(1)

    end

    interaction.ComputerLine("~ Terminating Instance", Monitor) 
end



---------------------------
-- # Start Main Process 
---------------------------

MainProcess()