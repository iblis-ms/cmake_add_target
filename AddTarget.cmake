# Author: Marcin Serwach
# License: MIT
# ULR: https://github.com/iblis-ms/cmake_add_target
#
# AddTarget simpliefies adding targets in CMake. For example:
##################### <EXAMPLE> ########################
#   set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
#   set(SRC
#       "${SRC_DIR}/main.cpp"
#       "${SRC_DIR}/ExeA.cpp"
#       "${SRC_DIR}/exeA1/ExeA1.cpp"
#       "${SRC_DIR}/exeA1/ExeA1Sub/ExeA1Sub.cpp"
#       "${SRC_DIR}/exeA2/ExeA2.cpp"
#       )
#   set(INC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/inc")
#   
#   AddTarget(
#      TARGET_NAME "exeA"                      # - target name
#      TARGET_TYPE "EXE"                       # - type of target: "EXE" so target is executable
#      SRC "${SRC}"                            # - source files
#      PRIVATE_LIBS "LibraryA"                 # - libraries to link with this target; private linking, so not visible to others
#      PUBLIC_INC_DIRS "${INC_DIR}"            # - path to directories with header files
#      PUBLIC_DEFINES "DEFINE_A" "DEFINE_AA=1" # - defines
#   )
##################### </EXAMPLE> #######################

# Set to 1 to print debug values
set(ADD_TARGET_DEBUG 1)

# \brief Add files to groups for example to have groups in Visual Studio that match to folder structure.
# \param[in] ROOT_PATH - Root path - groups will be created from this root path - the path given here is treaten as entry point.
# \param[in] PATHS_TO_DIRS - Paths to folders with header files
# \param[out] OUTPUT_FILES - Name of variable with result - a list of header files
function(AddFileToGroupInternal ROOT_PATH PATHS_TO_DIRS OUTPUT_FILES)

    foreach(PATH_TO_DIR IN LISTS PATHS_TO_DIRS)
        file(GLOB_RECURSE PATHS_TO_FILES_HPP "${PATH_TO_DIR}/*.hpp")
        source_group(TREE "${ROOT_PATH}" FILES ${PATHS_TO_FILES_HPP})
        file(GLOB_RECURSE PATHS_TO_FILES_H "${PATH_TO_DIR}/*.h")
        source_group(TREE "${ROOT_PATH}" FILES ${PATHS_TO_FILES_H})
        list(APPEND BUF ${PATHS_TO_FILES_HPP} ${PATHS_TO_FILES_H})
    endforeach()
    
    set(${OUTPUT_FILES} ${BUF} PARENT_SCOPE)

endfunction()

# \brief Creates target.
# \param[in] TARGET_NAME Target name
# \param[in] TARGET_TYPE Target type: EXE for executable, STATIC for static library, SHARED for shared library, INTERFACE for headers only library
# \param[in] TARGET_DIR Path to directory where target is defined
# \param[in] SRC Source files
# \param[in] PUBLIC_INC_DIRS Arguments to target_include_directories with PUBLIC/INTERFACE visibility,
# \param[in] PRIVATE_INC_DIRS Arguments to target_include_directories with PRIVATE visibility,
# \param[in] PUBLIC_LIBS Arguments to target_link_libraries with PUBLIC/INTERFACE visibility,
# \param[in] PRIVATE_LIBS Arguments to target_link_libraries with PRIVATE visibility,
# \param[in] PUBLIC_DEFINES Arguments to target_compile_definitions with PUBLIC/INTERFACE visibility,
# \param[in] PRIVATE_DEFINES Arguments to target_compile_definitions with PRIVATE visibility,
function(AddTargetInternal)

    set(OPTIONAL_ARGUMENTS_PATTERN 
        TEST_TARGET
        )
    
    set(ONE_ARGUMENT_PATTERN 
        TARGET_NAME 
        TARGET_TYPE 
        TARGET_DIR
        ) 
        
    set(MULTI_ARGUMENT_PATTERN 
        SRC 
        
        PUBLIC_INC_DIRS 
        PRIVATE_INC_DIRS 
        
        PUBLIC_LIBS 
        PRIVATE_LIBS 
        
        PUBLIC_DEFINES
        PRIVATE_DEFINES
        )
  
    CMake_parse_arguments(ADD_TARGET "${OPTIONAL_ARGUMENTS_PATTERN}" "${ONE_ARGUMENT_PATTERN}" "${MULTI_ARGUMENT_PATTERN}" ${ARGN} )

    if (ADD_TARGET_DEBUG)
        message(STATUS "--------------------------------------------------------------")
        message(STATUS "TARGET_NAME=${ADD_TARGET_TARGET_NAME}")
        message(STATUS "TARGET_TYPE=${ADD_TARGET_TARGET_TYPE}")
        message(STATUS "TARGET_DIR=${ADD_TARGET_TARGET_DIR}")
        
        message(STATUS "SRC=${ADD_TARGET_SRC}")
        
        message(STATUS "PUBLIC_INC_DIRS=${ADD_TARGET_PUBLIC_INC_DIRS}")
        message(STATUS "PRIVATE_INC_DIRS=${ADD_TARGET_PRIVATE_INC_DIRS}")
        
        message(STATUS "PUBLIC_LIBS=${ADD_TARGET_PUBLIC_LIBS}")
        message(STATUS "PRIVATE_LIBS=${ADD_TARGET_PRIVATE_LIBS}")
        
        message(STATUS "PUBLIC_DEFINES=${ADD_TARGET_PUBLIC_DEFINES}")
        message(STATUS "PRIVATE_DEFINES=${ADD_TARGET_PRIVATE_DEFINES}")
        
        message(STATUS "TEST_TARGET=${ADD_TARGET_TEST_TARGET}")
        message(STATUS "--------------------------------------------------------------")
    endif ()
    
    AddFileToGroupInternal("${ADD_TARGET_TARGET_DIR}" "${ADD_TARGET_PUBLIC_INC_DIRS}" PUBLIC_INCS_TO_SRC)
    AddFileToGroupInternal("${ADD_TARGET_TARGET_DIR}" "${ADD_TARGET_PRIVATE_INC_DIRS}" PRIVATE_INCS_TO_SRC)
    message(STATUS "PUBLIC_INCS_TO_SRC=${PUBLIC_INCS_TO_SRC}")
    message(STATUS "PRIVATE_INCS_TO_SRC=${PRIVATE_INCS_TO_SRC}")
    source_group(TREE "${ADD_TARGET_TARGET_DIR}" FILES ${ADD_TARGET_SRC})

    set(SRC "${ADD_TARGET_SRC}" "${PUBLIC_INCS_TO_SRC}" "${PRIVATE_INCS_TO_SRC}" "${INTERFACE_INCS_TO_SRC}")
    
    if ("${ADD_TARGET_TARGET_TYPE}" STREQUAL "EXE")
        add_executable("${ADD_TARGET_TARGET_NAME}" "${SRC}")
    elseif ("${ADD_TARGET_TARGET_TYPE}" STREQUAL "STATIC")
        add_library("${ADD_TARGET_TARGET_NAME}" STATIC "${SRC}")
    elseif ("${ADD_TARGET_TARGET_TYPE}" STREQUAL "SHARED")
        add_library("${ADD_TARGET_TARGET_NAME}" SHARED "${SRC}")
    elseif ("${ADD_TARGET_TARGET_TYPE}" STREQUAL "INTERFACE")
        add_library("${ADD_TARGET_TARGET_NAME}" INTERFACE)
    else ()
        message(FATAL_ERROR " Incorrect TARGET_TYPE=${ADD_TARGET_TARGET_TYPE} for TARGET_NAME=${ADD_TARGET_TARGET_NAME} from location ${ADD_TARGET_TARGET_DIR}")
    endif ()
    
    if ("${ADD_TARGET_TARGET_TYPE}" STREQUAL "INTERFACE")
        target_include_directories("${ADD_TARGET_TARGET_NAME}" INTERFACE "${ADD_TARGET_PUBLIC_INC_DIRS}")
        
        target_link_libraries("${ADD_TARGET_TARGET_NAME}" INTERFACE "${ADD_TARGET_PUBLIC_LIBS}")
        
        target_compile_definitions("${ADD_TARGET_TARGET_NAME}" INTERFACE "${ADD_TARGET_PUBLIC_DEFINES}")
    else()
        target_include_directories("${ADD_TARGET_TARGET_NAME}" PUBLIC "${ADD_TARGET_PUBLIC_INC_DIRS}")
        target_include_directories("${ADD_TARGET_TARGET_NAME}" PRIVATE "${ADD_TARGET_PRIVATE_INC_DIRS}")
        
        target_link_libraries("${ADD_TARGET_TARGET_NAME}" PUBLIC "${ADD_TARGET_PUBLIC_LIBS}")
        target_link_libraries("${ADD_TARGET_TARGET_NAME}" PRIVATE "${ADD_TARGET_PRIVATE_LIBS}")
        
        target_compile_definitions("${ADD_TARGET_TARGET_NAME}" PUBLIC "${ADD_TARGET_PUBLIC_DEFINES}")
        target_compile_definitions("${ADD_TARGET_TARGET_NAME}" PRIVATE "${ADD_TARGET_PRIVATE_DEFINES}")
    endif()
    
    if (TEST_TARGET)
        add_test(NAME "${ADD_TARGET_TARGET_TYPE}" COMMAND "${ADD_TARGET_TARGET_TYPE}")
    endif()
	
endfunction()

# \brief Creates target.
# \param[in] TARGET_NAME Target name
# \param[in] TARGET_TYPE Target type: EXE for executable, STATIC for static library, SHARED for shared library, INTERFACE for headers only library
# \param[in] TARGET_DIR Path to directory where target is defined
# \param[in] SRC Source files
# \param[in] PUBLIC_INC_DIRS Arguments to target_include_directories with PUBLIC/INTERFACE visibility,
# \param[in] PRIVATE_INC_DIRS Arguments to target_include_directories with PRIVATE visibility,
# \param[in] PUBLIC_LIBS Arguments to target_link_libraries with PUBLIC/INTERFACE visibility,
# \param[in] PRIVATE_LIBS Arguments to target_link_libraries with PRIVATE visibility,
# \param[in] PUBLIC_DEFINES Arguments to target_compile_definitions with PUBLIC/INTERFACE visibility,
# \param[in] PRIVATE_DEFINES Arguments to target_compile_definitions with PRIVATE visibility,
macro(AddTarget)

    AddTargetInternal(TARGET_DIR "${CMAKE_CURRENT_SOURCE_DIR}" ${ARGV})
	
endmacro()

# \brief Creates test target.
# \param[in] TARGET_NAME Target name
# \param[in] TARGET_TYPE Target type: EXE for executable, STATIC for static library, SHARED for shared library, INTERFACE for headers only library
# \param[in] TARGET_DIR Path to directory where target is defined
# \param[in] SRC Source files
# \param[in] PUBLIC_INC_DIRS Arguments to target_include_directories with PUBLIC/INTERFACE visibility,
# \param[in] PRIVATE_INC_DIRS Arguments to target_include_directories with PRIVATE visibility,
# \param[in] PUBLIC_LIBS Arguments to target_link_libraries with PUBLIC/INTERFACE visibility,
# \param[in] PRIVATE_LIBS Arguments to target_link_libraries with PRIVATE visibility,
# \param[in] PUBLIC_DEFINES Arguments to target_compile_definitions with PUBLIC/INTERFACE visibility,
# \param[in] PRIVATE_DEFINES Arguments to target_compile_definitions with PRIVATE visibility,
macro(AddTestTarget)

    AddTargetInternal(TARGET_DIR "${CMAKE_CURRENT_SOURCE_DIR}" ${ARGV} TEST_TARGET)
	
endmacro()