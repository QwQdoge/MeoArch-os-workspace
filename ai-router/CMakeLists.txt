cmake_minimum_required(VERSION 3.21)

project(MeoArchAiRouter VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core)

add_library(meo-ai-router-core STATIC
    core/capabilityregistry.cpp
    core/capabilityregistry.h
    core/policyengine.cpp
    core/policyengine.h
    core/systemairouter.cpp
    core/systemairouter.h
    core/settingsdeeplinkexecutor.cpp
    core/settingsdeeplinkexecutor.h
    core/terminalworkspaceexecutor.cpp
    core/terminalworkspaceexecutor.h
    core/mcpgatewayadapter.cpp
    core/mcpgatewayadapter.h
)

target_include_directories(meo-ai-router-core PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/core"
)

target_link_libraries(meo-ai-router-core PUBLIC Qt6::Core)

qt_add_executable(meo-ai-router
    app/main.cpp
)
target_link_libraries(meo-ai-router PRIVATE meo-ai-router-core Qt6::Core)

qt_add_executable(meo-ai-router-contract-test
    tests/router-contract-test.cpp
)
target_link_libraries(meo-ai-router-contract-test PRIVATE meo-ai-router-core Qt6::Core)

enable_testing()
add_test(NAME meo-ai-router-contract COMMAND meo-ai-router-contract-test)

install(TARGETS meo-ai-router RUNTIME DESTINATION bin)
