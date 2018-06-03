
# author: Nick Porcino
# license: MIT

# LABRENDER_FOUND
# LABRENDER_INCLUDE_DIR
# LABRENDER_LIBRARY_RELEASE
# LABRENDER_LIBRARY_DEBUG
# LABRENDER_LIBRARIES
# LABRENDER_DYLIBS
# LABRENDER_DYLIBS_RELEASE
# LABRENDER_DYLIBS_DEBUG

if (TARGET LabRender::Core)
    return()
endif()

include(FindPackageHandleStandardArgs)

find_path(LABRENDER_INCLUDE_DIR LabRender/Renderer.h
    PATHS
    ${LABRENDER_LOCATION}
    $ENV{LABRENDER_DIR}
    $ENV{PROGRAMFILES}/LabRender
    /usr
    /usr/local
    /sw
    /opt/local

    PATH_SUFFIXES
    /include

    DOC "LabRender include directory")

set(LABRENDER_LIB_NAMES LabRender LabModelLoader LabRenderBinder)

foreach(LIB ${LABRENDER_LIB_NAMES})
    find_library(LABRENDER_${LIB}_LIB_RELEASE ${LIB}
        HINTS ${LABRENDER_INCLUDE_DIR}/..

        PATHS
        ${LABRENDER_LOCATION}
        $ENV{LABRENDER_DIR}
        /usr
        /usr/local
        /sw
        /opt/local

        PATH_SUFFIXES
        /lib
        DOC "LABRENDER library ${LIB}")

        if (LABRENDER_${LIB}_LIB_RELEASE)
            list(APPEND LABRENDER_LIBRARIES "${LABRENDER_${LIB}_LIB_RELEASE}")
            list(APPEND LABRENDER_LIBRARIES_RELEASE "${LABRENDER_${LIB}_LIB_RELEASE}")
            set(LABRENDER_${LIB}_FOUND TRUE)
            set(${LIB}_LIBRARY "${LABRENDER_${LIB}_LIB_RELEASE}")
            set(${LIB}_LIBRARY_RELEASE "${LABRENDER_${LIB}_LIB_RELEASE}")
        else()
            set(${LIB}_FOUND FALSE)
        endif()

    find_library(LABRENDER_${LIB}_LIB_DEBUG ${LIB}_d
        HINTS ${LABRENDER_INCLUDE_DIR}/..

        PATHS
        ${LABRENDER_LOCATION}
        $ENV{LABRENDER_DIR}
        /usr
        /usr/local
        /sw
        /opt/local

        PATH_SUFFIXES
        /lib
        DOC "LABRENDER library ${LIB}")

        if (LABRENDER_${LIB}_LIB_DEBUG)
            list(APPEND LABRENDER_LIBRARIES_DEBUG "${LABRENDER_${LIB}_LIB_DEBUG}")
            set(${LIB}_DEBUG_FOUND TRUE)
            set(${LIB}_LIBRARY_DEBUG "${LABRENDER_${LIB}_LIB_DEBUG}")
        else()
            set(${LIB}_FOUND FALSE)
        endif()
endforeach()

find_package_handle_standard_args(LABRENDER
    REQUIRED_VARS LABRENDER_LIBRARIES LABRENDER_LIBRARIES_DEBUG LABRENDER_INCLUDE_DIR)

iF (LABRENDER_FOUND)

    add_library(LabRender::Core SHARED IMPORTED)
    set_property(TARGET LabRender::Core APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_property(TARGET LabRender::Core APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
    set_target_properties(LabRender::Core PROPERTIES IMPORTED_IMPLIB_RELEASE ${LabRender_LIBRARY})
    set_target_properties(LabRender::Core PROPERTIES IMPORTED_IMPLIB_DEBUG   ${LabRender_LIBRARY_DEBUG})
    set_property(TARGET LabRender::Core APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${LabRender_INCLUDE_DIR})

    add_library(LabRender::Binder SHARED IMPORTED)
    set_property(TARGET LabRender::Binder APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_property(TARGET LabRender::Binder APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
    set_target_properties(LabRender::Binder PROPERTIES IMPORTED_IMPLIB_RELEASE ${LabRenderBinder_LIBRARY})
    set_target_properties(LabRender::Binder PROPERTIES IMPORTED_IMPLIB_DEBUG   ${LabRenderBinder_LIBRARY_DEBUG})
    set_property(TARGET LabRender::Binder APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${LabRender_INCLUDE_DIR})

    add_library(LabRender::ModelLoader SHARED IMPORTED)
    set_property(TARGET LabRender::ModelLoader APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
    set_property(TARGET LabRender::ModelLoader APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
    set_target_properties(LabRender::ModelLoader PROPERTIES IMPORTED_IMPLIB_RELEASE ${LabModelLoader_LIBRARY})
    set_target_properties(LabRender::ModelLoader PROPERTIES IMPORTED_IMPLIB_DEBUG   ${LabModelLoader_LIBRARY_DEBUG})
    set_property(TARGET LabRender::ModelLoader APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${LabRender_INCLUDE_DIR})

endif()
