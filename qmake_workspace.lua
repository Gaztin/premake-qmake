local p     = premake
local qmake = p.extensions.qmake

qmake.workspace = {}
local m         = qmake.workspace

--
-- Generate a qmake workspace
--
function m.generate(wks)
	p.utf8()

	m.template()
	m.subprojects(wks)

	m.subdirs(wks)
end

--
-- Project type
--
function m.template()
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
		local prjpath = p.project.getrelative(wks, prj.name)
		p.w('%s.subdir = %s/%s', prj.name, prjpath, prj.name)
	end

	p.outln('')
end
