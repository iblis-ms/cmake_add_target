

set(INTERFACE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/interface")


AddTarget(
TARGET_NAME "LibraryInterfaceC"
TARGET_TYPE "INTERFACE"
PUBLIC_INC_DIRS "${INTERFACE_DIR}"
PUBLIC_DEFINES "DEFINE_INTERFACE_C" "DEFINE_INTERFACE_CC=1"
)
