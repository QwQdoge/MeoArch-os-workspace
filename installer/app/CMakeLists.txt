qt_add_executable(meoarch-installer-app
    main.cpp
    installercontroller.cpp
    installercontroller.h
)

find_program(MEOARCH_LRELEASE_EXECUTABLE NAMES lrelease lrelease-qt6 HINTS /usr/lib/qt6/bin)
if(MEOARCH_LRELEASE_EXECUTABLE)
    set(MEOARCH_TRANSLATION_QM "${CMAKE_BINARY_DIR}/translations/meoarch_zh_CN.qm")
    add_custom_command(
        OUTPUT "${MEOARCH_TRANSLATION_QM}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_BINARY_DIR}/translations"
        COMMAND "${MEOARCH_LRELEASE_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/../translations/meoarch_zh_CN.ts" -qm "${MEOARCH_TRANSLATION_QM}"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/../translations/meoarch_zh_CN.ts"
        VERBATIM
    )
    add_custom_target(meoarch-installer-translations DEPENDS "${MEOARCH_TRANSLATION_QM}")
    add_dependencies(meoarch-installer-app meoarch-installer-translations)
    target_compile_definitions(meoarch-installer-app PRIVATE MEOARCH_TRANSLATIONS_BUILD_DIR="${CMAKE_BINARY_DIR}/translations")
endif()

if(WIN32)
    target_sources(meoarch-installer-app PRIVATE
        meoarch-installer-app.rc
        meoarch-installer-app.manifest
    )
endif()

target_link_libraries(meoarch-installer-app PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::Network KF6::I18n
)
target_compile_definitions(meoarch-installer-app PRIVATE
    MEOARCH_QML_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/../qml"
    MEOUI_QML_BUILD_IMPORT_PATH="${CMAKE_BINARY_DIR}/meoui"
)
set_target_properties(meoarch-installer-app PROPERTIES
    WIN32_EXECUTABLE FALSE
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)

install(TARGETS meoarch-installer-app RUNTIME DESTINATION bin)
