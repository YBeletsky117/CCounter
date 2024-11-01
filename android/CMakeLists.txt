cmake_minimum_required(VERSION 3.9.0)
project(DragonFamilyCounterComponent)

set (CMAKE_VERBOSE_MAKEFILE ON)
set (CMAKE_CXX_STANDARD 17)

add_library(dragon-family-counter-component
        SHARED
        ../cpp/CounterLogic.cpp
        cpp-adapter.cpp
)

find_library(log-lib log)

# Specifies a path to native header files.
include_directories(
        ../cpp
)

target_link_libraries(
        dragon-family-counter-component
        ${log-lib}                  # <-- Logcat logger
        android                     # <-- Android JNI core
)
