--[[
    👑 EMR Bœuf Hub - Master Pro Edition 👑
    - Système d'UI à icônes 100% circulaires (Style Apple)
    - Pastille Flottante (AssistiveTouch Style) ultra-discrète, ronde et Draggable
    - Notifications Dynamic Island animées
    - Mini-Lecteur Apple Music (Style macOS) avec Slider de Volume et Playlist Chill
    - Mode Économiseur d'Énergie OLED & Interrupteur Anti-Lag (FPS Boost)
    - Sélecteur d'Armes style iOS Toggle Switches
    Sécurisation : Code secret requis (emr.rvj)
]]

-- ==========================================
-- 1. BASE DE DONNÉES DES COMPOSANTS
-- ==========================================
local PLAYLIST = {
    {Name = "☕ Lo-Fi Chill Cafe", Id = "rbxassetid://9043887091"},
    {Name = "🌌 Synthwave Drive", Id = "rbxassetid://5415525648"},
    {Name = "🌸 Anime Memory", Id = "rbxassetid://1837873410"},
    {Name = "🌙 Midnight Lullaby", Id = "rbxassetid://9042571836"}
}

local ICONS = {
    Dashboard = "rbxassetid://11418486730", 
    Farm      = "rbxassetid://10613247079", 
    Custom    = "rbxassetid://11419409341",
    LogoPastille = "rbxassetid://11419515259" -- Icône premium épurée centrale
}

local CUSTOM_DATA = {
    Wallpapers = {
        {Name = "🖤 Carbone Élite", Id = "rbxassetid://15605417446"},
        {Name = "🐅 Tigre & Grillz", Id = "rbxassetid://5309"}, 
        {Name = "🌌 Espace Profond", Id = "rbxassetid://15531481283"},
        {Name = "🔮 Aura Cyber", Id = "rbxassetid://11401835368"},
        {Name = "⬛ Noir Mat Épuré", Id = ""}
    },
    Colors = {
        {Name = "🔵 Bleu Apple", Color = Color3.fromRGB(10, 132, 255)},
        {Name = "🟡 Or Champagne", Color = Color3.fromRGB(235, 180, 90)},
        {Name = "🟢 Vert Menthe", Color = Color3.fromRGB(48, 209, 88)},
        {Name = "🔴 Rouge Rubis", Color = Color3.fromRGB(255, 69, 58)},
        {Name = "🟣 Violet Néon", Color = Color3.fromRGB(191, 90, 242)}
    }
}

local ASSETS = {
    SoundOpen  = "rbxassetid://5414349156",  
    SoundClick = "rbxassetid://8339145229",  
    SoundError = "rbxassetid://13511853870", 
    SoundValid = "rbxassetid://6421379564"   
}

-- ==========================================
-- 2. SERVICES & CONFIGURATION DE L'UI
-- ==========================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

repeat task.wait() until game:IsLoaded() and Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer

local CORRECT_PASSWORD = "emr.rvj"

local CurrentTheme = {
    AccentColor = CUSTOM_DATA.Colors[1].Color,
    Font = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    AnimStyle = Enum.EasingStyle.Exponential,
    BgColor = Color3.fromRGB(12, 12, 15),
    TextLight = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(155, 157, 165)
}

local TrackedLabels = {} local TrackedButtons = {} local TrackedStrokes = {} local TrackedScrolls = {}
local CurrentTrackIndex = 1 local CurrentActiveSound = nil local IsPlaying = false local HubOuvert = true

-- ==========================================
-- 3. UTILITAIRES ET SYSTÈMES CORE MOTEUR
-- ==========================================
local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do if k ~= "Parent" then instance[k] = v end end
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

local function Tween(instance, properties, duration)
    local info = TweenInfo.new(duration or 0.2, CurrentTheme.AnimStyle, Enum.EasingDirection.Out)
    local anim = TweenService:Create(instance, info, properties)
    anim:Play()
    return anim
end

local function PlayPremiumSound(soundId, volume)
    local sound = Instance.new("Sound") sound.SoundId = soundId sound.Volume = volume or 0.5 sound.Parent = SoundService sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

local function ApplyLuxuryStyle(frame, radius, strokeTrans, dynamicStroke)
    Create("UICorner", { CornerRadius = UDim.new(0, radius or 14), Parent = frame })
    local stroke = Create("UIStroke", { Color = dynamicStroke and CurrentTheme.AccentColor or Color3.fromRGB(255, 255, 255), Transparency = strokeTrans or 0.88, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = frame })
    if dynamicStroke then table.insert(TrackedStrokes, stroke) end
    return stroke
end

local function RefreshUIElements()
    for label, isBold in pairs(TrackedLabels) do if label and label.Parent then label.Font = isBold and CurrentTheme.FontBold or CurrentTheme.Font end end
    for _, btn in ipairs(TrackedButtons) do if btn and btn.Parent and btn.BackgroundTransparency < 1 then btn.BackgroundColor3 = CurrentTheme.AccentColor end end
    for _, stroke in ipairs(TrackedStrokes) do if stroke and stroke.Parent and stroke.Color ~= Color3.fromRGB(255,255,255) then stroke.Color = CurrentTheme.AccentColor end end
    for _, scroll in ipairs(TrackedScrolls) do if scroll and scroll.Parent then scroll.ScrollBarImageColor3 = CurrentTheme.AccentColor end end
end

-- ==========================================
-- 4. STRUCTURE DE BASE & DYNAMIC ISLAND
-- ==========================================
local MainGui = Create("ScreenGui", { Name = "EMRBoeuf_MasterPro", IgnoreGuiInset = true, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = CoreGui })

local IslandPill = Create("Frame", { Name = "DynamicIsland", Size = UDim2.new(0, 160, 0, 30), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -40), BackgroundColor3 = Color3.fromRGB(0, 0, 0), ClipsDescendants = true, Parent = MainGui })
Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = IslandPill })
Create("UIStroke", { Color = Color3.fromRGB(255,255,255), Transparency = 0.9, Thickness = 1, Parent = IslandPill })
local IslandText = Create("TextLabel", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamMedium, TextSize = 11, Parent = IslandPill })

local function TriggerIsland(text)
    IslandText.Text = text IslandPill.Position = UDim2.new(0.5, 0, 0, 15)
    Tween(IslandPill, {Size = UDim2.new(0, 240, 0, 35)}, 0.4) task.wait(2.5)
    Tween(IslandPill, {Size = UDim2.new(0, 160, 0, 30), Position = UDim2.new(0.5, 0, 0, -40)}, 0.4)
end

local MainFrame = Create("Frame", { Name = "MainFrame", Size = UDim2.new(0, 460, 0, 300), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundColor3 = CurrentTheme.BgColor, BackgroundTransparency = 0.15, BorderSizePixel = 0, ClipsDescendants = true, Parent = MainGui })
ApplyLuxuryStyle(MainFrame, 18, 0.8, false)

local Background = Create("ImageLabel", { Size = UDim2.new(1, 0, 1, 0), Image = CUSTOM_DATA.Wallpapers[1].Id, ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.5, BackgroundTransparency = 1, Parent = MainFrame })
local SoftOverlay = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(6, 6, 8), BackgroundTransparency = 0.25, Parent = MainFrame })

-- ==========================================
-- 5. CRÉATION DE LA PASTILLE FLOTTANTE DRAGGABLE
-- ==========================================
local ToggleButton = Create("TextButton", { Name = "EMR_Pastille", Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(0, 15, 0, 15), BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 0.2, Text = "", Visible = false, Parent = MainGui })
local PastilleCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleButton })
local PastilleStroke = ApplyLuxuryStyle(ToggleButton, 100, 0.7, true)

local PastilleIcon = Create("ImageLabel", { Size = UDim2.new(0, 20, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Image = ICONS.LogoPastille, BackgroundTransparency = 1, ImageColor3 = Color3.fromRGB(255,255,255), Parent = ToggleButton })
Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = PastilleIcon })

-- Logique Draggable tactile/souris pour mobile
local dragging, dragInput, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = ToggleButton.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Liaison Pastille <> Hub
ToggleButton.MouseButton1Click:Connect(function()
    PlayPremiumSound(ASSETS.SoundClick, 0.4)
    HubOuvert = not HubOuvert
    if HubOuvert then
        MainFrame.Visible = true
        Tween(MainFrame, {Size = UDim2.new(0, 460, 0, 300), BackgroundTransparency = 0.15}, 0.4)
        Tween(ToggleButton, {BackgroundTransparency = 0.6}, 0.3)
    else
        Tween(MainFrame, {Size = UDim2.new(0, 420, 0, 260), BackgroundTransparency = 1}, 0.4).Completed:Connect(function() if not HubOuvert then MainFrame.Visible = false end end)
        Tween(ToggleButton, {BackgroundTransparency = 0.2}, 0.3)
    end
end)

-- ==========================================
-- 6. ÉCRAN DE SÉCURITÉ DE DÉPART
-- ==========================================
local SecurityFrame = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = MainFrame })
local LabelTitle = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 50), Position = UDim2.new(0, 0, 0, 25), BackgroundTransparency = 1, Text = "EMR Bœuf Hub", TextColor3 = CurrentTheme.TextLight, Font = Enum.Font.GothamBold, TextSize = 28, Parent = SecurityFrame })
local InputContainer = Create("Frame", { Size = UDim2.new(0.75, 0, 0, 42), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 130), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.6, Parent = SecurityFrame })
ApplyLuxuryStyle(InputContainer, 10, 0.8, false)
local PasswordInput = Create("TextBox", { Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "", PlaceholderText = "Saisissez le code secret...", TextColor3 = CurrentTheme.TextLight, PlaceholderColor3 = CurrentTheme.TextMuted, Font = Enum.Font.Gotham, TextSize = 13, Parent = InputContainer })
local ConnectBtn = Create("TextButton", { Size = UDim2.new(0.75, 0, 0, 44), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 195), BackgroundColor3 = CurrentTheme.AccentColor, Text = "Déverrouiller l'accès Premium", TextColor3 = CurrentTheme.TextLight, Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false, Parent = SecurityFrame })
ApplyLuxuryStyle(ConnectBtn, 10, 0.85, false) table.insert(TrackedButtons, ConnectBtn)

-- ==========================================
-- 7. INTERFACE PRINCIPALE DU HUB & PAGES
-- ==========================================
local HubPanel = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Parent = MainFrame })
local Sidebar = Create("Frame", { Size = UDim2.new(0, 150, 1, 0), BackgroundColor3 = Color3.fromRGB(4, 4, 6), BackgroundTransparency = 0.75, Parent = HubPanel })
ApplyLuxuryStyle(Sidebar, 0, 1, true)
local NavTitle = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Text = "EMR MENU", TextColor3 = Color3.fromRGB(245, 245, 245), Font = Enum.Font.GothamBold, TextSize = 13, Parent = Sidebar })
local ContentWindow = Create("Frame", { Size = UDim2.new(1, -150, 1, 0), Position = UDim2.new(0, 150, 0, 0), BackgroundTransparency = 1, Parent = HubPanel })

local ActivePages = {}
local function AddPage(pageName)
    local frame = Create("ScrollingFrame", { Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Visible = false, CanvasSize = UDim2.new(0, 0, 0, 450), ScrollBarThickness = 3, ScrollBarImageColor3 = CurrentTheme.AccentColor, Parent = ContentWindow })
    Create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame })
    ActivePages[pageName] = frame table.insert(TrackedScrolls, frame)
    return frame
end

local TabAccueil = AddPage("Accueil")
local TabFarm    = AddPage("Farm")
local TabCustom  = AddPage("Custom")

-- Page Accueil Init
Create("TextLabel", { Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = "Tableau de Bord Élite ✨", TextColor3 = CurrentTheme.TextLight, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabAccueil })
local LaunchMusicBtn = Create("TextButton", { Size = UDim2.new(0.95, 0, 0, 36), BackgroundColor3 = Color3.fromRGB(30, 30, 35), BackgroundTransparency = 0.4, Text = "Lancer la playlist Apple Music 🎵", TextColor3 = Color3.fromRGB(255, 100, 130), Font = Enum.Font.GothamBold, TextSize = 12, Parent = TabAccueil })
ApplyLuxuryStyle(LaunchMusicBtn, 8, 0.9, false)

-- ==========================================
-- 8. MINI LECTEUR AUDIO APPLE MUSIC (MAC STYLE)
-- ==========================================
local MiniPlayer = Create("Frame", { Name = "AppleMusicMini", Size = UDim2.new(0, 220, 0, 130), Position = UDim2.new(0.65, 0, 0.65, 0), BackgroundColor3 = Color3.fromRGB(20, 20, 25), BackgroundTransparency = 0.1, Visible = false, Active = true, Draggable = true, Parent = MainGui })
ApplyLuxuryStyle(MiniPlayer, 12, 0.85, true)

local MacBar = Create("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = MiniPlayer })
local DotRed = Create("TextButton", { Size = UDim2.new(0, 11, 0, 11), Position = UDim2.new(0, 10, 0, 7), BackgroundColor3 = Color3.fromRGB(255, 95, 87), Text = "", Parent = MacBar }) Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = DotRed })
local DotYellow = Create("TextButton", { Size = UDim2.new(0, 11, 0, 11), Position = UDim2.new(0, 26, 0, 7), BackgroundColor3 = Color3.fromRGB(254, 188, 46), Text = "", Parent = MacBar }) Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = DotYellow })
local DotGreen = Create("TextButton", { Size = UDim2.new(0, 11, 0, 11), Position = UDim2.new(0, 42, 0, 7), BackgroundColor3 = Color3.fromRGB(40, 200, 64), Text = "", Parent = MacBar }) Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = DotGreen })

local TrackLabel = Create("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 32), BackgroundTransparency = 1, Text = "Aucune musique en lecture", TextColor3 = CurrentTheme.TextLight, Font = Enum.Font.GothamMedium, TextSize = 12, Parent = MiniPlayer })
local ControlsContainer = Create("Frame", { Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 58), BackgroundTransparency = 1, Parent = MiniPlayer })
local PrevBtn = Create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 45, 0, 0), BackgroundTransparency = 1, Text = "⏮", TextColor3 = CurrentTheme.TextLight, Font = Enum.Font.Gotham, TextSize = 16, Parent = ControlsContainer })
local PlayBtn = Create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 95, 0, 0), BackgroundTransparency = 1, Text = "▶", TextColor3 = Color3.fromRGB(255, 69, 58), Font = Enum.Font.GothamBold, TextSize = 20, Parent = ControlsContainer })
local NextBtn = Create("TextButton", { Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 145, 0, 0), BackgroundTransparency = 1, Text = "⏭", TextColor3 = CurrentTheme.TextLight, Font = Enum.Font.Gotham, TextSize = 16, Parent = ControlsContainer })

local VolumeContainer = Create("Frame", { Size = UDim2.new(0.7, 0, 0, 4), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 105), BackgroundColor3 = Color3.fromRGB(60, 60, 65), Parent = MiniPlayer })
Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = VolumeContainer })
local VolumeFill = Create("Frame", { Size = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 69, 58), Parent = VolumeContainer })
Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = VolumeFill })
local VolumeTrigger = Create("TextButton", { Size = UDim2.new(1, 0, 3, 0), Position = UDim2.new(0,0,-1,0), BackgroundTransparency = 1, Text = "", Parent = VolumeContainer })

local function SyncAudio()
    if CurrentActiveSound then CurrentActiveSound:Destroy() end
    local data = PLAYLIST[CurrentTrackIndex] TrackLabel.Text = data.Name
    CurrentActiveSound = Create("Sound", { SoundId = data.Id, Volume = VolumeFill.Size.X.Scale, Looped = true, Parent = SoundService })
    if IsPlaying then CurrentActiveSound:Play() PlayBtn.Text = "⏸" else PlayBtn.Text = "▶" end
end

LaunchMusicBtn.MouseButton1Click:Connect(function()
    MiniPlayer.Size = UDim2.new(0, 180, 0, 100) MiniPlayer.Visible = true
    Tween(MiniPlayer, {Size = UDim2.new(0, 220, 0, 130)}, 0.3) SyncAudio()
    task.spawn(function() TriggerIsland("🎵 Apple Music connecté") end)
end)

DotRed.MouseButton1Click:Connect(function() MiniPlayer.Visible = false if CurrentActiveSound then CurrentActiveSound:Destroy() IsPlaying = false end end)
PlayBtn.MouseButton1Click:Connect(function()
    IsPlaying = not IsPlaying
    if IsPlaying then CurrentActiveSound:Play() PlayBtn.Text = "⏸" task.spawn(function() TriggerIsland("▶ Lecture de la playlist") end) else CurrentActiveSound:Pause() PlayBtn.Text = "▶" end
end)
NextBtn.MouseButton1Click:Connect(function() CurrentTrackIndex = (CurrentTrackIndex % #PLAYLIST) + 1 SyncAudio() end)
PrevBtn.MouseButton1Click:Connect(function() CurrentTrackIndex = (CurrentTrackIndex - 2 % #PLAYLIST) + 1 SyncAudio() end)

local holdingVolume = false
VolumeTrigger.MouseButton1Down:Connect(function() holdingVolume = true end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then holdingVolume = false end end)
UserInputService.InputChanged:Connect(function(input)
    if holdingVolume and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local scale = math.clamp((input.Position.X - VolumeContainer.AbsolutePosition.X) / VolumeContainer.AbsoluteSize.X, 0, 1)
        VolumeFill.Size = UDim2.new(scale, 0, 1, 0) if CurrentActiveSound then CurrentActiveSound.Volume = scale end
    end
end)

-- ==========================================
-- 9. SÉLECTEUR D'ARMES & MODULES ANTI-LAG
-- ==========================================
Create("TextLabel", { Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = "Ajustements Tactiques Blox Fruits ⚔️", TextColor3 = CurrentTheme.TextLight, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabFarm })

local ActiveWeaponType = "Combat"
local function CreateIOSSwitch(labelName, order, parentFrame)
    local row = Create("Frame", { Size = UDim2.new(0.95, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = order, Parent = parentFrame or TabFarm })
    local lbl = Create("TextLabel", { Size = UDim2.new(0.7, 0, 1, 0), BackgroundTransparency = 1, Text = labelName, TextColor3 = CurrentTheme.TextLight, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = row })
    local switchBG = Create("TextButton", { Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(0.85, 0, 0.2, 0), BackgroundColor3 = Color3.fromRGB(120, 120, 125), Text = "", AutoButtonColor = false, Parent = row })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switchBG })
    local switchRound = Create("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 2, 0, 2), BackgroundColor3 = Color3.fromRGB(255,255,255), Parent = switchBG })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switchRound })
    return switchBG, switchRound
end

local SwCombatBG, SwCombatR = CreateIOSSwitch("Prioriser le style de Combat (Melee)", 1)
local SwSwordBG, SwSwordR = CreateIOSSwitch("Prioriser l'Épée Légendaire (Sword)", 2)
local SwFruitBG, SwFruitR = CreateIOSSwitch("Prioriser les pouvoirs du Fruit", 3)

local function UpdateSwitches()
    Tween(SwCombatBG, {BackgroundColor3 = (ActiveWeaponType == "Combat") and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(120, 120, 125)}, 0.2)
    Tween(SwCombatR, {Position = (ActiveWeaponType == "Combat") and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.2)
    Tween(SwSwordBG, {BackgroundColor3 = (ActiveWeaponType == "Sword") and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(120, 120, 125)}, 0.2)
    Tween(SwSwordR, {Position = (ActiveWeaponType == "Sword") and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.2)
    Tween(SwFruitBG, {BackgroundColor3 = (ActiveWeaponType == "Fruit") and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(120, 120, 125)}, 0.2)
    Tween(SwFruitR, {Position = (ActiveWeaponType == "Fruit") and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.2)
end
UpdateSwitches()

SwCombatBG.MouseButton1Click:Connect(function() ActiveWeaponType = "Combat" UpdateSwitches() task.spawn(function() TriggerIsland("⚔️ Style Combat sélectionné") end) end)
SwSwordBG.MouseButton1Click:Connect(function() ActiveWeaponType = "Sword" UpdateSwitches() task.spawn(function() TriggerIsland("⚔️ Mode Épée sélectionné") end) end)
SwFruitBG.MouseButton1Click:Connect(function() ActiveWeaponType = "Fruit" UpdateSwitches() task.spawn(function() TriggerIsland("🔮 Pouvoir Fruit sélectionné") end) end)

-- OPTION ANTI-LAG ET BOOST FPS INTÉGRÉE
local AntiLagActif = false
local SwLagBG, SwLagR = CreateIOSSwitch("Activer le Mode Performance Anti-Lag", 4)
SwLagBG.MouseButton1Click:Connect(function()
    AntiLagActif = not AntiLagActif
    Tween(SwLagBG, {BackgroundColor3 = AntiLagActif and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(120, 120, 125)}, 0.2)
    Tween(SwLagR, {Position = AntiLagActif and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.2)
    
    if AntiLagActif then
        task.spawn(function() TriggerIsland("⚡ Mode Anti-Lag : Textures lissées") end)
        for _, obj in ipairs(game:GetDescendants()) do
            if obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy()
            elseif obj:IsA("Part") or obj:IsA("MeshPart") then obj.Material = Enum.Material.SmoothPlastic obj.Reflectance = 0 end
        end
    end
end)

-- MODE ÉCONOMISEUR D'ÉNERGIE (OLED NIGHT)
local SaverScreen = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), Visible = false, ZIndex = 999, Parent = MainGui })
local SaverText = Create("TextLabel", { Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0.45, 0), BackgroundTransparency = 1, Text = "EMR Hub en cours de farm...\n[Cliquez sur l'écran pour revenir au jeu]", TextColor3 = Color3.fromRGB(0, 255, 120), Font = Enum.Font.Code, TextSize = 13, Parent = SaverScreen })

local SwSaverBG, SwSaverR = CreateIOSSwitch("Activer l'Économiseur d'Énergie OLED", 5)
SwSaverBG.MouseButton1Click:Connect(function()
    SaverScreen.Visible = true
    task.spawn(function() while SaverScreen.Visible do Tween(SaverText, {Position = UDim2.new(0, math.random(-10, 10), 0.45, math.random(-10, 10))}, 2) task.wait(2) end end)
end)
SaverScreen.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then SaverScreen.Visible = false end end)

-- ==========================================
-- 10. CONFIGURATION DES ONGLETS CUSTOMISATION
-- ==========================================
local function BuildCustomGrid(parent, height)
    local container = Create("Frame", { Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1, Parent = parent })
    Create("UIGridLayout", { CellSize = UDim2.new(0.48, 0, 0, 26), CellPadding = UDim2.new(0, 6, 0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = container })
    return container
end

Create("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = "FONDS D'ÉCRAN LUXE", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabCustom })
local GridW = BuildCustomGrid(TabCustom, 80)
for _, d in ipairs(CUSTOM_DATA.Wallpapers) do
    local b = Create("TextButton", { BackgroundColor3 = Color3.fromRGB(20,20,25), BackgroundTransparency = 0.5, Text = d.Name, TextColor3 = CurrentTheme.TextLight, Font = Enum.Font.Gotham, TextSize = 11, Parent = GridW })
    ApplyLuxuryStyle(b, 6, 0.9, false)
    b.MouseButton1Click:Connect(function() Background.Image = d.Id Background.ImageTransparency = (d.Id == "") and 1 or 0.5 end)
end

Create("TextLabel", { Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, Text = "COULEURS DES BOUTONS", TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabCustom })
local GridC = BuildCustomGrid(TabCustom, 80)
for _, d in ipairs(CUSTOM_DATA.Colors) do
    local b = Create("TextButton", { BackgroundColor3 = d.Color, BackgroundTransparency = 0.2, Text = d.Name, TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, TextSize = 11, Parent = GridC })
    ApplyLuxuryStyle(b, 6, 0.8, false)
    b.MouseButton1Click:Connect(function() CurrentTheme.AccentColor = d.Color RefreshUIElements() PastilleStroke.Color = d.Color end)
end

-- ==========================================
-- 11. BOUTONS LATÉRAUX & CRÉATION DE NAVIGATION
-- ==========================================
local function CreateSidebarTab(text, iconId, targetPage, order)
    local btn = Create("TextButton", { Size = UDim2.new(0.92, 0, 0, 36), BackgroundColor3 = CurrentTheme.AccentColor, BackgroundTransparency = 1, Text = "", LayoutOrder = order, AutoButtonColor = false, Parent = Sidebar })
    ApplyLuxuryStyle(btn, 8, 0.96, false)
    local container = Create("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = btn })
    Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 10), Parent = container })
    Create("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = container })

    local iconImg = Create("ImageLabel", { Size = UDim2.new(0, 20, 0, 20), Image = iconId, ScaleType = Enum.ScaleType.Crop, BackgroundTransparency = 1, Parent = container })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = iconImg })
    local lbl = Create("TextLabel", { Size = UDim2.new(1, -30, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = CurrentTheme.TextMuted, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = container })
    
    btn.MouseButton1Click:Connect(function()
        PlayPremiumSound(ASSETS.SoundClick, 0.4)
        for _, page in pairs(ActivePages) do page.Visible = false end targetPage.Visible = true
        for _, child in pairs(Sidebar:GetChildren()) do if child:IsA("TextButton") then Tween(child, {BackgroundTransparency = 1}, 0.2) child:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextLabel").TextColor3 = CurrentTheme.TextMuted end end
        Tween(btn, {BackgroundTransparency = 0.15}, 0.2) lbl.TextColor3 = CurrentTheme.TextLight
    end)
    return btn
end

local NavAcc = CreateSidebarTab("Tableau de bord", ICONS.Dashboard, TabAccueil, 1)
local NavFrm = CreateSidebarTab("Auto Farm", ICONS.Farm, TabFarm, 2)
local NavCst = CreateSidebarTab("Customisation", ICONS.Custom, TabCustom, 3)
Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Sidebar })

-- ==========================================
-- 12. VÉRIFICATION DU MOT DE PASSE ET LANCEUR
-- ==========================================
local function LancerScriptHoho()
    _G.lowend_device = true
    loadstring(game:HttpGet('https://raw.githubusercontent.com/acsu123/HohoV2/refs/heads/main/ScriptLoadButOlder.lua'))()
end

local function TransitionVersHub()
    PlayPremiumSound(ASSETS.SoundValid, 0.5)
    Tween(SecurityFrame, {Position = UDim2.new(0, 0, -1, 0), BackgroundTransparency = 1}, 0.5)
    HubPanel.Visible = true Tween(HubPanel, {Position = UDim2.new(0, 0, 0, 0)}, 0.5)
    TabAccueil.Visible = true Tween(NavAcc, {BackgroundTransparency = 0.15}, 0.2)
    NavAcc:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("TextLabel").TextColor3 = CurrentTheme.TextLight
    ToggleButton.Visible = true -- Rendre la pastille disponible
    task.spawn(LancerScriptHoho)
    task.spawn(function() TriggerIsland("🔓 Accès Premium Validé") end)
end

local traitementEnCours = false
ConnectBtn.MouseButton1Click:Connect(function()
    if traitementEnCours then return end traitementEnCours = true
    local txtSaisie = PasswordInput.Text:match("^%s*(.-)%s*$")
    
    if txtSaisie == CORRECT_PASSWORD then
        ConnectBtn.BackgroundColor3 = Color3.fromRGB(48, 209, 88) ConnectBtn.Text = "Code correct. Connexion..."
        task.wait(0.4) TransitionVersHub()
    else
        PlayPremiumSound(ASSETS.SoundError, 0.6)
        local bkColor = ConnectBtn.BackgroundColor3 ConnectBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 58) ConnectBtn.Text = "Mot de passe incorrect !"
        local ancPos = MainFrame.Position
        for i = 1, 5 do MainFrame.Position = ancPos + UDim2.new(0, (i%2 == 0 and 6 or -6), 0, 0) task.wait(0.04) end
        MainFrame.Position = ancPos task.wait(1.2)
        ConnectBtn.BackgroundColor3 = bkColor ConnectBtn.Text = "Déverrouiller l'accès Premium" traitementEnCours = false
    end
end)

-- Rendu initial fluide
MainFrame.Size = UDim2.new(0, 440, 0, 280) MainFrame.BackgroundTransparency = 1
Tween(MainFrame, {Size = UDim2.new(0, 460, 0, 300), BackgroundTransparency = 0.15}, 0.5)
