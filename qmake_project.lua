local p     = premake
local qmake = p.extensions.qmake

qmake.project = {}
local m       = qmake.project

--
-- Generate a qmake project
--
function m.generate(prj)
	p.utf8()
end
