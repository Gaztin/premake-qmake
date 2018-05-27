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

function qmake.pushVariable(name)
	p.eol(" \\\n")
	p.push('%s +=', name)
end

function qmake.popVariable()
	p.pop()
	p.eol("\n")
	p.outln('')
end

function qmake.fileConfigs(cfg, exts)
	local fconfigs = {}
	local tr       = p.project.getsourcetree(cfg.project)
	if #tr.children > 0 then
		p.tree.traverse(tr, {
			onleaf = function(node)
				local fcfg = p.fileconfig.getconfig(node, cfg)
				if fcfg and path.hasextension(node.name, exts) then
					table.insert(fconfigs, fcfg)
				end
			end
		})
	end
	return fconfigs;
end
