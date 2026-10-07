cmake_minimum_required(VERSION 3.21)
project(MeoSystemTransaction VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core DBus)
qt_standard_project_setup(REQUIRES 6.6)

add_library(meo-system-transaction-core STATIC
    src/transactionvalidator.cpp
    src/transactionvalidator.h
)
target_link_libraries(meo-system-transaction-core PUBLIC Qt6::Core)

a dd_executable_placeholder()
