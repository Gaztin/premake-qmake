local p     = premake
local qmake = p.extensions.qmake

qmake.workspace = {}
local m         = qmake.workspace

--
-- Generate a qmake workspace
--
function m.generate(prj)
	p.utf8()
end
