
# All the things that are not required to use the same values as USD
set(FMT_LOCATION ${LOCAL_ROOT})
set(GLFW_LOCATION ${LOCAL_ROOT})
set(GLM_ROOT_DIR ${LOCAL_ROOT})
set(LABCMD_LOCATION ${LOCAL_ROOT})
set(LABRENDER_LOCATION ${LOCAL_ROOT})
set(LABPHYSICS_LOCATION ${LOCAL_ROOT})
set(TBB_ROOT_DIR ${LOCAL_ROOT})
set(USD_ROOT ${LOCAL_ROOT})

message(INFO, "XXXXXX" ${TBB_ROOT_DIR})

link_directories(${LOCAL_ROOT}/lib)

# --math
if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    find_library(M_LIB m)
endif()

# --z
if (WIN32)
    find_file(Z_BINARY_RELEASE
        NAMES
            zlib.dll
        HINTS
            "${LOCAL_ROOT}/bin"
        DOC "The z library")
endif()

find_package(OpenGL)
find_package(GLFW)
find_package(GLM)
find_package(LabCmd)
find_package(LabRender)
find_package(LabPhysics)
find_package(Fmt)
find_package(TBB)
find_package(USD)

set(USD_LOCATION "${USD_INCLUDE_DIR}/..")
set(GLEW_LOCATION ${USD_LOCATION})

set(LAB_BOOST_COMPONENTS system)

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
    list(APPEND LAB_BOOST_COMPONENTS python)
endif()
find_package(Boost COMPONENTS system ${LAB_BOOST_COMPONENTS})
include_directories(${Boost_INCLUDE_DIR})

find_package(GLEW)

# USD requires Python
find_package(PythonInterp 2.7)
find_package(PythonLibs 2.7)

