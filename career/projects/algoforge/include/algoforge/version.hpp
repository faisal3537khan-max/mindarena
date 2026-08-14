#pragma once

#define ALGOFORGE_VERSION_MAJOR 1
#define ALGOFORGE_VERSION_MINOR 2
#define ALGOFORGE_VERSION_PATCH 0
#define ALGOFORGE_VERSION "1.2.0"

#include <limits>

namespace algoforge {

constexpr const char* kVersion = ALGOFORGE_VERSION;
constexpr double kInf = std::numeric_limits<double>::infinity();

}  // namespace algoforge
