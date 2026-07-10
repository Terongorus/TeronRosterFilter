RosterFilterAddonTable 'rosterfilter'

-- Vanilla has no Interface-Options-panel system to register with (Settings.* is
-- Dragonflight-only), so this is a standalone frame toggled from a button on the main
-- window instead. require'd at file scope, safely, per the module system's
-- forward-reference design: gui/core.lua loads later in the .toc, but nothing here
-- calls into gui.* until handle.LOAD2() runs at PLAYER_LOGIN, long after every file
-- has loaded.
local gui = require 'rosterfilter.gui'

function handle.LOAD()
    if not _G.RosterFilterOptions then
        _G.RosterFilterOptions = {}
    end
end

local defs = {}
local function GetConfigOrDefault(key, def)
    defs[key] = def

    if _G.RosterFilterOptions[key] == nil then
        _G.RosterFilterOptions[key] = def
    end

    return _G.RosterFilterOptions[key]
end

local changedcb = {}
local function RegisterKeyChangedCallback(key, cb)
    if not changedcb[key] then
        changedcb[key] = {}
    end

    table.insert(changedcb[key] , cb)
end
M.RegisterKeyChangedCallback = RegisterKeyChangedCallback

local function triggerCallback(key, value)
    for _, cb in pairs(changedcb[key] or {}) do
        cb(value)
    end
end

local function SetConfig(key, value)
    _G.RosterFilterOptions[key] = value

    triggerCallback(key, value)
end
M.SetConfig = SetConfig


local f = CreateFrame("Frame", "RosterFilterOptionsFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
f.name = "Teron's Roster Filter"
f:SetWidth(320)
f:SetHeight(300)
f:SetPoint("CENTER", 0, 0)
f:SetFrameStrata("DIALOG")
f:SetMovable(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")
-- Vanilla invokes scripts with no arguments (this-global convention), but StartMoving/
-- StopMovingOrSizing are native methods that need an explicit receiver, so they can't
-- be passed directly as the handler the way modern clients allow.
f:SetScript("OnDragStart", function() f:StartMoving() end)
f:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)
f:Hide()
M.options_frame = f

-- Deferred to ADDON_LOADED (a 2nd, separate handle.LOAD entry - these accumulate
-- rather than overwrite, see RosterFilter.lua's set_handler.LOAD): gui/core.lua
-- (which defines set_window_style) loads after this file in the .toc, so calling it
-- here at file scope would fail before every file has finished loading.
function handle.LOAD()
    gui.set_window_style(f)
end

do
    local t = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    t:SetText(f.name)
    t:SetPoint("TOPLEFT", f, 15, -15)
end

local function createCheckbox(title, key, def)
    local b = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("LEFT", b, "RIGHT", 0, 1)
    b.text:SetText(title)
    b.text:SetTextColor(1, 1, 1)
    b:SetScript("OnClick", function()
        SetConfig(key, b:GetChecked())
    end)

    RegisterKeyChangedCallback(key, function(v)
        b:SetChecked(v)
    end)

    triggerCallback(key, GetConfigOrDefault(key, def))
    return b
end

function handle.LOAD2()
    f.default = function()
        for k, v in pairs(defs) do
            SetConfig(k, v)
        end
    end

    f.refresh = function()
    end

    local base = -15
    local nextpos = function(offset)
        if not offset then
            offset = 30
        end
        base = base - offset
        return base
    end

    do
        local b = createCheckbox("Show guild name", "showguildname", true)
        b:SetPoint("TOPLEFT", f, 15, nextpos())
    end

    do
        local b = createCheckbox("Show numbers", "shownumbers", true)
        b:SetPoint("TOPLEFT", f, 15, nextpos())
    end

    do
        local b = createCheckbox("Show guild notes", "notes", true)
        b:SetPoint("TOPLEFT", f, 15, nextpos())
    end

    -- Registered before the checkbox below so its initial triggerCallback (on load,
    -- from the saved/default value) also applies the saved side, not just future changes.
    RegisterKeyChangedCallback("detailsleft", function(v)
        set_details_side(v and 'LEFT' or 'RIGHT')
    end)

    do
        local b = createCheckbox("Anchor details panel on left", "detailsleft", false)
        b:SetPoint("TOPLEFT", f, 15, nextpos())
    end

    do
        local key = "scale"
        -- Vanilla's OptionsSliderTemplate exposes its Low/High/Text sub-widgets via
        -- the classic _G[name.."Suffix"] naming convention, not direct .Low/.High
        -- fields (that requires a later-client parentKey XML attribute vanilla
        -- doesn't have) - so the slider needs a real name, not nil.
        local sliderName = gui.unique_name()
        local s = CreateFrame("Slider", sliderName, f, "OptionsSliderTemplate")
        s:SetOrientation('HORIZONTAL')
        s:SetHeight(14)
        s:SetWidth(160)
        s:SetMinMaxValues(0.1, 2.0)
        s:SetValueStep(0.05)
        _G[sliderName.."Low"]:SetText("10%")
        _G[sliderName.."High"]:SetText("200%")

        local l = s:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        l:SetPoint("RIGHT", s, "LEFT", -20, 1)
        l:SetText("Frame scale")
        l:SetTextColor(1, 1, 1)

        s:SetPoint("TOPLEFT", f, 40 + l:GetStringWidth(), nextpos(45))

        -- Vanilla's OnValueChanged delivers the new value via the global arg1, not a
        -- parameter. Guarded against re-entrancy: Slider:SetValue() re-fires
        -- OnValueChanged (unlike CheckButton:SetChecked(), which doesn't re-fire
        -- OnClick), so without this the changed-callback below would call SetValue,
        -- which fires OnValueChanged, which calls SetConfig, which calls the
        -- changed-callback again - infinite loop / C stack overflow.
        local suppressConfigUpdate = false
        s:SetScript("OnValueChanged", function()
            _G[sliderName.."Text"]:SetText(tostring(math.floor(arg1*100)).."%")
            if suppressConfigUpdate then return end
            SetConfig(key, arg1)
        end)

        RegisterKeyChangedCallback(key, function(v)
            suppressConfigUpdate = true
            s:SetValue(v)
            suppressConfigUpdate = false
        end)

        triggerCallback(key, GetConfigOrDefault(key, 1.0))
    end

    do
        local close = gui.button(f)
        close:SetPoint("BOTTOMRIGHT", -8, 8)
        gui.set_size(close, 60, 24)
        close:SetText("Close")
        close:SetScript("OnClick", function() f:Hide() end)
    end
end
