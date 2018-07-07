
# author: Nick Porcino
# license: MIT

include_guard()

include(FindPackageHandleStandardArgs)

find_path(FMT_INCLUDE_DIR fmt/format.h
    PATHS
    ${FMT_LOCATION}
    /usr
    /usr/local
    /sw
    /opt/local

    PATH_SUFFIXES
    /include

    DOC "Fmt include directory")

set(FMT_LIB_NAMES fmt)

foreach(LIB ${FMT_LIB_NAMES})
    find_library(FMT_${LIB}_LIB_RELEASE ${LIB}
        HINTS ${LABCMD_INCLUDE_DIR}/..

        PATHS
        ${FMT_LOCATION}
        /usr
        /usr/local
        /sw
        /opt/local

        PATH_SUFFIXES
        /lib
        DOC "Fmt library ${LIB}")

        if (FMT_${LIB}_LIB_RELEASE)
            list(APPEND FMT_LIBRARIES "${FMT_${LIB}_LIB_RELEASE}")
            set(${LIB}_FOUND TRUE)
            set(${LIB}_LIBRARY "${FMT_${LIB}_LIB_RELEASE}")
            set(${LIB}_LIBRARY_RELEASE "${FMT_${LIB}_LIB_RELEASE}")
        else()
            set(FMT_${LIB}_FOUND FALSE)
        endif()

    find_library(FMT_${LIB}_LIB_DEBUG ${LIB}d
        HINTS ${FMT_INCLUDE_DIR}/..

        PATHS
        ${FMT_LOCATION}
        /usr
        /usr/local
        /sw
        /opt/local

        PATH_SUFFIXES
        /lib
        DOC "Fmt library ${LIB}")

        if (FMT_${LIB}_LIB_DEBUG)
            set(${LIB}_DEBUG_FOUND TRUE)
            set(${LIB}_LIBRARY_DEBUG "${FMT_${LIB}_LIB_DEBUG}")
        else()
            set(${LIB}_DEBUG_FOUND FALSE)
        endif()
endforeach()

find_package_handle_standard_args(FMT
    REQUIRED_VARS FMT_LIBRARIES FMT_INCLUDE_DIR)

iF (FMT_FOUND)
    add_library(Fmt::Format SHARED IMPORTED)
    set_property(TARGET Fmt::Format APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_property(TARGET Fmt::Format APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
    set_target_properties(Fmt::Format PROPERTIES IMPORTED_IMPLIB_RELEASE ${fmt_LIBRARY})
    set_target_properties(Fmt::Format PROPERTIES IMPORTED_IMPLIB_DEBUG   ${fmt_LIBRARY_DEBUG})
    set_property(TARGET Fmt::Format APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${FMT_INCLUDE_DIR})
endif()
