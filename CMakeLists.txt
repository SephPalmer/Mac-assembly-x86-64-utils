cmake_minimum_required(VERSION 3.15) # Example version
set(CMAKE_C_STANDARD 11)
project(AssemblyUtilsProject C) # Use ASM for GAS, or C/CXX if mixing

# Add my core library
add_subdirectory(lib)

# If using GAS (.s files), CMake might handle them automatically if ASM is enabled
add_executable(app main.c) # Replace with your source files

# Link the executable ("app") against our library ("mymath_lib")
# target_link_libraries(<target_name> [PUBLIC | PRIVATE | INTERFACE] [lib1] [lib2 ...])
#
# PUBLIC: Links library AND propagates usage requirements (like include directories) further.
# PRIVATE: Links library, usage requirements only apply to this target, not consumers.
# INTERFACE: Doesn't link library directly, but propagates usage requirements (for header-only libs mostly).
#
# For linking an executable to a library, PRIVATE is usually appropriate.
target_link_libraries(app PRIVATE core_lib)