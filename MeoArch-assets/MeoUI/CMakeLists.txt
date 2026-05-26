cmake_minimum_required(VERSION 3.16)
project(MeoUI LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Quick)

# 定义 QML 模块
qt_add_qml_module(meoui_module
    URI "MeoUI"
    VERSION 1.0
    QML_FILES
        MeoTheme.qml
        components/MeoButton.qml
        components/MeoSegmentedButtons.qml
        components/MeoTextField.qml
        components/MeoCheckbox.qml
        components/MeoSwitch.qml
        components/MeoSlider.qml
        components/MeoRadioButton.qml
        components/MeoFAB.qml
        components/MeoCard.qml
        components/MeoChip.qml
        components/MeoProgressBar.qml
        components/MeoNavigationBar.qml
        components/MeoDialog.qml
        components/MeoBadge.qml
        components/MeoDivider.qml
        components/MeoListItem.qml
        components/MeoMenu.qml
        components/MeoTabs.qml
        components/MeoTooltip.qml
        components/MeoSnackbar.qml
        widgets/MeoMediaController.qml
        widgets/MeoDatePicker.qml
        widgets/MeoTimePicker.qml
        widgets/MeoNavigationRail.qml
        widgets/MeoNavigationDrawer.qml
        widgets/MeoBottomSheet.qml
        widgets/MeoSearchBar.qml
)

# 确保链接到 QtQuick
target_link_libraries(meoui_module PUBLIC Qt6::Core Qt6::Quick)
