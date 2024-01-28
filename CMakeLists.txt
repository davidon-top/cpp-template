cmake_minimum_required(VERSION 3.28)
project({{project-name}} LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)

file(GLOB_RECURSE SOURCES "src/*.cpp" "src/*.h" "src/*.hpp" "src/*.c")

add_executable(${PROJECT_NAME} ${SOURCES})
