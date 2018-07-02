
include_guard()

# All the things that are not required to use the same values as USD
set(FMT_LOCATION ${LOCAL_ROOT})
set(GLFW_LOCATION ${LOCAL_ROOT})
set(GLM_ROOT_DIR ${LOCAL_ROOT})
set(TBB_ROOT_DIR ${LOCAL_ROOT})
set(USD_ROOT ${LOCAL_ROOT})

link_directories(${LOCAL_ROOT}/lib)

# --math
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    find_library(M_LIB m)
endif()

find_package(Assimp)
find_package(OpenGL)
find_package(GLFW)
find_package(GLM)
find_package(Fmt)
find_package(TBB)
find_package(USD)

set(USD_LOCATION "${USD_INCLUDE_DIR}/..")
set(GLEW_LOCATION ${USD_LOCATION})

if (LAB_BOOST_VCPKG)
    unset(Boost_USE_STATIC_LIBS)
    unset(Boost_USE_MULTITHREADED)
    unset(Boost_USE_STATIC_RUNTIME)
    set(Boost_COMPILER "-vc140")
    set(BOOST_ROOT ${LAB_PACKAGE_ROOT})
    set(BOOST_INCLUDEDIR ${LAB_PACKAGE_ROOT}/include)       
    set(BOOST_LIBRARYDIR ${LAB_PACKAGE_ROOT}/lib ${LAB_PACKAGE_ROOT}/debug/lib)
else()
    set(BOOST_ROOT ${USD_ROOT})
    set(BOOST_INCLUDEDIR ${USD_ROOT}/include)
    set(BOOST_LIBRARYDIR ${USD_ROOT}/lib)
    set(Boost_USE_STATIC_LIBS OFF)
    set(Boost_USE_MULTITHREADED ON)
    set(Boost_USE_STATIC_RUNTIME OFF)
endif()
find_package(Boost 
    COMPONENTS system
    OPTIONAL_COMPONENTS python)

include_directories(${Boost_INCLUDE_DIR})

find_package(GLEW)

# USD requires Python
find_package(PythonInterp 2.7)
find_package(PythonLibs 2.7)

