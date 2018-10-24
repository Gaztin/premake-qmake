local p     = premake
local qmake = p.extensions.qmake

qmake.user = {}
local m    = qmake.user

--
-- Generate qmake user settings for a project
--
function m.generate(prj)
	p.indentation(" ")

	p.w("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
	p.w("<!DOCTYPE QtCreatorProject>")
	m.push("qtcreator")
	m.pop("qtcreator")
end

--
-- Writing functions
--

function m.push(name)
	p.push("<%s>", name)
end

function m.pop(name)
	p.pop("</%s>", name)
end
