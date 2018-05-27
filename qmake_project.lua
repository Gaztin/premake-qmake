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
