
# All the things that are not required to use the same values as USD
set(FMT_LOCATION ${LOCAL_ROOT})
set(GLFW_LOCATION ${LOCAL_ROOT})
set(GLM_ROOT_DIR ${LOCAL_ROOT})
set(LABCMD_LOCATION ${LOCAL_ROOT})
set(LABRENDER_LOCATION ${LOCAL_ROOT})
set(LABPHYSICS_LOCATION ${LOCAL_ROOT})
set(USD_ROOT ${LOCAL_ROOT})

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


find_package(OpenGL REQUIRED)
find_package(GLFW REQUIRED)
find_package(GLM REQUIRED)
find_package(LabCmd REQUIRED)
find_package(LabRender REQUIRED)
find_package(LabPhysics REQUIRED)
find_package(Fmt REQUIRED)
find_package(USD REQUIRED)

set(USD_LOCATION "${USD_INCLUDE_DIR}/..")
set(TBB_ROOT_DIR ${USD_LOCATION})
set(GLEW_LOCATION ${USD_LOCATION})

# USD requires Boost
set(BOOST_ROOT ${USD_ROOT})
set(BOOST_LIBRARYDIR ${USD_ROOT}/lib)
set(Boost_USE_STATIC_LIBS OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package(Boost COMPONENTS python)
include_directories(${Boost_INCLUDE_DIR})

find_package(GLEW REQUIRED)
find_package(TBB REQUIRED)

# USD requires Python
find_package(PythonInterp 2.7 REQUIRED)
find_package(PythonLibs 2.7 REQUIRED)

