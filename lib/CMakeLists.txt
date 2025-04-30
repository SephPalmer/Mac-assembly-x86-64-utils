# Define the library target


set(CMAKE_C_STANDARD 11)
enable_language(ASM)

# add_library(<target_name> [STATIC | SHARED | MODULE] [source1] [source2 ...])
# By default, CMake often builds STATIC libraries, but you can be explicit.
# Let's call our library target "mymath_lib"
add_library(core_lib STATIC # Or SHARED for a dynamic/shared library
        core.c
        core.h # Good practice to include headers here too
        core.s
)

# Specify include directories needed by consumers of this library.
# target_include_directories(<target_name> [PUBLIC | PRIVATE | INTERFACE] [dir1] [dir2 ...])
#
# PUBLIC: The include directories are used for compiling the target itself
#         AND are propagated to targets that link against this one.
# PRIVATE: Only used for compiling the target itself.
# INTERFACE: Only propagated to targets that link against this one.
#
# We want anyone linking to mymath_lib to automatically know where mymath.h is.
# ${CMAKE_CURRENT_SOURCE_DIR} refers to the directory containing this CMakeLists.txt (i.e., lib/)
target_include_directories(core_lib
        PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
)

# Optional: Set properties like C standard
# target_compile_features(mymath_lib PUBLIC c_std_99) # Example for C99