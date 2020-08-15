
set(SRC_DIR 
    "${CMAKE_CURRENT_SOURCE_DIR}/src")
    
set(SRC
	"${SRC_DIR}/LibraryA.cpp"
	"${SRC_DIR}/LibrarySecondInc.cpp"
	"${SRC_DIR}/libraryASub/LibraryASub.cpp"
	)
	
set(INC_DIR 
    "${CMAKE_CURRENT_SOURCE_DIR}/inc"
    "${CMAKE_CURRENT_SOURCE_DIR}/inc2"
    )
    
set(INTERFACE_DIR 
    "${CMAKE_CURRENT_SOURCE_DIR}/interface"
    )

AddTarget(
    TARGET_NAME "LibraryA"
    TARGET_TYPE "STATIC"
    SRC "${SRC}"
    PRIVATE_LIBS "LibraryInterfaceA" "LibraryInterfaceB"
    PUBLIC_INC_DIRS "${INTERFACE_DIR}"
    PRIVATE_INC_DIRS "${INC_DIR}"
    PUBLIC_DEFINES "DEFINE_LIB_A" "DEFINE_LIB_AA=1"
    )
