#include "LibraryASub/LibraryASub.hpp"
#include <LibraryInterfaceB.hpp>
#include <LibraryInterfaceA.hpp>

#include <iostream>

namespace NLibraryA
{
CLibraryASub::CLibraryASub()
{
	std::cout<<"CLibraryASub\n";
	NLibraryInterfaceB::CLibraryInterfaceB b;
	NLibraryInterfaceA::CLibraryInterfaceA a;
#ifdef DEFINE_LIB_A
		std::cout << "DEFINE_LIB_A\n";
#endif 
		std::cout << "DEFINE_LIB_AA=" << DEFINE_LIB_AA << std::endl;
}
	
} // namespace NLibraryA
