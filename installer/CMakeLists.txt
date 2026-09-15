cmake_minimum_required(VERSION 3.21)
project(MeoArchInstaller VERSION 0.3.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Network)
find_package(Qt6Keychain CONFIG REQUIRED)
find_package(KF6I18n REQUIRED)
qt_standard_project_setup(REQUIRES 6.6)

set(MEOUI_BUILD_SHOWCASE OFF CACHE BOOL "Build MeoUI showcase" FORCE)
set(_meoui_default_source "${CMAKE_CURRENT_SOURCE_DIR}/../../meo-ui")
if(NOT EXISTS "${_meoui_default_source}/CMakeLists.txt"
   AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../../MeoUI/CMakeLists.txt")
    set(_meoui_default_source "${CMAKE_CURRENT_SOURCE_DIR}/../../MeoUI")
endif()
set(MEOUI_SOURCE_DIR "${_meoui_default_source}" CACHE PATH "Path to the MeoUI source checkout")
if(NOT EXISTS "${MEOUI_SOURCE_DIR}/CMakeLists.txt")
    message(FATAL_ERROR "MeoUI source not found at ${MEOUI_SOURCE_DIR}; set MEOUI_SOURCE_DIR explicitly")
endif()
add_subdirectory("${MEOUI_SOURCE_DIR}" "${CMAKE_BINARY_DIR}/meoui")
get_target_property(MEOUI_RUNTIME_VERSION meoui_module VERSION)
if(NOT MEOUI_RUNTIME_VERSION OR MEOUI_RUNTIME_VERSION VERSION_LESS "1.0.4")
    message(FATAL_ERROR
        "MeoArch Installer requires MeoUI 1.0.4 beta 1 or newer; "
        "${MEOUI_SOURCE_DIR} provides ${MEOUI_RUNTIME_VERSION}")
endif()
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../repair" "${CMAKE_BINARY_DIR}/repair")
add_subdirectory(app)
