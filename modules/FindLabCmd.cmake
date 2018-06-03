
# author: Nick Porcino
# license: MIT

if (TARGET LabCmd::Core)
    return()
endif()

include(FindPackageHandleStandardArgs)


find_path(
    LABCMD_INCLUDE_DIR 
    NAMES LabCmd/LabCmd.h
    
    PATHS
    ${LABCMD_LOCATION}
    $ENV{LABCMD_DIR}
    $ENV{PROGRAMFILES}/LabCmd
    /usr
    /usr/local
    /sw
    /opt/local

    PATH_SUFFIXES
    /include

    DOC "LabCmd include directory")

set(LABCMD_LIB_NAMES LabCmd)

foreach(LIB ${LABCMD_LIB_NAMES})
    find_library(
        LABCMD_${LIB}_LIB_RELEASE 
        NAMES ${LIB}
        HINTS ${LABCMD_INCLUDE_DIR}/..

        PATHS
        ${LABCMD_LOCATION}
        $ENV{LABCMD_DIR}
        /usr
        /usr/local
        /sw
        /opt/local

        PATH_SUFFIXES
        /lib
        DOC "LABCMD library ${LIB}" )

    if (LABCMD_${LIB}_LIB_RELEASE)
        list(APPEND LABCMD_LIBRARIES "${LABCMD_${LIB}_LIB_RELEASE}")
        set(${LIB}_FOUND TRUE)
        set(${LIB}_LIBRARY "${LABCMD_${LIB}_LIB_RELEASE}")
        set(${LIB}_LIBRARY_RELEASE "${LABCMD_${LIB}_LIB_RELEASE}")
    else()
        set(LABCMD_${LIB}_FOUND FALSE)
    endif()

    find_library(LABCMD_${LIB}_LIB_DEBUG ${LIB}_d
        HINTS ${LABCMD_INCLUDE_DIR}/..

        PATHS
        ${LABCMD_LOCATION}
        $ENV{LABCMD_DIR}
        /usr
        /usr/local
        /sw
        /opt/local

        PATH_SUFFIXES
        /lib
        DOC "LABCMD library ${LIB}" )

    if (LABCMD_${LIB}_LIB_DEBUG)
        list(APPEND LABCMD_LIBRARIES_DEBUG "${LABCMD_${LIB}_LIB_DEBUG}")
        set(${LIB}_DEBUG_FOUND TRUE)
        set(${LIB}_LIBRARY_DEBUG "${LABCMD_${LIB}_LIB_DEBUG}")
    else()
        set(${LIB}_DEBUG_FOUND FALSE)
    endif()

endforeach()

find_package_handle_standard_args(LABCMD
    REQUIRED_VARS LABCMD_LIBRARIES LABCMD_LIBRARIES_DEBUG LABCMD_INCLUDE_DIR)

iF (LABCMD_FOUND)

    add_library(LabCmd::Core SHARED IMPORTED)
    set_property(TARGET LabCmd::Core APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_property(TARGET LabCmd::Core APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
    set_target_properties(LabCmd::Core PROPERTIES IMPORTED_IMPLIB_RELEASE ${LabCmd_LIBRARY})
    set_target_properties(LabCmd::Core PROPERTIES IMPORTED_IMPLIB_DEBUG   ${LabCmd_LIBRARY_DEBUG})
    set_property(TARGET LabCmd::Core APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${LABCMD_INCLUDE_DIR})

endif()
