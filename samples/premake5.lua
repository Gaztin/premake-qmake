require "../qmake"

workspace "Samples"
	configurations {"Debug", "Release"}
	platforms {"win32", "unix"}

project "WidgetsSample"
	kind "WindowedApp"
	location "projects"
	files {"widgets.cpp"}
	qtmodules {"core", "gui", "widgets"}
