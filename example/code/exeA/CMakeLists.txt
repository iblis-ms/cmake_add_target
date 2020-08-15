
set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(SRC
	"${SRC_DIR}/main.cpp"
	"${SRC_DIR}/ExeA.cpp"
	"${SRC_DIR}/exeA1/ExeA1.cpp"
	"${SRC_DIR}/exeA1/ExeA1Sub/ExeA1Sub.cpp"
	"${SRC_DIR}/exeA2/ExeA2.cpp"
	)
	
set(INC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/inc")


AddTarget(
	TARGET_NAME "exeA"
	TARGET_TYPE "EXE"
	SRC "${SRC}"
	PRIVATE_LIBS "LibraryA"
	PUBLIC_INC_DIRS "${INC_DIR}"
	PUBLIC_DEFINES "DEFINE_A" "DEFINE_AA=1"
	)
