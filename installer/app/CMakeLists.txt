qt_add_executable(meoarch-installer-app
    main.cpp
    installercontroller.cpp
    installercontroller.h
)

target_link_libraries(meoarch-installer-app PRIVATE
    Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::Network
    meoui_module
)
qt_import_qml_plugins(meoarch-installer-app)
set_target_properties(meoarch-installer-app PROPERTIES WIN32_EXECUTABLE FALSE)

install(TARGETS meoarch-installer-app RUNTIME DESTINATION bin)
