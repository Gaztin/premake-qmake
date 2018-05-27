-- Fix for when the module isn't embedded
include("_preload.lua")
include("qmake_project.lua")
include("qmake_workspace.lua")

local p     = premake
local qmake = p.extensions.qmake

--
-- Utility functions
--

function qmake.config(cfg)
	if cfg.platform then
		return cfg.platform .. ":" .. cfg.buildcfg
	else
		return cfg.buildcfg
	end
end
