local p       = premake
local project = p.project
local qmake   = p.extensions.qmake

qmake.project = {}
local m       = qmake.project
m.configs     = {}

local function pwdpath(fullpath)
	if path.isabsolute(fullpath) then
		return p.quoted(fullpath)
	end
	return p.quoted(path.join("$$PWD", fullpath))
end

--
-- Generate a qmake project
--
function m.generate(prj)
	-- Subdir subprojects need to live in their own subdirectories
	prj.location = prj.location .. "/" .. prj.name
	p.w("# Generated with premake " .. _PREMAKE_VERSION .. " using premake-qmake extension.")
	p.w("# https://github.com/Gaztin/premake-qmake")
	
	m.template(prj)

	for cfg in qmake.eachconfig(prj) do
		p.outln('')
		p.push('%s {', qmake.configName(cfg))

		m.destdir(cfg)
		m.target(cfg)
		m.mocDir(cfg)
		m.rccDir(cfg)
		m.uiDir(cfg)
		m.objDir(cfg)

		m.qt(cfg)
		m.config(cfg)
		m.defines(cfg)
		m.buildoptions(cfg)

		m.forms(cfg)
		m.resources(cfg)
		m.headers(cfg)
		m.sources(cfg)

		m.includepath(cfg)
		m.pchheader(cfg)
		m.libs(cfg)

		p.pop('}')
	end
end

--
-- Template
--
function m.template(prj)
	local templates = {
		['ConsoleApp']  = 'app',
		['WindowedApp'] = 'app',
		['SharedLib']   = 'lib',
		['StaticLib']   = 'lib',
	}
	p.w('TEMPLATE = %s', templates[prj.kind] or '')
end

--
-- Configs
--
m.configs.funcs = function(cfg)
	return {
		m.configs.kind,
		m.configs.rtti,
		m.configs.cppdialect,
	}
end

function m.configs.kind(cfg)
	local configs = {
		['ConsoleApp']  = 'console',
		['WindowedApp'] = 'windows',
		['SharedLib']   = 'shared',
		['StaticLib']   = 'static',
	}
	if configs[cfg.kind] then
		p.w(configs[cfg.kind])
	end
end

function m.configs.rtti(cfg)
	if cfg.rtti == "On" then
		p.w('rtti')
	elseif cfg.rtti == "Off" then
		p.w('rtti_off')
	end
end

function m.configs.cppdialect(cfg)
	local dialects = {
		["C++11"]   = "C++11",
		["C++14"]   = "C++14",
		["C++17"]   = "C++17",
		["gnu++11"] = "C++11",
		["gnu++14"] = "C++14",
		["gnu++17"] = "C++17",
		["C++20"] = "C++20",
		["C++23"] = "C++23",
		["C++latest"] = "C++2b"
	}
	if dialects[cfg.cppdialect] then
		p.w(dialects[cfg.cppdialect])
	end
end

--
-- Destination directory
--
function m.destdir(cfg)
	if cfg.buildtarget.directory then
		p.w('DESTDIR = %s', pwdpath(p.project.getrelative(cfg.project, cfg.buildtarget.directory)))
	end
end

--
-- Target
--
function m.target(cfg)
	if cfg.targetname then
		p.w('TARGET = %s', cfg.targetname)
	end
end

--
-- MOC directory
--
function m.mocDir(cfg)
	if cfg.objdir then
		p.w('MOC_DIR = "%s"', pwdpath(p.project.getrelative(cfg.project, cfg.objdir)))
	end
end

--
-- RCC directory
--
function m.rccDir(cfg)
	if cfg.objdir then
		p.w('RCC_DIR = "%s"', pwdpath(p.project.getrelative(cfg.project, cfg.objdir)))
	end
end

--
-- UI directory
--
function m.uiDir(cfg)
	if cfg.objdir then
		p.w('UI_DIR = "%s"', pwdpath(p.project.getrelative(cfg.project, cfg.objdir)))
	end
end

--
-- Objects directory
--
function m.objDir(cfg)
	if cfg.objdir then
		p.w('OBJECTS_DIR = "%s"', pwdpath(p.project.getrelative(cfg.project, cfg.objdir)))
	end
end

--
-- Qt modules
--
function m.qt(cfg)
	if #cfg.qtmodules > 0 then
		qmake.pushVariable("QT")
		for _, qtmodule in ipairs(cfg.qtmodules) do
			p.w(qtmodule)
		end
		qmake.popVariable()
	end
end

--
-- Config
--
function m.config(cfg)
	p.eol(" \\\n")
	p.push('CONFIG +=')
	p.callArray(m.configs.funcs, cfg)
	p.pop()
	p.eol("\n")
	p.outln('')
end

--
-- Defines
--
function m.defines(cfg)
	if #cfg.defines > 0 then
		qmake.pushVariable("DEFINES")
		for _, define in ipairs(cfg.defines) do
			p.w(define)
		end
		qmake.popVariable()
	end
	if #cfg.undefines > 0 then
		qmake.pushVariable("DEFINES", "-=")
		for _, undefine in ipairs(cfg.undefines) do
			p.w(undefine)
		end
		qmake.popVariable()
	end
end

--
-- buildoptions
--
function m.buildoptions(cfg)
	local toolset = p.config.toolset(cfg) or p.tools.gcc
	local cflags = table.join(cfg.buildoptions, toolset.getcflags(cfg), toolset.getforceincludes(cfg))
	local cxxflags = table.join(cfg.buildoptions, toolset.getcxxflags(cfg), toolset.getforceincludes(cfg))

	if #cflags > 0 then
		qmake.pushVariable("QMAKE_CFLAGS")
		for _, buildoption in ipairs(cflags) do
			p.w(buildoption)
		end
		qmake.popVariable()
	end
	if #cxxflags > 0 then
		qmake.pushVariable("QMAKE_CXXFLAGS")
		for _, buildoption in ipairs(cxxflags) do
			p.w(buildoption)
		end
		qmake.popVariable()
	end
end

--
-- Files
--
function m.files(cfg, var, exts, filter)
	local fconfigs = qmake.fileConfigs(cfg, exts, filter)
	if #fconfigs > 0 then
		qmake.pushVariable(var)
		for _, fcfg in ipairs(fconfigs) do
			p.w(fcfg.path)
		end
		qmake.popVariable()
	end
end

function m.forms(cfg)
	m.files(cfg, "FORMS", {".ui"})
end

function m.resources(cfg)
	m.files(cfg, "RESOURCES", {".qrc"})
end

function m.headers(cfg)
	m.files(cfg, "HEADERS", {".h", ".hh", ".hpp", ".hxx", ".inl"})
end

function m.sources(cfg)
	m.files(cfg, "SOURCES", {".c", ".cc", ".cpp", ".cxx"}, function(filecfg) return filecfg.flags.ExcludeFromBuild or filecfg.buildaction == "None" end)
end

--
-- Include path
--
function m.includepath(cfg)
	if #cfg.includedirs > 0 then
		qmake.pushVariable("INCLUDEPATH")
		for _, includedir in ipairs(cfg.includedirs) do
			p.w('"%s"', p.project.getrelative(cfg.project, includedir))
		end
		qmake.popVariable()
	end
	if #cfg.externalincludedirs > 0 then
		qmake.pushVariable("QMAKE_INCDIR")
		for _, includedir in ipairs(cfg.externalincludedirs) do
			p.w('"%s"', p.project.getrelative(cfg.project, includedir))
		end
		qmake.popVariable()
	end
end

--
-- Precompiled header
--
function m.pchheader(cfg)
	-- copied from gmake2_cpp.lua
	if not cfg.pchheader or cfg.flags.NoPCH then
		return
	end

	p.w('CONFIG += precompile_header')

	local pch = cfg.pchheader
	local found = false

	-- test locally in the project folder first (this is the most likely location)
	local testname = path.join(cfg.project.basedir, pch)
	if os.isfile(testname) then
		pch = project.getrelative(cfg.project, testname)
		found = true
	else
		-- else scan in all include dirs.
		for _, incdir in ipairs(cfg.includedirs) do
			testname = path.join(incdir, pch)
			if os.isfile(testname) then
				pch = project.getrelative(cfg.project, testname)
				found = true
				break
			end
		end
	end

	if not found then
		pch = project.getrelative(cfg.project, path.getabsolute(pch))
	end
	p.w('PRECOMPILED_HEADER = "%s"', pch)

end

--
-- Libs
--
function m.libs(cfg)
	local ldflags, libdirs, links

	local toolset = p.config.toolset(cfg)
	if toolset then
		ldflags = toolset.getldflags(cfg)
		libdirs = toolset.getLibraryDirectories(cfg)
		links = toolset.getlinks(cfg)
	else
		ldflags = cfg.linkoptions
		links = p.config.getlinks(cfg)
		libdirs = { }
		for _, dir in ipairs(cfg.libdirs) do
			table.insert(libdirs, '-L' .. dir)
		end
	end

	if #ldflags > 0 or #libdirs > 0 or #links > 0 then
		qmake.pushVariable("LIBS")
		for _, flag in ipairs(ldflags) do
			p.w('"%s"', flag)
		end
		for _, dir in ipairs(libdirs) do
			p.w('"%s"', dir)
		end
		for _, link in ipairs(links) do
			p.w('"%s"', link)
		end
		qmake.popVariable()
	end
end
