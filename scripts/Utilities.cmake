
function(source_file fname)
    if(IS_ABSOLUTE ${fname})
        target_sources(${PROJECT_NAME} PRIVATE ${fname})
    else()
        target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/${fname})
    endif()
endfunction()

function(include_dir fpath)
    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${fpath})
endfunction()


function(_get_install_dir path out)
    if (LAB_INSTALL_SUBDIR)
        set(${out} ${LAB_INSTALL_SUBDIR}/${path} PARENT_SCOPE)
    else()
        set(${out} ${path} PARENT_SCOPE)
    endif()
endfunction() # get_install_dir


function(_get_folder suffix result)
    if(LAB_PREFIX)
        set(folder "${LAB_PREFIX}")
    elseif(LAB_INSTALL_SUBDIR)
        set(folder "${LAB_INSTALL_SUBDIR}")
    else()
        set(folder "Libraries")
    endif()
    if(suffix)
        set(folder "${folder}/${suffix}")
    endif()
    set(${result} ${folder} PARENT_SCOPE)
endfunction()



# Add a library target named NAME.
function(_lab_library_detail NAME)
    # Argument parsing.
    set(options
    )
    set(oneValueArgs
        PREFIX
        SUBDIR
        SUFFIX
        TYPE
        PRECOMPILED_HEADERS
        PRECOMPILED_HEADER_NAME
    )
    set(multiValueArgs
        PUBLIC_HEADERS
        PRIVATE_HEADERS
        CPPFILES
        LIBRARIES
        INCLUDE_DIRS
        RESOURCE_FILES
        LIB_INSTALL_PREFIX_RESULT
        PUBLIC_DEFINITIONS
        PRIVATE_DEFINITIONS
    )
    cmake_parse_arguments(args
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN}
    )

    #
    # Set up the target.
    #

    # Note OBJECT and PLUGIN types.
    set(isObject FALSE)
    set(isPlugin FALSE)
    if(args_TYPE STREQUAL "OBJECT" OR args_TYPE STREQUAL "OBJECT_PLUGIN")
        set(isObject TRUE)
    endif()
    if(args_TYPE STREQUAL "PLUGIN" OR args_TYPE STREQUAL "OBJECT_PLUGIN")
        set(isPlugin TRUE)
    endif()

    # Add the target.  We also add the headers because that's the easiest
    # way to get them to appear in IDE projects.
    if(isObject)
        # When building a monolithic library we don't build individual
        # static or shared libraries.  Instead we build OBJECT libraries
        # which simply compile the sources.
        #
        # These can't be linked like other libraries and as a result we
        # don't automatically get transitive compiler definitions,
        # include directories or link libraries.  We have to do that
        # manually.  See pxr_monolithic_epilogue().
        add_library(${NAME}
            OBJECT
            ${args_CPPFILES}
            ${args_PUBLIC_HEADERS}
            ${args_PRIVATE_HEADERS}
        )

    elseif(args_TYPE STREQUAL "STATIC")
        # Building an explicitly static library.
        add_library(${NAME}
            STATIC
            ${args_CPPFILES}
            ${args_PUBLIC_HEADERS}
            ${args_PRIVATE_HEADERS}
        )

    else()
        # Building an explicitly shared library or plugin.
        add_library(${NAME}
            SHARED
            ${args_CPPFILES}
            ${args_PUBLIC_HEADERS}
            ${args_PRIVATE_HEADERS}
        )
    endif()

    #
    # Compute names and paths.
    #

    # Where do we install to?
    _get_install_dir("include/${LAB_PREFIX}/${NAME}" headerInstallPrefix)
    _get_install_dir("lib" libInstallPrefix)
    _get_install_dir("bin" binInstallPrefix)

    if(args_SUBDIR)
        set(libInstallPrefix "${libInstallPrefix}/${args_SUBDIR}")
    endif()

    # Return libInstallPrefix to caller.
    if(args_LIB_INSTALL_PREFIX_RESULT)
        set(${args_LIB_INSTALL_PREFIX_RESULT} "${libInstallPrefix}" PARENT_SCOPE)
    endif()

    # Names and paths passed to the compile via macros.  Paths should be
    # relative to facilitate relocating the build.
    string(TOUPPER ${NAME} uppercaseName)

    if(LAB_INSTALL_LOCATION)
        file(TO_CMAKE_PATH "${LAB_INSTALL_LOCATION}" labInstallLocation)
        set(labInstallLocation "LAB_INSTALL_LOCATION=${labInstallLocation}")
    endif()

    # API macros.
    set(apiPublic "")
    set(apiPrivate ${uppercaseName}_EXPORTS=1)
    if(NOT _building_monolithic AND args_TYPE STREQUAL "STATIC")
        set(apiPublic LAB_STATIC=1)
    endif()

    # Final name.
    set(libraryFilename "${args_PREFIX}${NAME}${args_SUFFIX}")

    #
    # Set up the compile/link.
    #

    # PIC is required by shared libraries. It's on for static libraries
    # because we'll likely link them into a shared library.
    #
    # We set PUBLIC_HEADER so we install directly from the source tree.
    # We don't want to install the headers copied to the build tree
    # because they have #line directives embedded to aid in debugging.
    _get_folder("" folder)
    set_target_properties(${NAME}
        PROPERTIES
            FOLDER "${folder}"
            POSITION_INDEPENDENT_CODE ON
            PREFIX "${args_PREFIX}"
            SUFFIX "${args_SUFFIX}"
            PUBLIC_HEADER "${args_PUBLIC_HEADERS}"
            OUTPUT_NAME_DEBUG "${NAME}_d"
    )

    target_compile_definitions(${NAME}
        PUBLIC
            ${apiPublic}
            ${args_PUBLIC_DEFINITIONS}
        PRIVATE
            BUILDING_${NAME}=1
            ${labInstallLocation}
            ${apiPrivate}
            ${args_PRIVATE_DEFINITIONS}
    )

    # Copy headers to the build directory and include from there and from
    # external packages.
    install(
        FILES
            ${args_PUBLIC_HEADERS}

        DESTINATION
            ${headerInstallPrefix}
    )

    target_include_directories(${NAME}
        PRIVATE
            "${CMAKE_BINARY_DIR}/include"
            "${CMAKE_BINARY_DIR}/${LAB_INSTALL_SUBDIR}/include"
        PUBLIC
            ${args_INCLUDE_DIRS}
    )

    target_link_libraries(${NAME} ${args_LIBRARIES})

    lab_default_definitions(${NAME})

    # Rpath has libraries under the third party prefix and the install prefix.
    # The former is for helper libraries for a third party application and
    # the latter for core USD libraries.
    #@TODO - support rpaths
    #_pxr_init_rpath(rpath "${libInstallPrefix}")
    #_pxr_add_rpath(rpath "${CMAKE_INSTALL_PREFIX}/${PXR_INSTALL_SUBDIR}/lib")
    #_pxr_add_rpath(rpath "${CMAKE_INSTALL_PREFIX}/lib")
    #_pxr_install_rpath(rpath ${NAME})

    #
    # Set up the install.
    #

    install(
        FILES
            $<TARGET_PDB_FILE:LabCmd>
        DESTINATION
            bin OPTIONAL
    )

    install(
        TARGETS ${NAME}
        EXPORT pxrTargets
        LIBRARY DESTINATION ${libInstallPrefix}
        ARCHIVE DESTINATION ${libInstallPrefix}
        RUNTIME DESTINATION ${binInstallPrefix}
        PUBLIC_HEADER DESTINATION ${headerInstallPrefix}
    )

    install(
        FILES ${args_RESOURCE_FILES}
        DESTINATION "${binInstallPrefix}")

endfunction() # _lab_library




# adapted from pxr_library
function(lab_library NAME)
    set(options
        DISABLE_PRECOMPILED_HEADERS
    )
    set(oneValueArgs
        TYPE
        PRECOMPILED_HEADER_NAME
    )
    set(multiValueArgs
        PUBLIC_HEADERS
        PRIVATE_HEADERS
        CPPFILES
        LIBRARIES
        INCLUDE_DIRS
        RESOURCE_FILES
    )

    cmake_parse_arguments(args
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN}
    )

    # Collect libraries.
    get_property(help CACHE LAB_ALL_LIBS PROPERTY HELPSTRING)
    list(APPEND LAB_ALL_LIBS ${NAME})
    set(LAB_ALL_LIBS "${LAB_ALL_LIBS}" CACHE INTERNAL "${help}")
    if(args_TYPE STREQUAL "STATIC")
        # Note if this library is explicitly STATIC.
        get_property(help CACHE LAB_STATIC_LIBS PROPERTY HELPSTRING)
        list(APPEND LAB_STATIC_LIBS ${NAME})
        set(LAB_STATIC_LIBS "${LAB_STATIC_LIBS}" CACHE INTERNAL "${help}")
    else()
        # If the caller didn't specify the library type then choose the
        # type now.
        if("x${args_TYPE}" STREQUAL "x")
            if(_building_monolithic)
                set(args_TYPE "OBJECT")
            elseif(BUILD_SHARED_LIBS)
                set(args_TYPE "SHARED")
            else()
                set(args_TYPE "STATIC")
            endif()
        endif()

        set(prefix "${LAB_LIB_PREFIX}")
        if(args_TYPE STREQUAL "STATIC")
            set(suffix ${CMAKE_STATIC_LIBRARY_SUFFIX})
        else()
            set(suffix ${CMAKE_SHARED_LIBRARY_SUFFIX})
        endif()
    endif()

    set(pch "ON")
    if(args_DISABLE_PRECOMPILED_HEADERS)
        set(pch "OFF")
    endif()

    _lab_library_detail(${NAME}
        TYPE "${args_TYPE}"
        PREFIX "${prefix}"
        SUFFIX "${suffix}"
        SUBDIR "${subdir}"
        CPPFILES "${args_CPPFILES};${${NAME}_CPPFILES}"
        PUBLIC_HEADERS "${args_PUBLIC_HEADERS};${${NAME}_PUBLIC_HEADERS}"
        PRIVATE_HEADERS "${args_PRIVATE_HEADERS};${${NAME}_PRIVATE_HEADERS}"
        LIBRARIES "${args_LIBRARIES}"
        INCLUDE_DIRS "${args_INCLUDE_DIRS}"
        RESOURCE_FILES "${args_RESOURCE_FILES}"
        PRECOMPILED_HEADERS "${pch}"
        PRECOMPILED_HEADER_NAME "${args_PRECOMPILED_HEADER_NAME}"
        LIB_INSTALL_PREFIX_RESULT libInstallPrefix
    )
endfunction()

macro(lab_shared_library NAME)
    lab_library(${NAME} TYPE "SHARED" ${ARGN})
endmacro(lab_shared_library)

macro(lab_static_library NAME)
    lab_library(${NAME} TYPE "STATIC" ${ARGN})
endmacro(lab_static_library)
