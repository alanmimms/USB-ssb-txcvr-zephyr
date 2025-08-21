# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(my-blinky-app-cpp)

# Specify the C++ standard for the target
target_compile_features(app PRIVATE cxx_std_20)

# Point to the C++ source file
target_sources(app PRIVATE src/main.cpp)
