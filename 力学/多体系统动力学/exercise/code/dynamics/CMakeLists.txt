cmake_minimum_required(VERSION 3.25)
project(lianxi1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# MSVC：让编译器按 UTF-8 读写源码（源文件里有中文注释和 λ 等字符）
if(MSVC)
    add_compile_options(/utf-8)
endif()

# Eigen 头文件位置（想换版本改这里，或在 CMake 里改缓存变量 EIGEN_DIR）
set(EIGEN_DIR "D:/libs/eigen-5.0.0" CACHE PATH "Eigen 头文件目录")
if(NOT EXISTS "${EIGEN_DIR}/Eigen/Dense")
    message(FATAL_ERROR "找不到 Eigen 头文件: ${EIGEN_DIR}")
endif()

# 可执行文件：lianxi1
add_executable(lianxi1 lianxi1.cpp)
target_include_directories(lianxi1 PRIVATE "${EIGEN_DIR}")
