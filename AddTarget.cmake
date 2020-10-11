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
if (NOT DEFINED ADD_TARGET_DEBUG)
    set(ADD_TARGET_DEBUG 1)
endif ()

# Set to 1 to run valgrind with test
if (NOT DEFINED ADD_TARGET_VALGRIND)
    set(ADD_TARGET_VALGRIND 0)
endif ()

# Set to 1 to run dr memory with test
if (NOT DEFINED ADD_TARGET_DR_MEMORY)
    set(ADD_TARGET_DR_MEMORY 0)
endif ()

# Set to 1 to run clang address sanitizer with test
if (NOT DEFINED ADD_TARGET_CLANG_ADDRESS_SANITIZER)
    set(ADD_TARGET_CLANG_ADDRESS_SANITIZER 0)
endif ()

if (NOT DEFINED ADD_TARGET_CLANG_MEMORY_SANITIZER)
    set(ADD_TARGET_CLANG_MEMORY_SANITIZER 0)
endif ()

if (NOT DEFINED ADD_TARGET_CLANG_THREAD_SANITIZER)
    set(ADD_TARGET_CLANG_THREAD_SANITIZER 0)
endif ()

if (NOT DEFINED ADD_TARGET_CLANG_UNDEFINED_BEHAVIOR_SANITIZER)
    set(ADD_TARGET_CLANG_UNDEFINED_BEHAVIOR_SANITIZER 0)
endif ()

# custom test run command shall be done by defining addTargetTestRunCommand. See 

include("${CMAKE_CURRENT_LIST_DIR}/conan.cmake")

function(AddTargetTestRunCommand_Valgrind TEST_TARGET_NAME)
    set(ADD_TARGET_TEST_COMMAND "valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes $<TARGET_FILE:${TEST_TARGET_NAME}>" PARENT_SCOPE)
    set(ADD_TARGET_TEST_SHELL_COMMAND YES PARENT_SCOPE)
endfunction()

function(AddTargetTestRunCommand_DrMemory TEST_TARGET_NAME)
    set(ADD_TARGET_TEST_COMMAND "drmemory" "--" "$<TARGET_FILE:${TEST_TARGET_NAME}>" PARENT_SCOPE)
endfunction()


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

        RESOURCES_TO_COPY_TO_EXE_DIR
        RESOURCES_TO_COPY
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
    
    if (ADD_TARGET_TEST_TARGET)
        if (ADD_TARGET_TEST_TARGET_INCLUDE)
            if (NOT "${ADD_TARGET_TARGET_NAME}" MATCHES "${ADD_TARGET_TEST_TARGET_INCLUDE}")
                message(STATUS "Target ${ADD_TARGET_TARGET_NAME} doesn't match to regex: ${ADD_TARGET_TEST_TARGET_INCLUDE}, so the test target wouldn't be built.")
                return()
            endif ()
        endif ()
        if (ADD_TARGET_TEST_TARGET_EXCLUDE)
            if ("${ADD_TARGET_TARGET_NAME}" MATCHES "${ADD_TARGET_TEST_TARGET_EXCLUDE}")
                message(STATUS "Target ${ADD_TARGET_TARGET_NAME} matches to regex: ${ADD_TARGET_TEST_TARGET_EXCLUDE}, so the test target wouldn't be built.")
                return()
            endif ()
        endif ()
    endif ()
    AddFileToGroupInternal("${ADD_TARGET_TARGET_DIR}" "${ADD_TARGET_PUBLIC_INC_DIRS}" PUBLIC_INCS_TO_SRC)
    AddFileToGroupInternal("${ADD_TARGET_TARGET_DIR}" "${ADD_TARGET_PRIVATE_INC_DIRS}" PRIVATE_INCS_TO_SRC)
   
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
    
    if (ADD_TARGET_TEST_TARGET)
        set(ADD_TARGET_TEST_COMMAND "${ADD_TARGET_TARGET_NAME}")
        if (COMMAND addTargetTestRunCommand)
            AddTargetTestRunCommand("${ADD_TARGET_TARGET_NAME}")
        else()
            if (ADD_TARGET_VALGRIND)
                AddTargetTestRunCommand_Valgrind("${ADD_TARGET_TARGET_NAME}")
            endif ()

            if (ADD_TARGET_DR_MEMORY)
                AddTargetTestRunCommand_DrMemory("${ADD_TARGET_TARGET_NAME}")
            endif ()
        endif ()
        if (ADD_TARGET_TEST_SHELL_COMMAND)
            add_test(NAME "${ADD_TARGET_TARGET_NAME}" COMMAND sh -c "${ADD_TARGET_TEST_COMMAND}")
        else()
            add_test(NAME "${ADD_TARGET_TARGET_NAME}" COMMAND  "${ADD_TARGET_TEST_COMMAND}")
        endif()
    endif()
    
    set(CONAN_FILE_PATH "${ADD_TARGET_TARGET_DIR}/conanfile.txt")
    if (EXISTS "${CONAN_FILE_PATH}")
        file(RELATIVE_PATH CONAN_FILE_RELATIVE_PATH "${CMAKE_CURRENT_SOURCE_DIR}" "${CONAN_FILE_PATH}") # conan_cmake_run requires relative path

        # Note that build type, architecture is detected by CMake, but you can overwrite it
        # see https://github.com/conan-io/cmake-conan for details
        conan_cmake_run(CONANFILE "${CONAN_FILE_RELATIVE_PATH}"
                        BASIC_SETUP         # calls conan_basic_setup: https://docs.conan.io/en/latest/reference/generators/cmake.html
                        CMAKE_TARGETS       # to use modern CMake approach: target_* function
                        BUILD missing)      # build library if missing 
        message(STATUS "Libraries taken via Conan.io: ${CONAN_TARGETS}")
        target_link_libraries("${ADD_TARGET_TARGET_NAME}" PUBLIC  ${CONAN_TARGETS})
    endif()
    
    if (ADD_TARGET_CLANG_ADDRESS_SANITIZER)
        target_link_options("${ADD_TARGET_TARGET_NAME}" PUBLIC "-fsanitize=address" "-fno-omit-frame-pointer")
        target_compile_options("${ADD_TARGET_TARGET_NAME}" PUBLIC "-fsanitize=address" "-fno-omit-frame-pointer")
    endif()
    if (ADD_TARGET_CLANG_MEMORY_SANITIZER)
        target_link_options("${ADD_TARGET_TARGET_NAME}" PUBLIC "-fsanitize=memory" "-fno-omit-frame-pointer" "-fno-optimize-sibling-calls")
        target_compile_options("${ADD_TARGET_TARGET_NAME}" PUBLIC "-fsanitize=memory" "-fno-omit-frame-pointer" "-fno-optimize-sibling-calls")
    endif()
    if (ADD_TARGET_CLANG_THREAD_SANITIZER)
        target_link_options("${ADD_TARGET_TARGET_NAME}" PUBLIC "-fsanitize=thread" "-fno-omit-frame-pointer")
        target_compile_options("${ADD_TARGET_TARGET_NAME}" PUBLIC "-fsanitize=thread" "-fno-omit-frame-pointer")
    endif()
    if (ADD_TARGET_CLANG_UNDEFINED_BEHAVIOR_SANITIZER)
        target_link_options("${ADD_TARGET_TARGET_NAME}" PUBLIC "-fsanitize=undefined")
        target_compile_options("${ADD_TARGET_TARGET_NAME}" PUBLIC "-fsanitize=undefined")
    endif()

    list(APPEND LIBS ${ADD_TARGET_PUBLIC_LIBS} ${ADD_TARGET_PRIVATE_LIBS})
    foreach(LIB IN LISTS LIBS)
        get_target_property(LIB_RESOURCES_TO_COPY_TO_EXE_DIR ${LIB} RESOURCES_TO_COPY_TO_EXE_DIR)
        if (LIB_RESOURCES_TO_COPY_TO_EXE_DIR)
            list(APPEND ADD_TARGET_RESOURCES_TO_COPY_TO_EXE_DIR ${LIB_RESOURCES_TO_COPY_TO_EXE_DIR})
        endif()
        get_target_property(LIB_RESOURCES_TO_COPY ${LIB} RESOURCES_TO_COPY)
        if (LIB_RESOURCES_TO_COPY)
            list(APPEND ADD_TARGET_RESOURCES_TO_COPY ${LIB_RESOURCES_TO_COPY})
        endif()
    endforeach()

    set_target_properties(${ADD_TARGET_TARGET_NAME} PROPERTIES 
        RESOURCES_TO_COPY_TO_EXE_DIR "${ADD_TARGET_RESOURCES_TO_COPY_TO_EXE_DIR}"
        RESOURCES_TO_COPY "${ADD_TARGET_RESOURCES_TO_COPY}"
        )

    if("${ADD_TARGET_TARGET_TYPE}" STREQUAL "EXE")
        get_target_property(LIB_RESOURCES_TO_COPY_TO_EXE_DIR ${ADD_TARGET_TARGET_NAME} RESOURCES_TO_COPY_TO_EXE_DIR)
        if (LIB_RESOURCES_TO_COPY_TO_EXE_DIR)
            foreach(RES IN LISTS LIB_RESOURCES_TO_COPY_TO_EXE_DIR)

                if (NOT EXISTS "${RES}")
                    message(FATAL "Resource ${RES} not exists.")
                else()
                    if (IS_DIRECTORY "${RES}")
                        get_filename_component(DIR_NAME "${RES}" NAME_WE)
                        add_custom_command(TARGET ${ADD_TARGET_TARGET_NAME} POST_BUILD
                            COMMAND ${CMAKE_COMMAND} -E copy_directory 
                                "${RES}" 
                                "$<TARGET_FILE_DIR:${ADD_TARGET_TARGET_NAME}>/${DIR_NAME}")  # copy_directory copies content without folder, so folder needs to be added to destination path
                    else ()
                        add_custom_command(TARGET ${ADD_TARGET_TARGET_NAME} POST_BUILD
                            COMMAND ${CMAKE_COMMAND} -E copy
                                "${RES}" 
                                "$<TARGET_FILE_DIR:${ADD_TARGET_TARGET_NAME}>")  

                    endif ()
                endif ()
            endforeach()
        endif()

        get_target_property(LIB_RESOURCES_TO_COPY_WITH_DEST ${ADD_TARGET_TARGET_NAME} RESOURCES_TO_COPY)
        if (LIB_RESOURCES_TO_COPY_WITH_DEST)
            list(LENGTH LIB_RESOURCES_TO_COPY_WITH_DEST RES_LIST_LENGTH)

            math(EXPR CHECK_LENGTH "${RES_LIST_LENGTH}%3")
            if (NOT "${CHECK_LENGTH}" STREQUAL "0")
                message(FATAL "Incorrect format of RESOURCES_TO_COPY values. Expected \"src TO dest\".")
            endif ()
            foreach (KEYWORD_INDEX RANGE 1 ${RES_LIST_LENGTH} 3) # RANGE start stop step

                math(EXPR INDEX "${KEYWORD_INDEX}-1")
                list(GET LIB_RESOURCES_TO_COPY_WITH_DEST ${INDEX} SRC)

                list(GET LIB_RESOURCES_TO_COPY_WITH_DEST ${KEYWORD_INDEX} KEYWORD)

                math(EXPR DEST_INDEX "${KEYWORD_INDEX}+1")
                list(GET LIB_RESOURCES_TO_COPY_WITH_DEST ${DEST_INDEX} DEST)

                if (NOT "${KEYWORD}" STREQUAL "TO")
                    message(FATAL "Incorrect key for RESOURCES_TO_COPY in target: ${ADD_TARGET_TARGET_NAME} after item: ${SRC}")
                endif()
                if (IS_DIRECTORY "${SRC}")
                    get_filename_component(DIR_NAME "${SRC}" NAME_WE)
                    add_custom_command(TARGET ${ADD_TARGET_TARGET_NAME} POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E copy_directory 
                            "${SRC}" 
                            "${DEST}/${DIR_NAME}")  
                else ()
                    add_custom_command(TARGET ${ADD_TARGET_TARGET_NAME} POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E copy
                            "${SRC}" 
                            "${DEST}")  

                endif ()

            endforeach ()
        endif()

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