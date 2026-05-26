cmake_minimum_required(VERSION 3.16)
project(MeoUI LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Quick)

# 定义 QML 模块
qt_add_qml_module(meoui_module
    URI "MeoUI"  # 这里对应你在 QML 中 import 的名字
    VERSION 1.0
    QML_FILES
        components/MeoButton.qml
        components/MeoSegmentedButtons.qml
        components/MeoTextField.qml
        MeoTheme.qml
        # 把你所有需要导出的组件都列在这里
)

# 确保链接到 QtQuick
target_link_libraries(meoui_module PUBLIC Qt6::Core Qt6::Quick)
