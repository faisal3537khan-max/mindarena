cmake_minimum_required(VERSION 3.16)
project(algoforge VERSION 1.2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(ALGOFORGE_BUILD_TESTS "Build unit tests" ON)
option(ALGOFORGE_BUILD_BENCH "Build benchmarks" ON)

add_library(algoforge INTERFACE)
add_library(algoforge::algoforge ALIAS algoforge)
target_include_directories(algoforge INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>
)

function(algoforge_warnings target)
  if(MSVC)
    target_compile_options(${target} PRIVATE /W4 /permissive- /WX)
  else()
    target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic -Werror)
  endif()
endfunction()

if(ALGOFORGE_BUILD_TESTS)
  enable_testing()
  add_executable(algoforge_test tests/test_algoforge.cpp)
  target_link_libraries(algoforge_test PRIVATE algoforge)
  algoforge_warnings(algoforge_test)
  add_test(NAME algoforge_test COMMAND algoforge_test)
endif()

if(ALGOFORGE_BUILD_BENCH)
  add_executable(algoforge_bench src/bench.cpp)
  target_link_libraries(algoforge_bench PRIVATE algoforge)
  algoforge_warnings(algoforge_bench)
endif()

install(DIRECTORY include/ DESTINATION include)
install(TARGETS algoforge EXPORT algoforgeTargets)
install(EXPORT algoforgeTargets
  FILE algoforgeTargets.cmake
  NAMESPACE algoforge::
  DESTINATION lib/cmake/algoforge
)
