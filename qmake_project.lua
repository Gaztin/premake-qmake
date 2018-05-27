local p     = premake
local qmake = p.extensions.qmake

qmake.project = {}
local m       = qmake.project

--
-- Generate a qmake project
--
function m.generate(prj)
	p.utf8()

	m.template(prj)
	m.config(prj)

	for cfg in p.project.eachconfig(prj) do
		p.push('\n%s {', qmake.config(cfg))
		m.target(cfg)
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
-- Config
--
function m.config(prj)
	local configs = {
		['ConsoleApp']  = 'console',
		['WindowedApp'] = 'windows',
		['SharedLib']   = 'shared',
		['StaticLib']   = 'static',
	}
	p.w('CONFIG += %s', configs[prj.kind] or '')
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
		p.w('DEFINES += \\')
		for _, define in ipairs(cfg.defines) do
			p.w('\t%s \\', define)
		end
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

		p.w('HEADERS += \\')
		p.tree.traverse(tr, {
			onleaf = function(node)
				local fcfg = p.fileconfig.getconfig(node, cfg)
				if fcfg and path.hasextension(node.name, extensions) then
					p.w('\t%s \\', node.path)
				end
			end
		})
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

		p.w('SOURCES += \\')
		p.tree.traverse(tr, {
			onleaf = function(node)
				local fcfg = p.fileconfig.getconfig(node, cfg)
				if fcfg and path.hasextension(node.name, extensions) then
					p.w('\t%s \\', node.path)
				end
			end
		})
		p.outln('')
	end
end
