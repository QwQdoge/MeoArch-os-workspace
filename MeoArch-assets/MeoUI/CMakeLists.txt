cmake_minimum_required(VERSION 3.16)
project(MeoUI LANGUAGES CXX)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 REQUIRED COMPONENTS Core Quick QuickControls2 Core5Compat Gui Qml)

set_source_files_properties(MeoTheme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

# 定义 QML 模块
qt_add_qml_module(meoui_module
    URI "MeoUI"
    VERSION 1.0
    OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/MeoUI"
    QML_FILES
                widgets/MeoNavigationBar.qml
        widgets/MeoNavigationDrawerModal.qml
        patterns/MeoAppLayout.qml
        patterns/MeoFeedLayout.qml
        patterns/MeoDashboardLayout.qml
        showcase/pages/ButtonsPage.qml
        showcase/pages/InputsPage.qml
        showcase/pages/NavigationPage.qml
        showcase/pages/SelectionPage.qml
        showcase/pages/DisplayPage.qml
        showcase/pages/FeedbackPage.qml
        showcase/pages/PatternsPage.qml
        showcase/pages/DataTablePage.qml
MeoTheme.qml
        components/MeoButton.qml
        components/MeoDockedToolbar.qml
        components/MeoFloatingToolbar.qml
        components/MeoSegmentedButtons.qml
        components/MeoTextField.qml
        components/MeoTextArea.qml
        components/MeoBanner.qml
        components/MeoBreadcrumbs.qml
        components/MeoRangeSlider.qml
        components/MeoCarousel.qml
        components/MeoFullScreenDialog.qml
        components/MeoPageIndicator.qml
        components/MeoCheckbox.qml
        components/MeoSwitch.qml
        components/MeoSlider.qml
        components/MeoRadioButton.qml
        components/MeoFAB.qml
        components/MeoCard.qml
        components/MeoChip.qml
        components/MeoProgressBar.qml
        components/MeoDialog.qml
        components/MeoBadge.qml
        components/MeoDivider.qml
        components/MeoListItem.qml
        components/MeoMenu.qml
        components/MeoTabs.qml
        components/MeoTooltip.qml
        components/MeoSnackbar.qml
        components/MeoStateLayer.qml
        components/MeoFilterChip.qml
        components/MeoInputChip.qml
        components/MeoPullToRefresh.qml
        components/MeoFilterGroup.qml
        components/MeoListHeader.qml
        components/MeoSelectionGroup.qml
        components/MeoNavigationDrawerItem.qml
        components/MeoDateInput.qml
        components/MeoTimeInput.qml
        components/MeoIcon.qml
        components/MeoIconButton.qml
        components/MeoDataTable.qml
        components/MeoExposedDropdown.qml
        components/MeoRichTooltip.qml
        widgets/MeoMediaController.qml
        widgets/MeoDatePicker.qml
        widgets/MeoDateRangePicker.qml
        widgets/MeoTimePicker.qml
        widgets/MeoNavigationRail.qml
        widgets/MeoNavigationDrawer.qml
        widgets/MeoBottomSheet.qml
        widgets/MeoAccountHeader.qml
        widgets/MeoSearchBar.qml
        widgets/MeoDockedSearchBar.qml
        widgets/MeoBottomAppBar.qml
        widgets/MeoSearchView.qml
        widgets/MeoTopAppBar.qml
        widgets/MeoSearchSuggestions.qml
        components/MeoAssistChip.qml
        components/MeoSuggestionChip.qml
        components/MeoSkeleton.qml
        widgets/MeoSideSheetModal.qml
        widgets/MeoSideSheet.qml
        widgets/MeoStandardBottomSheet.qml
        patterns/MeoEmptyState.qml
        patterns/MeoScaffold.qml
        patterns/MeoListDetailLayout.qml
        patterns/MeoSettingsLayout.qml
        patterns/MeoSearchFilterBar.qml
        showcase/MeoShowcase.qml
)

# 确保链接到 QtQuick
target_link_libraries(meoui_module PUBLIC Qt6::Core Qt6::Quick Qt6::QuickControls2 Qt6::Core5Compat)

# 新增 Demo 展示程序可执行目标
qt_add_executable(MeoShowcaseDemo
    main.cpp
)

target_link_libraries(MeoShowcaseDemo PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Core5Compat
    meoui_module
)

# 移除不支持的 qt_import_qml_modules，改用设置 target 属性
set_target_properties(MeoShowcaseDemo PROPERTIES
    QT_QML_IMPORT_PATH "${CMAKE_BINARY_DIR}"
)
