qt_add_executable(meoarch-installer-app
    main.cpp
    installercontroller.cpp
    installercontroller.h
)

if(WIN32)
    target_sources(meoarch-installer-app PRIVATE
        meoarch-installer-app.rc
        meoarch-installer-app.manifest
    )
endif()

target_link_libraries(meoarch-installer-app PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::Network
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
