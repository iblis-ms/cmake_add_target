CMake_minimum_required(VERSION 3.5.2 FATAL_ERROR)
project(ProjectName)
enable_testing()
include("${CMAKE_CURRENT_SOURCE_DIR}/../../AddTarget.cmake")


add_subdirectory(libraryInterfaceA)
add_subdirectory(libraryInterfaceB)
add_subdirectory(libraryInterfaceC)
add_subdirectory(libraryA)
add_subdirectory(exeA)

set_property (DIRECTORY PROPERTY VS_STARTUP_PROJECT LibraryA)
