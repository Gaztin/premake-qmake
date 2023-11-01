local p = premake

-- Initialize extension
p.extensions.qmake = premake.extensions.qmake or {}
local qmake        = p.extensions.qmake
qmake._VERSION     = premake._VERSION

local function default_toolset()
	local toolset_by_os = {
		windows = "msc-v142", -- Visual Studio 2019
		macosx = "clang",
		linux = "gcc"
	}
	return toolset_by_os[os.target()] or "gcc"
end

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

	toolset = default_toolset(),

	-- Workspace generation

	onWorkspace = function(wks)
		p.generate(wks, ".pro", qmake.workspace.generate)
	end,

	onProject = function(prj)
		p.generate(prj, ".pro", qmake.project.generate)
	end,
}

--
-- Decide when the full module should be loaded.
--
return function(cfg)
	return (_ACTION == "qmake")
end
