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

add_executable(meo-system-transaction-service
    src/main.cpp
    src/systemtransactionservice.cpp
    src/systemtransactionservice.h
)
target_link_libraries(meo-system-transaction-service PRIVATE
    meo-system-transaction-core
    Qt6::Core
    Qt6::DBus
)
set_target_properties(meo-system-transaction-service PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)

install(TARGETS meo-system-transaction-service
        RUNTIME DESTINATION lib/meo-system-transaction)
install(FILES data/org.meo.SystemTransaction1.conf
        DESTINATION share/dbus-1/system.d)
install(FILES data/org.meo.SystemTransaction1.service
        DESTINATION share/dbus-1/system-services)
install(FILES data/meo-system-transaction.service
        DESTINATION lib/systemd/system)
