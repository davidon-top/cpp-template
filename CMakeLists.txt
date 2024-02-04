cmake_minimum_required(VERSION 3.28)
project({{project-name}} LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)

file(GLOB_RECURSE SOURCES "src/*.cpp" "src/*.h" "src/*.hpp" "src/*.c")

{% if crate_type == "bin" %}add_executable(${PROJECT_NAME} ${SOURCES}){% endif %}{% if crate_type == "lib" %}add_library(${PROJECT_NAME} ${SOURCES}){% endif %}
