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
		m.target(cfg)
		m.config(cfg)
		m.defines(cfg)
		m.headers(prj, cfg)
		m.sources(prj, cfg)
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
function m.config(cfg)
	p.eol(" \\\n")
	p.push('CONFIG +=')
	p.callArray(m.configs.funcs, cfg)
	p.pop()
	p.eol("\n")
	p.outln('')
end

m.configs.funcs = function(cfg)
	return {
		m.configs.kind,
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

--
-- Target
--
function m.target(cfg)
	if cfg.targetname then
		p.w('TARGET = %s', cfg.targetname)
	end
end

--
-- Defines
--
function m.defines(cfg)
	if #cfg.defines > 0 then
		p.eol(" \\\n")
		p.push('DEFINES +=')
		for _, define in ipairs(cfg.defines) do
			p.w(define)
		end
		p.pop()
		p.eol("\n")
		p.outln('')
	end
end

--
-- Headers
--
function m.headers(prj, cfg)
	local tr = p.project.getsourcetree(prj)

	if #tr.children > 0 then
		local extensions = {".h", ".hh", ".hpp", ".hxx", ".inl"}

		p.eol(" \\\n")
		p.push('HEADERS +=')
		p.tree.traverse(tr, {
			onleaf = function(node)
				local fcfg = p.fileconfig.getconfig(node, cfg)
				if fcfg and path.hasextension(node.name, extensions) then
					p.w(node.path)
				end
			end
		})
		p.pop()
		p.eol("\n")
		p.outln('')
	end
end

--
-- Sources
--
function m.sources(prj, cfg)
	local tr = p.project.getsourcetree(prj)

	if #tr.children > 0 then
		local extensions = {".c", ".cc", ".cpp", ".cxx"}

		p.eol(" \\\n")
		p.push('SOURCES +=')
		p.tree.traverse(tr, {
			onleaf = function(node)
				local fcfg = p.fileconfig.getconfig(node, cfg)
				if fcfg and path.hasextension(node.name, extensions) then
					p.w(node.path)
				end
			end
		})
		p.pop()
		p.eol("\n")
		p.outln('')
	end
end
