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

	onStart = function()
		--
		-- Overloaded functions
		--
		p.override(p.tools.gcc, "getLibraryDirectories",
			-- Relative paths in library directories should be prepended with '$$PWD'
			-- To achieve this, we override the 'p.quoted' function that just so happens to be inserted after every '-L'
			function(base, cfg)
				local originalquoted = p.quoted
				p.quoted = function(value)
					if not path.isabsolute(value) then
						value = path.join("$$PWD", value)
					end
					return originalquoted(value)
				end

				local result = base(cfg)

				-- Restore 'p.quoted' to its original function
				p.quoted = originalquoted

				return result
			end
		)
	end,


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
