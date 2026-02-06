-- PREMIUM 12-HOUR ONE-TIME KEY SYSTEM (AUTO SHOW PANEL, FULL WEBHOOK)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

-- ================= SETTINGS =================
local RAW_KEYS_URL = "https://raw.githubusercontent.com/kielsvu/Utility/refs/heads/Lua/Utility/Major/Main.txt"
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1466776018319835187/HIoanp_dtf9HvFqD7HfDCsJDnaJ53oTVNNqEXyKkP4by_pM2i99Qay7K-yzXlCrwcsma"
local devKey = "GarciaTorres"
local devUserId = 2612722358
local KEY_EXPIRATION_HOURS = 12
local submitDelay = 1

local links = {
    Primary = "https://kielkeyhandler.github.io/SystemPanel/",
    Backup = "https://kielkeyhandler.github.io/SystemPanel/",
    Discord = "https://discord.gg/yourdiscord"
}

-- ================= FILE PERSISTENCE =================
local mainFolder = "Garcia'sScripts"
local keysFolder = mainFolder.."/Keys"
local usedKeysFile = keysFolder.."/used_keys.json"

if not isfolder(mainFolder) then makefolder(mainFolder) end
if not isfolder(keysFolder) then makefolder(keysFolder) end

local UsedKeys = {}
if isfile(usedKeysFile) then
    UsedKeys = HttpService:JSONDecode(readfile(usedKeysFile))
end

local function SaveUsedKeys()
    writefile(usedKeysFile, HttpService:JSONEncode(UsedKeys))
end

local function IsKeyValid(key)
    return not UsedKeys[key] -- one-time use
end

local function MarkKeyUsed(key)
    UsedKeys[key] = os.time()
    SaveUsedKeys()
end

-- ================= FETCH KEYS =================
local CachedKeys = {}
local function FetchKeys()
    local success, data = pcall(function()
        return game:HttpGet(RAW_KEYS_URL)
    end)
    if not success then return end

    table.clear(CachedKeys)
    for line in string.gmatch(data, "[^\r\n]+") do
        CachedKeys[line] = true
    end
end
FetchKeys()

-- ================= DEVICE + GAME =================
local function GetDevice()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    elseif UserInputService.GamepadEnabled then
        return "Console"
    else
        return "PC"
    end
end

local function GetGameName()
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    return ok and info.Name or "Unknown"
end

-- ================= DISCORD WEBHOOK =================
local function SendWebhook(keyUsed)
    if not LocalPlayer or not LocalPlayer.Parent then return end
    if not DISCORD_WEBHOOK or DISCORD_WEBHOOK == "" then return end

    local data = {
        content = string.format(
            "**Key Used**\nUsername: %s\nUserId: %s\nKey: %s\nGame: %s\nDevice: %s",
            LocalPlayer.Name,
            LocalPlayer.UserId,
            keyUsed,
            GetGameName(),
            GetDevice()
        )
    }

    pcall(function()
        HttpService:PostAsync(DISCORD_WEBHOOK, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
end

-- ================= UI CREATION FUNCTION =================
local function CreateKeyPanel()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(0, 350, 0, 280)
    Panel.Position = UDim2.new(0.5, -175, 0.5, -140)
    Panel.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Panel.BorderSizePixel = 0
    Panel.Parent = ScreenGui
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0,20)
    local Stroke = Instance.new("UIStroke", Panel)
    Stroke.Color = Color3.fromRGB(178,132,255)
    Stroke.Thickness = 2

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 15)
    Title.BackgroundTransparency = 1
    Title.Text = "Garcia's Scripts"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 20
    Title.TextColor3 = Color3.fromRGB(240,240,240)
    Title.Parent = Panel

    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(0, 310, 0, 30)
    KeyBox.Position = UDim2.new(0,20,0,60)
    KeyBox.BackgroundColor3 = Color3.fromRGB(40,40,45)
    KeyBox.TextColor3 = Color3.fromRGB(240,240,240)
    KeyBox.PlaceholderText = "Enter Key"
    KeyBox.Font = Enum.Font.SourceSansBold
    KeyBox.TextSize = 16
    KeyBox.ClearTextOnFocus = false
    KeyBox.Parent = Panel
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0,15)

    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.Size = UDim2.new(0,120,0,30)
    VerifyBtn.Position = UDim2.new(0.5, -60, 0, 100)
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(40,40,45)
    VerifyBtn.Text = "Verify"
    VerifyBtn.Font = Enum.Font.SourceSansBold
    VerifyBtn.TextSize = 16
    VerifyBtn.TextColor3 = Color3.fromRGB(240,240,240)
    VerifyBtn.BorderSizePixel = 0
    VerifyBtn.Parent = Panel
    Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0,15)

    local function Tween(obj, props, time)
        TweenService:Create(obj, TweenInfo.new(time), props):Play()
    end
    VerifyBtn.MouseEnter:Connect(function() Tween(VerifyBtn,{BackgroundColor3=Color3.fromRGB(65,65,75)},0.2) end)
    VerifyBtn.MouseLeave:Connect(function() Tween(VerifyBtn,{BackgroundColor3=Color3.fromRGB(40,40,45)},0.2) end)

    -- ================= LINK BUTTONS =================
    local function CreateLinkBtn(name,x,y,link)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,90,0,25)
        btn.Position = UDim2.new(0,x,0,y)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,45)
        btn.Text = name
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(240,240,240)
        btn.BorderSizePixel = 0
        btn.Parent = Panel
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)
        btn.MouseEnter:Connect(function() Tween(btn,{BackgroundColor3=Color3.fromRGB(65,65,75)},0.2) end)
        btn.MouseLeave:Connect(function() Tween(btn,{BackgroundColor3=Color3.fromRGB(40,40,45)},0.2) end)
        btn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(link)
            end
        end)
    end

    -- Original positions
    CreateLinkBtn("Primary Key", 20, 150, links.Primary)
    CreateLinkBtn("Backup Key", 120, 150, links.Backup)
    CreateLinkBtn("Discord", 220, 150, links.Discord)

    -- ================= VERIFY LOGIC =================
    VerifyBtn.MouseButton1Click:Connect(function()
        local key = KeyBox.Text
        local valid = false

        -- Dev key
        if key == devKey then
            SendWebhook(key)
            if LocalPlayer.UserId == devUserId then
                valid = true
            else
                LocalPlayer:Kick("Access denied!\nOnly developers can use this key")
                return
            end
        end

        -- Normal keys
        if CachedKeys[key] and IsKeyValid(key) then
            valid = true
            SendWebhook(key)
        end

        if valid then
            VerifyBtn.Text = "Access Granted"
            MarkKeyUsed(key)

            -- Load tap simulator
            task.spawn(function()
                loadstring(game:HttpGet(
                    "https://gist.githubusercontent.com/gerelyncontiga-dot/de66cf3790f609468117ecebda06c30d/raw/e5f3f65ec51fccf22588fc7f455de77d247f7ad1/Tap%2520simulator%2520v41.lua"
                ))()
            end)

            task.delay(submitDelay,function()
                ScreenGui:Destroy()
            end)
        else
            VerifyBtn.Text = "Invalid or Expired Key"
            task.delay(submitDelay,function()
                VerifyBtn.Text = "Verify"
            end)
        end
    end)

    -- ================= DRAGGING =================
    local dragging, dragInput, mousePos, framePos = false,nil,nil,nil
    Panel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = Panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Panel.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            Panel.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X,
                                       framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- ================= AUTO SHOW PANEL =================
CreateKeyPanel()
