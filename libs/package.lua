-- Vanilla's file loader never passes (addonName, addonTable) args to a chunk the way
-- modern clients do, so the shared addon table lives on a plain global instead.
_G.RosterFilterAddonTable = _G.RosterFilterAddonTable or {}
local addon_table = _G.RosterFilterAddonTable

local _G, setfenv, setmetatable = _G, setfenv, setmetatable
local environments, interfaces = {}, {}
local require, create_module, pass, empty, environment_mt

local function module(_, name)
    local defined = not not environments[name]
    if not defined then
        create_module(name)
    end
    setfenv(2, environments[name])
    return defined
end

setmetatable(addon_table, { __call = module })

function pass() end

empty = setmetatable({}, { __metatable=false, __newindex=pass })

environment_mt = { __index = _G }

function require(name)
    if not interfaces[name] then
        create_module(name)
    end
    return interfaces[name]
end

function create_module(name)
	local environment = setmetatable({ pass = pass, empty = empty, require = require }, environment_mt)
	local exports = {}
	environment.M = setmetatable({}, {
		__metatable = false,
		__newindex = function(_, k, v)
			environment[k], exports[k] = v, v
		end,
	})
	environment._M = environment
	environments[name] = environment
	interfaces[name] = setmetatable({}, { __metatable = false, __index = exports, __newindex = pass })
end

-- for testing
_G.module = create_module
_G.require = require

-- Vanilla sound-name polyfill (vanilla uses string sound names, not the SOUNDKIT enum
-- table). Merged key-by-key rather than an all-or-nothing "if not SOUNDKIT" guard,
-- since another addon (TeronModernSpellBook) polyfills the same global with a
-- different partial set of keys and may load first, which would otherwise block
-- these keys from ever being added.
SOUNDKIT = SOUNDKIT or {}
if not SOUNDKIT.IG_MAINMENU_OPEN then SOUNDKIT.IG_MAINMENU_OPEN = "igMainMenuOpen" end
if not SOUNDKIT.IG_MAINMENU_CLOSE then SOUNDKIT.IG_MAINMENU_CLOSE = "igMainMenuClose" end
if not SOUNDKIT.IG_CHARACTER_INFO_TAB then SOUNDKIT.IG_CHARACTER_INFO_TAB = "igCharacterInfoTab" end
