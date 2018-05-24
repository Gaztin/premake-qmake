local suite = test.declare("qmake")
local p     = premake
local qmake = p.extensions.qmake

--
-- Setup
--

local wks, prj

function suite.setup()
	p.action.set("qmake")
	wks = test.createWorkspace()
end

local function prepare()
	wks = p.oven.bakeWorkspace(wks)
	prj = test.getproject(wks, 1)
end

--
-- Check workspace generation
--

function suite.qmake_Workspace()
	prepare()
	qmake.workspace.generate(wks)
	test.capture [[
TEMPLATE = subdirs

SUBDIRS = \
	MyProject

MyProject.subdir = MyProject/MyProject

	]]
end
