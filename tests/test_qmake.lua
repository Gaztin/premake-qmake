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
-- Workspace generation
--

function suite.qmake_DefaultWorkspace()
	prepare()
	qmake.workspace.generate(wks)
	test.capture [[
TEMPLATE = subdirs

SUBDIRS = \
	MyProject

MyProject.subdir = MyProject/MyProject
	]]
end

function suite.qmake_DependsWorkspace()
	test.createproject(wks)
	dependson("MyProject")
	test.createproject(wks)
	dependson("MyProject")
	dependson("MyProject2")
	prepare()
	qmake.workspace.depends(wks)
	test.capture [[
MyProject2.depends = MyProject
MyProject3.depends = MyProject MyProject2
	]]
end

--
-- Project generation
--

function suite.qmake_DefaultProject()
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = app
CONFIG += console

Debug {
}

Release {
}
	]]
end

function suite.qmake_ProjectPlatforms()
	wks.platforms = {"win32", "unix"}
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = app
CONFIG += console

win32:Debug {
}

unix:Debug {
}

win32:Release {
}

unix:Release {
}
	]]
end

function suite.qmake_ProjectKindConsoleApp()
	kind("ConsoleApp")
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = app
CONFIG += console
	]]
end

function suite.qmake_ProjectKindWindowedApp()
	kind("WindowedApp")
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = app
CONFIG += windows
	]]
end

function suite.qmake_ProjectKindSharedLib()
	kind("SharedLib")
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = lib
CONFIG += shared
	]]
end

function suite.qmake_ProjectKindStaticLib()
	kind("StaticLib")
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = lib
CONFIG += static
	]]
end
