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

Debug {
	CONFIG += \
		console \

}

Release {
	CONFIG += \
		console \

}
	]]
end

function suite.qmake_ProjectPlatforms()
	wks.platforms = {"win32", "unix"}
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = app

win32:Debug {
	CONFIG += \
		console \

}

unix:Debug {
	CONFIG += \
		console \

}

win32:Release {
	CONFIG += \
		console \

}

unix:Release {
	CONFIG += \
		console \

}
	]]
end

function suite.qmake_ProjectKindConsoleApp()
	kind("ConsoleApp")
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = app

Debug {
	CONFIG += \
		console \

}

Release {
	CONFIG += \
		console \

}
	]]
end

function suite.qmake_ProjectKindWindowedApp()
	kind("WindowedApp")
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = app

Debug {
	CONFIG += \
		windows \

}
	]]
end

function suite.qmake_ProjectKindSharedLib()
	kind("SharedLib")
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = lib

Debug {
	CONFIG += \
		shared \

}
	]]
end

function suite.qmake_ProjectKindStaticLib()
	kind("StaticLib")
	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = lib

Debug {
	CONFIG += \
		static \

}
	]]
end

function suite.qmake_AdvancedProject()
	files {"common.h", "main.cpp"}

	filter("Debug")
	targetname("TargetDebug")
	defines {"DEBUG"}
	files {"common_d.h", "debug.cpp"}

	filter("Release")
	targetname("TargetRelease")
	defines {"RELEASE", "NDEBUG"}
	files {"common_r.h", "release.cpp"}

	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = app

Debug {
	TARGET = TargetDebug
	CONFIG += \
		console \

	DEFINES += \
		DEBUG \

	HEADERS += \
		common.h \
		common_d.h \

	SOURCES += \
		debug.cpp \
		main.cpp \

}

Release {
	TARGET = TargetRelease
	CONFIG += \
		console \

	DEFINES += \
		RELEASE \
		NDEBUG \

	HEADERS += \
		common.h \
		common_r.h \

	SOURCES += \
		main.cpp \
		release.cpp \

}
	]]
end
