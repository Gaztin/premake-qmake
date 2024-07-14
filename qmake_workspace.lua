local p     = premake
local qmake = p.extensions.qmake

qmake.workspace = {}
local m         = qmake.workspace

--
-- Generate a qmake workspace
--
function m.generate(wks)
	m.template()
	m.subprojects(wks)
	m.depends(wks)

	m.subdirs(wks)
end

--
-- Project type
--
function m.template()
	p.w("# Generated with premake " .. _PREMAKE_VERSION .. " using premake-qmake extension.")
	p.w("# https://github.com/Gaztin/premake-qmake")
	p.w('TEMPLATE = subdirs')
	p.outln('')
end

--
-- Sub-project names
--
function m.subprojects(wks)
	p.out('SUBDIRS =')

	for prj in p.workspace.eachproject(wks) do
		p.out(string.format(' \\\n\t%s', prj.name))
	end

	p.outln('\n')
end

--
-- Locations of sub-projects
--
function m.subdirs(wks)
	for prj in p.workspace.eachproject(wks) do
		local prjpath = p.workspace.getrelative(wks, prj.location .. "/" .. prj.name)
		p.w('%s.subdir = %s', prj.name, prjpath)
	end

	p.outln('')
end

--
-- Project dependencies
--
function m.depends(wks)
	for prj in p.workspace.eachproject(wks) do
		local deps = p.project.getdependencies(prj)
		if #deps > 0 then
			p.out(string.format('%s.depends =', prj.name))
			for _, dep in ipairs(deps) do
				p.out(' ' .. dep.name)
			end
			p.outln('')
		end
	end
end
