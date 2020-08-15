#ifndef LIBRARY_INTERFACE_B_HPP_
#define LIBRARY_INTERFACE_B_HPP_

#include "LibraryInterfaceA.hpp"
#include <iostream>

namespace NLibraryInterfaceB
{
class CLibraryInterfaceB
{
public: 
	CLibraryInterfaceB()
	{
		std::cout<<"CLibraryInterfaceB\n";
		NLibraryInterfaceA::CLibraryInterfaceA a;
	}
};	
	
} // namespace NLibraryInterfaceB


#endif // LIBRARY_INTERFACE_B_HPP_