local suite = test.declare("qmake")
local p     = premake
local qmake = p.extensions.qmake

--
-- Setup
--

function suite.setup()
	p.action.set "qmake"
	test.createWorkspace()
end

local function prepare()
	project "TestProject"
end

--
-- Check workspace generation
--

function suite.qmake_Workspace()
	prepare()
	test.capture [[
	]]
end
