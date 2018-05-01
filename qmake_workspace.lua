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
	p.out('TEMPLATE = subdirs\n\n')
end

--
-- Sub-project names
--
function m.subprojects(wks)
	p.out('SUBDIRS =')

	for prj in p.workspace.eachproject(wks) do
		p.w(' \\\n\t%s', prj.name)
	end

	p.out('\n\n')
end

--
-- Locations of sub-projects
--
function m.subdirs(wks)
	for prj in p.workspace.eachproject(wks) do
		p.w('%s.subdir = %s/%s\n', prj.name, prj.location, prj.name)
	end

	p.out('\n')
end
