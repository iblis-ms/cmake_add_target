# cmake_add_target
Helper function for adding targets. Much simpler and shorter way of adding cmake targets.
Typical CMake code:
```
# groups for Visual Studio - wihtout groups VS doesn't show correct folder structure
# here groups for private headers
foreach(PATH_TO_DIR IN LISTS PRIVATE_HEADER_DIRS)
    file(GLOB_RECURSE PATHS_TO_FILES_HPP "${PATH_TO_DIR}/*.hpp")
    source_group(TREE "${ROOT_PATH}" FILES ${PATHS_TO_FILES_HPP})
    file(GLOB_RECURSE PATHS_TO_FILES_H "${PATH_TO_DIR}/*.h")
    source_group(TREE "${ROOT_PATH}" FILES ${PATHS_TO_FILES_H})
    list(APPEND BUF ${PATHS_TO_FILES_HPP} ${PATHS_TO_FILES_H})
endforeach()

# here groups for public headers
foreach(PATH_TO_DIR IN LISTS PRIVATE_HEADER_DIRS)
    file(GLOB_RECURSE PATHS_TO_FILES_HPP "${PATH_TO_DIR}/*.hpp")
    source_group(TREE "${ROOT_PATH}" FILES ${PATHS_TO_FILES_HPP})
    file(GLOB_RECURSE PATHS_TO_FILES_H "${PATH_TO_DIR}/*.h")
    source_group(TREE "${ROOT_PATH}" FILES ${PATHS_TO_FILES_H})
    list(APPEND BUF ${PATHS_TO_FILES_HPP} ${PATHS_TO_FILES_H})
endforeach()

set(HEADERS_TO_SRC ${BUF})

add_executable("exeA" "${SRC_FILES}" "${HEADERS_TO_SRC}")

target_link_libraries("exeA" PUBLIC "${PUBLIC_LIBS}")
target_link_libraries("exeA" PRIVATE "${PRIVATE_LIBS}")

target_include_directories("exeA" PUBLIC "${PUBLIC_HEADER_DIRS}")
target_include_directories("exeA" PRIVATE "${PRIVATE_HEADER_DIRS}")

target_compile_definitions("exeA" PUBLIC "${PUBLIC_DEFINES}")
target_compile_definitions("exeA" PRIVATE "${PRIVATE_DEFINES}")

# And... different approach for headers only libraries - not PUBLIC/PRIVATE but INTERFACE

add_library("headerOnly" INTERFACE)

target_link_libraries("headerOnly" INTERFACE "${PUBLIC_LIBS_2}")

target_include_directories("headerOnly" INTERFACE" ${PUBLIC_HEADER_DIRS_2}")

target_compile_definitions("headerOnly" INTERFACE "${PUBLIC_DEFINES_2}")

```

The same with the function AddTestTarget:
```

AddTestTarget(
    TARGET_NAME "exeA"
    TARGET_TYPE "EXE"
    SRC "${SRC}"
    PUBLIC_LIBS "${PUBLIC_LIBS}"
    PRIVATE_LIBS "${PRIVATE_LIBS}"
    PUBLIC_INC_DIRS "${PUBLIC_HEADER_DIRS}"
    PRIVATE_INC_DIRS "${PRIVATE_HEADER_DIRS}"
    PUBLIC_DEFINES "${PUBLIC_DEFINES}"
    PRIVATE_DEFINES "${PRIVATE_DEFINES}"
    )
    
AddTestTarget(
    TARGET_NAME "headerOnly"
    TARGET_TYPE "INTERFACE"
    PUBLIC_LIBS "${PUBLIC_LIBS_2}"
    PUBLIC_INC_DIRS "${PUBLIC_HEADER_DIRS_2}"
    PUBLIC_DEFINES "${PUBLIC_DEFINES_2}"
    )
```
Groups will be done automatically. INTERFACE instead of PUBLIC is automatically added. 

# Author
Marcin Serwach
I've got several years of experience in programming in C++ and in Java including commercial applications. I also know several other languages: Objective-C, Python, Bash, etc. However I prefer C++.

My LinkedIn profile: [Marcin Serwach](https://pl.linkedin.com/in/marcin-serwach-b8646679)
