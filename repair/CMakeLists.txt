cmake_minimum_required(VERSION 3.21)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    project(MeoArchRepair VERSION 0.1.0 LANGUAGES CXX)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_AUTOMOC ON)
    find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Network)
    qt_standard_project_setup(REQUIRES 6.6)
    set(MEOUI_BUILD_SHOWCASE OFF CACHE BOOL "Build MeoUI showcase" FORCE)
    add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../../meo-ui" "${CMAKE_BINARY_DIR}/meoui")
endif()

find_package(Qt6Keychain CONFIG REQUIRED)

add_library(meoarch-repair-core STATIC
    "${CMAKE_CURRENT_SOURCE_DIR}/../installer/app/repaircontroller.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/../installer/app/repaircontroller.h"
)
target_include_directories(meoarch-repair-core PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/../installer/app"
)
target_link_libraries(meoarch-repair-core PUBLIC
    Qt6::Core Qt6::Network Qt6Keychain::Qt6Keychain
)
target_compile_definitions(meoarch-repair-core PRIVATE
    MEOARCH_REPAIR_CHECKS_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/checks"
    MEOARCH_REPAIR_ACTIONS_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/actions"
)

qt_add_executable(meoarch-repair
    app/main.cpp
)
target_link_libraries(meoarch-repair PRIVATE
    meoarch-repair-core
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::Network
)
target_compile_definitions(meoarch-repair PRIVATE
    MEOARCH_REPAIR_QML_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/qml"
    MEOUI_QML_BUILD_IMPORT_PATH="${CMAKE_BINARY_DIR}/meoui"
)
set_target_properties(meoarch-repair PROPERTIES
    WIN32_EXECUTABLE FALSE
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)

install(TARGETS meoarch-repair RUNTIME DESTINATION bin)
install(DIRECTORY qml/ DESTINATION lib/meoarch-repair/qml)
install(PROGRAMS
    checks/all.sh checks/network.sh checks/boot.sh checks/packages.sh
    checks/storage.sh checks/graphics.sh checks/security.sh
    DESTINATION lib/meoarch-repair/checks
)
install(PROGRAMS
    actions/reload-systemd-manager.sh actions/restart-network-manager.sh
    actions/rebuild-initramfs.sh actions/refresh-pacman-keyring.sh
    DESTINATION lib/meoarch-repair/actions
)
install(FILES data/org.meo.repair.desktop DESTINATION share/applications)
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../meo-ui/assets/icons/meo-ai-f.svg"
        DESTINATION share/icons/hicolor/scalable/apps RENAME meoarch-ai.svg)
