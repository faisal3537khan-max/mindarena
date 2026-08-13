cmake_minimum_required(VERSION 3.16)
project(algoforge LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(algoforge INTERFACE)
target_include_directories(algoforge INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/include)

add_executable(algoforge_bench src/bench.cpp)
target_link_libraries(algoforge_bench PRIVATE algoforge)

add_executable(algoforge_test tests/test_algoforge.cpp)
target_link_libraries(algoforge_test PRIVATE algoforge)

enable_testing()
add_test(NAME algoforge_test COMMAND algoforge_test)
