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

MyProject.subdir = MyProject
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

CONFIG(debug, debug|release) {
	MOC_DIR = "../obj/Debug"
	RCC_DIR = "../obj/Debug"
	UI_DIR = "../obj/Debug"
	CONFIG += \
		console \

}

CONFIG(release, debug|release) {
	MOC_DIR = "../obj/Release"
	RCC_DIR = "../obj/Release"
	UI_DIR = "../obj/Release"
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

CONFIG(debug, debug|release) {
	MOC_DIR = "../obj/Debug"
	RCC_DIR = "../obj/Debug"
	UI_DIR = "../obj/Debug"
	CONFIG += \
		console \

}

CONFIG(release, debug|release) {
	MOC_DIR = "../obj/Release"
	RCC_DIR = "../obj/Release"
	UI_DIR = "../obj/Release"
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

CONFIG(debug, debug|release) {
	MOC_DIR = "../obj/Debug"
	RCC_DIR = "../obj/Debug"
	UI_DIR = "../obj/Debug"
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

CONFIG(debug, debug|release) {
	MOC_DIR = "../obj/Debug"
	RCC_DIR = "../obj/Debug"
	UI_DIR = "../obj/Debug"
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

CONFIG(debug, debug|release) {
	MOC_DIR = "../obj/Debug"
	RCC_DIR = "../obj/Debug"
	UI_DIR = "../obj/Debug"
	CONFIG += \
		static \

}
	]]
end

function suite.qmake_ObscureConfigNames()
	local wks2 = workspace("MyWorkspace2")
	configurations { "NotRelease", "NotDebug" }

	local prj2 = project("MyProject1")
	language "C++"
	kind "ConsoleApp"
	filter { "configurations:NotRelease" }
	symbols "On"
	filter { "configurations:NotDebug" }
	symbols "Off"

	prj2 = test.getproject(wks2, 1)
	qmake.project.generate(prj2)
	test.capture [[
TEMPLATE = app

CONFIG(debug, debug|release) {
	MOC_DIR = "../obj/NotRelease"
	RCC_DIR = "../obj/NotRelease"
	UI_DIR = "../obj/NotRelease"
	CONFIG += \
		console \

}

CONFIG(release, debug|release) {
	MOC_DIR = "../obj/NotDebug"
	RCC_DIR = "../obj/NotDebug"
	UI_DIR = "../obj/NotDebug"
	CONFIG += \
		console \

}
	]]
end

function suite.qmake_AdvancedProject()
	toolset("msc")
	files {"common.h", "main.cpp"}
	includedirs {"include/dir/"}
	links {"test1", "path/to/test2"}
	qtmodules {"core", "gui", "widgets"}

	filter("Debug")
	targetname("TargetDebug")
	defines {"DEBUG"}
	files {"common_d.h", "debug.cpp"}
	includedirs {"include/dir/debug/"}
	links {"debug"}
	objdir("objs/debug/")
	qtmodules {"network"}

	filter("Release")
	targetname("TargetRelease")
	defines {"RELEASE", "NDEBUG"}
	files {"common_r.h", "release.cpp"}
	includedirs {"include/dir/release/"}
	links {"release"}
	objdir("objs/release/")

	prepare()
	qmake.project.generate(prj)
	test.capture [[
TEMPLATE = app

CONFIG(debug, debug|release) {
	TARGET = TargetDebug
	MOC_DIR = "../objs/debug"
	RCC_DIR = "../objs/debug"
	UI_DIR = "../objs/debug"
	QT += \
		core \
		gui \
		widgets \
		network \

	CONFIG += \
		console \

	DEFINES += \
		DEBUG \

	HEADERS += \
		../common.h \
		../common_d.h \

	SOURCES += \
		../debug.cpp \
		../main.cpp \

	INCLUDEPATH += \
		"../include/dir" \
		"../include/dir/debug" \

	LIBS += \
		"test1.lib" \
		"../path/to/test2.lib" \
		"debug.lib" \

}

CONFIG(release, debug|release) {
	TARGET = TargetRelease
	MOC_DIR = "../objs/release"
	RCC_DIR = "../objs/release"
	UI_DIR = "../objs/release"
	QT += \
		core \
		gui \
		widgets \

	CONFIG += \
		console \

	DEFINES += \
		RELEASE \
		NDEBUG \

	HEADERS += \
		../common.h \
		../common_r.h \

	SOURCES += \
		../main.cpp \
		../release.cpp \

	INCLUDEPATH += \
		"../include/dir" \
		"../include/dir/release" \

	LIBS += \
		"test1.lib" \
		"../path/to/test2.lib" \
		"release.lib" \

}
	]]
end
