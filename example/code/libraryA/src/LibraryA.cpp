#include "LibraryASub/LibraryASub.hpp"
#include "LibraryA.hpp"
#include "LibrarySecondInc.hpp"
#include <iostream>

namespace NLibraryA
{
CLibraryA::CLibraryA()
{
	std::cout<<"CLibraryASub\n";
	CLibraryASub obj;
    CLibrarySecondInclude obj2;
}
	
} // namespace NLibraryA
