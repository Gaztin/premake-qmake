local p = premake

-- Initialize extension
p.extensions.qmake = premake.extensions.qmake or {}
local qmake        = p.extensions.qmake
qmake._VERSION     = premake._VERSION

--
-- Create the qmake action
--
newaction {
	-- Metadata

	trigger     = "qmake",
	shortname   = "qmake",
	description = "Generate qmake files for Qt projects",

	-- Capabilities

	valid_kinds = {
		"ConsoleApp",
		"WindowedApp",
		"StaticLib",
		"SharedLib",
	},
	valid_languages = {
		"C++",
	},
	valid_tools = {
		cc = {
			"msc",
			"clang",
			"gcc",
		}
	},

	-- Workspace generation

	onWorkspace = function(wks)
		p.generate(wks, ".pro", qmake.workspace.generate)
	end,

	onProject = function(prj)
		p.generate(prj, prj.name .. "/" .. prj.name .. ".pro", qmake.project.generate)
	end,
}

--
-- Decide when the full module should be loaded.
--
return function(cfg)
	return (_ACTION == "qmake")
end
