
# author: Nick Porcino
# license: MIT

# LABPHYSICS_FOUND
# LABPHYSICS_INCLUDE_DIR
# LABPHYSICS_LIBRARY_RELEASE
# LABPHYSICS_LIBRARY_DEBUG
# LABPHYSICS_LIBRARIES
# LABPHYSICS_DYLIBS
# LABPHYSICS_DYLIBS_RELEASE
# LABPHYSICS_DYLIBS_DEBUG

include(FindPackageHandleStandardArgs)

find_path(LABPHYSICS_INCLUDE_DIR LabPhysics/PhysicsEngine.h
    HINTS
        ${LABPHYSICS_LOCATION}
        $ENV{LABPHYSICS_DIR}
        $ENV{PROGRAMFILES}/LabPhysics
        /usr
        /usr/local
        /sw
        /opt/local

    PATH_SUFFIXES
        /include

    DOC "LabPhysics include directory")

set(LABPHYSICS_LIB_NAMES LabPhysics)

foreach(LIB ${LABPHYSICS_LIB_NAMES})
    find_library(LABPHYSICS_${LIB}_LIB_RELEASE ${LIB}
        HINTS ${LABPHYSICS_INCLUDE_DIR}/..

        PATHS
        ${LABPHYSICS_LOCATION}
        $ENV{LABPHYSICS_DIR}
        /usr
        /usr/local
        /sw
        /opt/local

        PATH_SUFFIXES
        /lib
        DOC "LABPHYSICS library ${LIB}")

        if (LABPHYSICS_${LIB}_LIB_RELEASE)
            list(APPEND LABPHYSICS_LIBRARIES "${LABPHYSICS_${LIB}_LIB_RELEASE}")
            set(LABPHYSICS_${LIB}_FOUND TRUE)
            set(${LIB}_LIBRARY "${LABPHYSICS_${LIB}_LIB_RELEASE}")
            set(${LIB}_LIBRARY_RELEASE "${LABPHYSICS_${LIB}_LIB_RELEASE}")
        else()
            set(${LIB}_FOUND FALSE)
        endif()

    find_library(LABPHYSICS_${LIB}_LIB_DEBUG ${LIB}_d
        HINTS ${LABPHYSICS_INCLUDE_DIR}/..

        PATHS
        ${LABPHYSICS_LOCATION}
        $ENV{LABPHYSICS_DIR}
        /usr
        /usr/local
        /sw
        /opt/local

        PATH_SUFFIXES
        /lib
        DOC "LABPHYSICS library ${LIB}")

        if (LABPHYSICS_${LIB}_LIB_DEBUG)
            set(${LIB}_DEBUG_FOUND TRUE)
            set(${LIB}_LIBRARY_DEBUG "${LABPHYSICS_${LIB}_LIB_DEBUG}")
        else()
            set(${LIB}_FOUND FALSE)
        endif()
endforeach()

find_package_handle_standard_args(LABPHYSICS
    REQUIRED_VARS LABPHYSICS_LIBRARIES LABPHYSICS_INCLUDE_DIR)
