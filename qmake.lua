-- Fix for when the module isn't embedded
include("_preload.lua")
include("qmake_project.lua")
include("qmake_workspace.lua")

local p     = premake
local qmake = p.extensions.qmake

--
-- New fields
--

p.api.register {
	name  = "qtmodules",
	scope = "config",
	kind  = "list"
}

--
-- Utility functions
--

function qmake.eachconfig(prj)
	local configs = {}

	local function alreadyExists(cfg)
		for i = 1, #configs do
			if configs[i].buildcfg == cfg.buildcfg then
				return true
			end
		end
		return false
	end

	for cfg in p.project.eachconfig(prj) do
		if not alreadyExists(cfg) then
			table.insert(configs, cfg)
		end
	end

	local i = 0
	return function()
		i = i + 1
		return configs[i]
	end
end

function qmake.pushVariable(name, assign)
	assign = assign or '+='
	p.eol(" \\\n")
	p.push('%s ' .. assign, name)
end

function qmake.popVariable()
	p.pop()
	p.eol("\n")
	p.outln('')
end

function qmake.fileConfigs(cfg, exts, filter)
	local fconfigs = {}
	local tr       = p.project.getsourcetree(cfg.project)
	filter         = filter or function (fcfg) return false end
	if #tr.children > 0 then
		p.tree.traverse(tr, {
			onleaf = function(node)
				local fcfg = p.fileconfig.getconfig(node, cfg)
				if fcfg and path.hasextension(node.name, exts) and not filter(fcfg) then
					table.insert(fconfigs, fcfg)
				end
			end
		})
	end
	return fconfigs;
end

function qmake.configName(cfg)
	local buildcfg = cfg.buildcfg:lower()
	if buildcfg == "debug" or buildcfg == "release" or buildcfg == "profile" then
		return buildcfg
	else
		local debugsymbols = {
			["On"]   = "debug",
			["Full"] = "debug",
		}
		return debugsymbols[cfg.symbols] or "release"
	end
end
