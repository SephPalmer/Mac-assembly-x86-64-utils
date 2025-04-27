cmake_minimum_required(VERSION 3.15) # Example version
project(AssemblyUtilsProject ASM) # Use ASM for GAS, or C/CXX if mixing

# If using GAS (.s files), CMake might handle them automatically if ASM is enabled
add_executable(UtilsTestExecutable utils.s utiltests.s)