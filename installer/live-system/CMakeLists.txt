cmake_minimum_required(VERSION 3.21)
project(MeoSystemLive VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Core DBus Network Qml)
find_package(KF6NetworkManagerQt REQUIRED)
find_package(KF6BluezQt REQUIRED)
find_package(KF6Solid REQUIRED)
find_package(KF6PulseAudioQt REQUIRED)
find_package(KF6I18n REQUIRED)

if(NOT MEO_KDE_SOURCE_DIR)
    message(FATAL_ERROR "MEO_KDE_SOURCE_DIR must identify the validated MeoKDE source tree")
endif()
set(meo_system_source_dir "${MEO_KDE_SOURCE_DIR}/native/system")
if(NOT EXISTS "${meo_system_source_dir}/systemstatehub.cpp")
    message(FATAL_ERROR "MeoKDE SystemStateHub source is missing")
endif()

# The Live ISO needs the shared network/audio state backend, but not the
# Plasma-only desktop widget and dynamic-color providers from the full desktop
# plugin. Keeping this adapter deliberately small prevents a Cage Live image
# from acquiring a hidden plasma-workspace/libkrdb runtime dependency.
add_library(meosystemplugin MODULE
    meosystemliveplugin.cpp
    "${meo_system_source_dir}/systemstatehub.cpp"
    "${meo_system_source_dir}/systemstatehub.h"
)
set_target_properties(meosystemplugin PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml/Meo/System"
)
target_include_directories(meosystemplugin PRIVATE "${meo_system_source_dir}")
target_link_libraries(meosystemplugin PRIVATE
    Qt6::Core
    Qt6::DBus
    Qt6::Network
    Qt6::Qml
    KF6::NetworkManagerQt
    KF6::BluezQt
    KF6::Solid
    KF6::PulseAudioQt
    KF6::I18n
)

configure_file(qmldir "${CMAKE_BINARY_DIR}/qml/Meo/System/qmldir" COPYONLY)
