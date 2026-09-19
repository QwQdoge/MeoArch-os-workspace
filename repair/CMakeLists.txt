cmake_minimum_required(VERSION 3.21)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    project(MeoArchRepair VERSION 0.1.0 LANGUAGES CXX)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_AUTOMOC ON)
    find_package(Qt6 6.6 REQUIRED COMPONENTS Core DBus Gui Qml Quick QuickControls2 Network)
    qt_standard_project_setup(REQUIRES 6.6)
    set(MEOUI_BUILD_SHOWCASE OFF CACHE BOOL "Build MeoUI showcase" FORCE)
    add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../../meo-ui" "${CMAKE_BINARY_DIR}/meoui")
endif()

find_package(Qt6Keychain CONFIG REQUIRED)
find_package(PolkitQt6-1 CONFIG REQUIRED)

find_program(MEOARCH_REPAIR_LRELEASE_EXECUTABLE NAMES lrelease lrelease-qt6 HINTS /usr/lib/qt6/bin)
find_program(MEOARCH_REPAIR_LUPDATE_EXECUTABLE NAMES lupdate lupdate-qt6 HINTS /usr/lib/qt6/bin)
if(MEOARCH_REPAIR_LRELEASE_EXECUTABLE)
    set(MEOARCH_REPAIR_TRANSLATIONS_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/translations")
    set(MEOARCH_REPAIR_TRANSLATION_TS_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/translations/meoarch_repair_en.ts"
        "${CMAKE_CURRENT_SOURCE_DIR}/translations/meoarch_repair_zh_CN.ts"
    )
    set(MEOARCH_REPAIR_TRANSLATION_QM_FILES)
    foreach(translation_ts IN LISTS MEOARCH_REPAIR_TRANSLATION_TS_FILES)
        get_filename_component(translation_name "${translation_ts}" NAME_WE)
        set(translation_qm
            "${MEOARCH_REPAIR_TRANSLATIONS_BUILD_DIR}/${translation_name}.qm")
        add_custom_command(
            OUTPUT "${translation_qm}"
            COMMAND "${CMAKE_COMMAND}" -E make_directory "${MEOARCH_REPAIR_TRANSLATIONS_BUILD_DIR}"
            COMMAND "${MEOARCH_REPAIR_LRELEASE_EXECUTABLE}"
                    "${translation_ts}"
                    -qm "${translation_qm}"
            DEPENDS "${translation_ts}"
            VERBATIM
        )
        list(APPEND MEOARCH_REPAIR_TRANSLATION_QM_FILES "${translation_qm}")
    endforeach()
    add_custom_target(meoarch-repair-translations
        DEPENDS ${MEOARCH_REPAIR_TRANSLATION_QM_FILES})
endif()
if(MEOARCH_REPAIR_LUPDATE_EXECUTABLE)
    add_custom_target(meoarch-repair-update-translations
        COMMAND "${MEOARCH_REPAIR_LUPDATE_EXECUTABLE}"
                "${CMAKE_CURRENT_SOURCE_DIR}/qml/Main.qml"
                -ts "${CMAKE_CURRENT_SOURCE_DIR}/translations/meoarch_repair_en.ts"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "Update the reviewed MeoArch Repair English catalog")
    add_custom_target(meoarch-repair-update-zh-translations
        COMMAND "${MEOARCH_REPAIR_LUPDATE_EXECUTABLE}"
                "${CMAKE_CURRENT_SOURCE_DIR}/../installer/app/repaircontroller.cpp"
                -ts "${CMAKE_CURRENT_SOURCE_DIR}/translations/meoarch_repair_zh_CN.ts"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "Update the reviewed MeoArch Repair Simplified Chinese catalog")
endif()

add_library(meoarch-repair-core STATIC
    "${CMAKE_CURRENT_SOURCE_DIR}/../installer/app/repaircontroller.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/../installer/app/repaircontroller.h"
    core/capabilityregistry.cpp
    core/capabilityregistry.h
    core/agentstate.cpp
    core/agentstate.h
    core/sessionjournal.cpp
    core/sessionjournal.h
)
target_include_directories(meoarch-repair-core PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/../installer/app"
    "${CMAKE_CURRENT_SOURCE_DIR}/core"
)
target_link_libraries(meoarch-repair-core PUBLIC
    Qt6::Core Qt6::DBus Qt6::Network Qt6Keychain::Qt6Keychain
)
target_compile_definitions(meoarch-repair-core PRIVATE
    MEOARCH_REPAIR_CHECKS_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/checks"
    MEOARCH_REPAIR_ACTIONS_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/actions"
    MEOARCH_REPAIR_KNOWLEDGE_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/knowledge"
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
    MEOUI_TRANSLATIONS_BUILD_DIR="${CMAKE_BINARY_DIR}/meoui/translations"
)
if(TARGET meoarch-repair-translations)
    add_dependencies(meoarch-repair meoarch-repair-translations)
    target_compile_definitions(meoarch-repair PRIVATE
        MEOARCH_REPAIR_TRANSLATIONS_BUILD_DIR="${MEOARCH_REPAIR_TRANSLATIONS_BUILD_DIR}")
endif()
if(TARGET meoui_lrelease)
    add_dependencies(meoarch-repair meoui_lrelease)
endif()
set_target_properties(meoarch-repair PROPERTIES
    WIN32_EXECUTABLE FALSE
    QT_QML_MODULE_NO_IMPORT_SCAN TRUE
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)

qt_add_executable(meoarch-repair-ai-flow-smoke
    tests/ai-flow-smoke.cpp
)
target_link_libraries(meoarch-repair-ai-flow-smoke PRIVATE
    meoarch-repair-core
    Qt6::Core Qt6::Network
)
set_target_properties(meoarch-repair-ai-flow-smoke PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)

qt_add_executable(meoarch-repair-core-contract-test
    tests/core-contract-test.cpp
)
target_link_libraries(meoarch-repair-core-contract-test PRIVATE
    meoarch-repair-core
    Qt6::Core
)
set_target_properties(meoarch-repair-core-contract-test PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)

qt_add_executable(meoarch-repair-privileged-service
    privileged/main.cpp
    privileged/privilegedrepairservice.cpp
    privileged/privilegedrepairservice.h
)
target_link_libraries(meoarch-repair-privileged-service PRIVATE
    Qt6::Core Qt6::DBus PolkitQt6-1::Core
)
set_target_properties(meoarch-repair-privileged-service PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)

install(TARGETS meoarch-repair RUNTIME DESTINATION bin)
if(MEOARCH_REPAIR_TRANSLATION_QM_FILES)
    install(FILES ${MEOARCH_REPAIR_TRANSLATION_QM_FILES}
            DESTINATION share/meoarch-repair/translations)
endif()
install(TARGETS meoarch-repair-privileged-service
        RUNTIME DESTINATION lib/meoarch-repair)
install(DIRECTORY qml/ DESTINATION lib/meoarch-repair/qml)
install(PROGRAMS
    checks/all.sh checks/audio.sh checks/display.sh checks/network.sh checks/boot.sh checks/packages.sh
    checks/storage.sh checks/graphics.sh checks/security.sh
    DESTINATION lib/meoarch-repair/checks
)
install(PROGRAMS
    actions/reload-systemd-manager.sh actions/restart-network-manager.sh
    actions/rebuild-initramfs.sh actions/refresh-pacman-keyring.sh
    DESTINATION lib/meoarch-repair/actions
)
install(FILES data/org.meo.repair.desktop DESTINATION share/applications)
install(FILES data/org.meo.repair.policy DESTINATION share/polkit-1/actions)
install(FILES data/org.meo.Repair1.conf DESTINATION share/dbus-1/system.d)
install(FILES data/org.meo.Repair1.service DESTINATION share/dbus-1/system-services)
install(FILES data/meoarch-repair-privileged.service DESTINATION lib/systemd/system)
install(FILES docs/security-architecture.md DESTINATION share/doc/meoarch-repair)
install(DIRECTORY knowledge/ DESTINATION share/meoarch-repair/knowledge)
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/../../meo-ui/assets/icons/meo-ai-f.svg"
        DESTINATION share/icons/hicolor/scalable/apps RENAME meoarch-ai.svg)
