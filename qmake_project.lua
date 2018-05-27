local p     = premake
local qmake = p.extensions.qmake

qmake.project = {}
local m       = qmake.project
m.configs     = {}

--
-- Generate a qmake project
--
function m.generate(prj)
	p.utf8()

	m.template(prj)

	for cfg in p.project.eachconfig(prj) do
		p.outln('')
		p.push('%s {', qmake.config(cfg))
		m.destdir(cfg)
		m.target(cfg)
		m.config(cfg)
		m.defines(cfg)
		m.forms(cfg)
		m.headers(cfg)
		m.sources(cfg)
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
		["C++11"]   = "c++11",
		["C++14"]   = "c++14",
		["C++17"]   = "c++17",
		["gnu++11"] = "c++11",
		["gnu++14"] = "c++14",
		["gnu++17"] = "c++17",
	}
	if dialects[cfg.cppdialect] then
		p.w(dialects[cfg.cppdialect])
	end
end

--
-- Destination directory
--
function m.destdir(cfg)
	if cfg.targetdir then
		p.w('DESTDIR = %s', cfg.targetdir)
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
end

--
-- Files
--
function m.files(cfg, var, exts)
	local fconfigs = qmake.fileConfigs(cfg, exts)
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

function m.headers(cfg)
	m.files(cfg, "HEADERS", {".h", ".hh", ".hpp", ".hxx", ".inl"})
end

function m.sources(cfg)
	m.files(cfg, "SOURCES", {".c", ".cc", ".cpp", ".cxx"})
end
