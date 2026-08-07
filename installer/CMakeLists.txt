cmake_minimum_required(VERSION 3.21)
project(MeoArchInstaller VERSION 0.3.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Network)
qt_standard_project_setup(REQUIRES 6.6)

set(MEOUI_BUILD_SHOWCASE OFF CACHE BOOL "Build MeoUI showcase" FORCE)
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../../meo-ui" "${CMAKE_BINARY_DIR}/meoui")
add_subdirectory(app)
