-- blend mode :DISABLE, BLEND, ALPHAKEY, ADD, MOD
local K40 = CreateFrame("FRAME")

K40:RegisterEvent("ADDON_LOADED")
K40:SetScript("OnEvent", function()
    if event then
        if event == "ADDON_LOADED" and arg1 == 'K40UI' then
            K40UI:EnableMouse(false)
            K40:Show()
        end
    end
end)

--K40:SetPoint('CENTER', UIParent, 'CENTER', 0, -30)
--K40:SetWidth(300)
--K40:SetHeight(300)
K40:RegisterEvent('COMBAT_TEXT_UPDATE')
K40:RegisterEvent('PLAYER_DEAD')
K40:RegisterEvent('CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE')
K40:RegisterEvent('CHAT_MSG_SPELL_AURA_GONE_SELF')

local isK40Debug = false

K40.DebuffImage = nil


local L = {}

L["Banshee Curse"] = "Banshee Curse"   -- for testing
L["Corruption of Medivh"] = "Corruption of Medivh"
L["DEBUFF_ACTIVE_TOKEN"] = "You are afflicted by "
L["DEBUFF_FADE_TOKEN"] = " fades from you."
L["YELL"] = "YELL"

if (GetLocale() == "zhCN") then
    L["Corruption of Medivh"] = "麦迪文的腐化"
    L["Banshee Curse"] = "女妖诅咒"   -- for testing
    L["DEBUFF_ACTIVE_TOKEN"] = "你受到了"
    L["DEBUFF_FADE_TOKEN"] = "效果从你身上消失了."
    L["YELL"] = "大喊"
end
local texureOption = {
    x = 0,
    y = 20,
    width =32,
    height = 32,
    alpha = 1.0,
    Blend = "ALPHAKEY",
    Pos = "CENTER",
}

local DEBUFFTALBE = {
    [L["Banshee Curse"]] = {
        texture = "Interface\\Icons\\spell_nature_drowsy"
    },
    [L["Corruption of Medivh"]] = {
        texture = "Interface\\Icons\\Inv_misc_shadowegg",
    },
}

local function DebugLog(message)
    DEFAULT_CHAT_FRAME:AddMessage("K40DebugLog: "..message)
end

local function AnnounceDebuff(debuffName)
    SendChatMessage(string.format(debuffName),"SAY")
    if isK40Debug then
        DebugLog("Announced debuff: "..debuffName)
    end
end

local function IsDebuffActived(message)
    for deBuffName, _ in pairs(DEBUFFTALBE) do
        if string.find(message, L["DEBUFF_ACTIVE_TOKEN"].. deBuffName) then
            return deBuffName, true
        end
    end
    return nil, false
end

local function IsDebuffFaded(message)
    for deBuffName, _ in pairs(DEBUFFTALBE) do
        if string.find(message,  deBuffName .. L["DEBUFF_FADE_TOKEN"] ) then
            return deBuffName, true
        end
    end
    return nil, false
end


local function CreateDebuffTexture(debuffName)

    local config = DEBUFFTALBE[debuffName]
    if not config then return end

    if not K40.DebuffImage then
        K40.DebuffImage = CreateFrame("Frame", "K40DebuffImageFrame", K40UI,"K40FrameTemplate")
    end
    getglobal("K40DebuffImageFrameIcon"):SetTexture(config.texture)

    AnnounceDebuff(debuffName)
    K40.DebuffImage:Show()

    --local debuffTexture = K40:CreateTexture(nil, "OVERLAY")
    --debuffTexture:SetTexture(config.texture)
    --debuffTexture:SetWidth(texureOption.width)
    --debuffTexture:SetHeight(texureOption.height)
    --debuffTexture:SetPoint('Center', K40,texureOption.pos, texureOption.x, texureOption.y)
    --debuffTexture:SetAlpha(texureOption.alpha)
    --debuffTexture:SetBlendMode(texureOption.Blend)
    --K40.DebuffFrames[debuffName] = debuffTexture
    if K40.locked then
        K40UI:Show()
    else
        K40UI:Hide()
    end
end

local function CleanAllTexture()
    if K40.DebuffImage then
        K40.DebuffImage:Hide()
    end
    --for debuffName, texture in pairs(k40Textures) do
    --    texture:Hide()
    --    k40Textures[debuffName] = nil
    --end
end

K40:SetScript('OnEvent', function()
    if event == 'PLAYER_DEAD' then
        CleanAllTexture()
    end
    --   buff over
    if event  == 'CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE' then
        if arg1 then
            local debuffName, _ = IsDebuffActived(arg1)
            if debuffName then
                CleanAllTexture()
                if isK40Debug then DebugLog("Got debuff: " .. debuffName ) end
                CreateDebuffTexture(debuffName)
            end
        end

        elseif event == 'CHAT_MSG_SPELL_AURA_GONE_SELF' then
            if arg1 then
                local debuffName, _ = IsDebuffFaded(arg1)
                if debuffName then
                    CleanAllTexture()
                    if isK40Debug then DebugLog("K40: Debuff Fade: ".. debuffName ) end
                end
            end
    end
end)

K40.locked = true

-- Slash command handler
SLASH_K401 = '/k40'
SlashCmdList['K40'] = function(msg)
    if msg == 'debug' then
        isK40Debug = not isK40Debug
        DEFAULT_CHAT_FRAME:AddMessage('isDebug set to ' .. tostring(isK40Debug))
    elseif msg == 'lock' then
        K40.locked = true
        K40UIUnlock:Hide()
        K40UI:Hide()
        K40UI:EnableMouse(false)
        DEFAULT_CHAT_FRAME:AddMessage('K40 is locked')
    elseif msg == 'unlock' then
        K40.locked = false
        K40UIUnlock:Show()
        K40UI:Show()
        K40UI:EnableMouse(true)
        DEFAULT_CHAT_FRAME:AddMessage('K40 is unlocked')
    else
        DEFAULT_CHAT_FRAME:AddMessage('Usage: /k40 [debug | lock | unlock]')
    end
end