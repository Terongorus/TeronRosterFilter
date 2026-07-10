RosterFilterAddonTable 'rosterfilter'

local gui = require 'rosterfilter.gui'
local rosterfilter = require 'rosterfilter'


function handle.LOAD()
	for _, v in ipairs(tab_info) do
		tabs:create_tab(v.name)
	end
	rosterfilter.RegisterKeyChangedCallback("scale", function(value)
		RosterFilterFrame:SetScale(value)
	end)
end

do
    local frame = CreateFrame('Frame', 'RosterFilterFrame', UIParent, BackdropTemplateMixin and "BackdropTemplate")
    gui.set_window_style(frame)
    gui.set_size(frame, 750, 400)
    frame:SetPoint('LEFT', 750, 0)
    frame:SetToplevel(true)
	frame:SetMovable(true)
	frame:SetResizable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag('LeftButton')
	frame:SetScript('OnMouseDown', function() if IsControlKeyDown() then this:StartSizing(); end end)
	frame:SetScript('OnMouseUp', function() this:StopMovingOrSizing(); end)
	frame:SetScript('OnDragStart', function() this:StartMoving() end)
	frame:SetScript('OnDragStop', function() this:StopMovingOrSizing() end)
	frame:SetScript('OnShow', function() PlaySound(SOUNDKIT.IG_MAINMENU_OPEN) end)
	-- Also closes the details frame (see below) so nothing lingers on screen once the
	-- main window is closed. Nil-guarded: the initial frame:Hide() below fires this
	-- immediately, before the details-frame block later in this file has run yet.
	frame:SetScript('OnHide', function() PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE); if details_frame then details_frame:Hide() end end)
	frame.content = CreateFrame('Frame', nil, frame)
	frame.content:SetAllPoints()
	frame:Hide()
	M.RosterFilterFrame = frame
end

do
	tabs = gui.tabs(RosterFilterFrame, 'DOWN')
	tabs._on_select = on_tab_click
	function M.set_tab(id) tabs:select(id) end
end

do
	local frame = CreateFrame('Frame', nil, RosterFilterFrame)
	gui.set_size(frame, 10, 10)
	frame:SetPoint('BOTTOMRIGHT', RosterFilterFrame, 'BOTTOMRIGHT')
	frame:SetScript('OnMouseDown', function() RosterFilterFrame:StartSizing(); end)
	frame:SetScript('OnMouseUp', function() RosterFilterFrame:StopMovingOrSizing(); end)
end

do
	local options_button = gui.button(RosterFilterFrame)
	options_button:SetPoint('TOPRIGHT', RosterFilterFrame, 'TOPRIGHT', -4, -4)
	gui.set_size(options_button, 60, 20)
	options_button:SetText('Options')
	options_button:SetScript('OnClick', function()
		if options_frame:IsShown() then options_frame:Hide() else options_frame:Show() end
	end)
end

-- A side info panel shown when a roster row is clicked, replacing chat-print output.
-- Spans the main frame's full height and docks to whichever side is configured
-- (default RIGHT), similar to the default Guild UI's member-info side panel. Tied to
-- RosterFilterFrame: parented to it, and forced closed by its OnHide above, so nothing
-- lingers on screen once the main window is closed.
do
	local DETAILS_WIDTH = 240
	local DETAILS_GAP = 10

	local details = CreateFrame('Frame', 'RosterFilterDetailsFrame', RosterFilterFrame, BackdropTemplateMixin and "BackdropTemplate")
	gui.set_window_style(details)
	details:SetWidth(DETAILS_WIDTH)
	details:SetFrameStrata('DIALOG')
	details:Hide()

	local title = details:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
	title:SetPoint('TOPLEFT', 12, -12)
	title:SetPoint('RIGHT', -12, 0)
	title:SetJustifyH('LEFT')

	local body = details:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
	body:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -8)
	body:SetPoint('RIGHT', -12, 0)
	body:SetJustifyH('LEFT')
	body:SetJustifyV('TOP')

	do
		local close = gui.button(details)
		close:SetPoint('BOTTOMRIGHT', -8, 8)
		gui.set_size(close, 60, 24)
		close:SetText('Close')
		close:SetScript('OnClick', function() details:Hide() end)
	end

	local function anchor(side)
		details:ClearAllPoints()
		if side == 'LEFT' then
			details:SetPoint('TOPRIGHT', RosterFilterFrame, 'TOPLEFT', -DETAILS_GAP, 0)
			details:SetPoint('BOTTOMRIGHT', RosterFilterFrame, 'BOTTOMLEFT', -DETAILS_GAP, 0)
		else
			details:SetPoint('TOPLEFT', RosterFilterFrame, 'TOPRIGHT', DETAILS_GAP, 0)
			details:SetPoint('BOTTOMLEFT', RosterFilterFrame, 'BOTTOMRIGHT', DETAILS_GAP, 0)
		end
	end
	anchor('RIGHT')

	M.details_frame = details

	--- Moves the details panel to the given side ('LEFT' or 'RIGHT') of the main frame.
	function M.set_details_side(side)
		anchor(side)
	end

	--- Shows the details panel with a title (e.g. a character name) and a list of
	--- body lines (e.g. level/class/zone/notes).
	---@param titleText string
	---@param lines string[]
	function M.show_details(titleText, lines)
		title:SetText(titleText)
		body:SetText(table.concat(lines, '\n'))
		details:Show()
	end
end
