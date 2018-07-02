
# author: Nick Porcino
# license: MIT

include_guard()

include(FindPackageHandleStandardArgs)


find_path(
    LABTEXT_INCLUDE_DIR 
    NAMES LabText/TextScanner.h
    
    PATHS
    ${LABTEXT_LOCATION}
    $ENV{LABTEXT_DIR}
    $ENV{PROGRAMFILES}/LabText
    /usr
    /usr/local
    /sw
    /opt/local

    PATH_SUFFIXES
    /include

    DOC "LABTEXT include directory")

set(LABTEXT_LIB_NAMES LabText)

foreach(LIB ${LABTEXT_LIB_NAMES})
    find_library(
        LABTEXT_${LIB}_LIB_RELEASE 
        NAMES ${LIB}
        HINTS ${LABTEXT_INCLUDE_DIR}/..

        PATHS
        ${LABTEXT_LOCATION}
        $ENV{LABTEXT_DIR}
        /usr
        /usr/local
        /sw
        /opt/local

        PATH_SUFFIXES
        /lib
        DOC "LABTEXT library ${LIB}" )

    if (LABTEXT_${LIB}_LIB_RELEASE)
        list(APPEND LABTEXT_LIBRARIES "${LABTEXT_${LIB}_LIB_RELEASE}")
        set(${LIB}_FOUND TRUE)
        set(${LIB}_LIBRARY "${LABTEXT_${LIB}_LIB_RELEASE}")
        set(${LIB}_LIBRARY_RELEASE "${LABTEXT_${LIB}_LIB_RELEASE}")
    else()
        set(LABTEXT_${LIB}_FOUND FALSE)
    endif()

    find_library(LABTEXT_${LIB}_LIB_DEBUG ${LIB}_d
        HINTS ${LABTEXT_INCLUDE_DIR}/..

        PATHS
        ${LABTEXT_LOCATION}
        $ENV{LABTEXT_DIR}
        /usr
        /usr/local
        /sw
        /opt/local

        PATH_SUFFIXES
        /lib
        DOC "LABTEXT library ${LIB}" )

    if (LABTEXT_${LIB}_LIB_DEBUG)
        list(APPEND LABTEXT_LIBRARIES_DEBUG "${LABTEXT_${LIB}_LIB_DEBUG}")
        set(${LIB}_DEBUG_FOUND TRUE)
        set(${LIB}_LIBRARY_DEBUG "${LABTEXT_${LIB}_LIB_DEBUG}")
    else()
        set(${LIB}_DEBUG_FOUND FALSE)
    endif()

endforeach()

find_package_handle_standard_args(LABTEXT
    REQUIRED_VARS LABTEXT_LIBRARIES LABTEXT_LIBRARIES_DEBUG LABTEXT_INCLUDE_DIR)

iF (LABTEXT_FOUND)
    add_library(LabText::Core SHARED IMPORTED)
    set_property(TARGET LabText::Core APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_property(TARGET LabText::Core APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
    set_target_properties(LabText::Core PROPERTIES IMPORTED_IMPLIB_RELEASE ${LABTEXT_LIBRARY})
    set_target_properties(LabText::Core PROPERTIES IMPORTED_IMPLIB_DEBUG   ${LABTEXT_LIBRARY_DEBUG})
    set_property(TARGET LabText::Core APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${LABTEXT_INCLUDE_DIR})
endif()
