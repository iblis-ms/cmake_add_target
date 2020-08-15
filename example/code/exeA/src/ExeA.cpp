#include "ExeA.hpp"
#include "ExeA1/ExeA1.hpp"
#include "ExeA2/ExeA2.hpp"
#include <iostream>

namespace NExeA
{
	
CExeA::CExeA()
{
	std::cout<<"CExeA\n";
	CExeA1 exe1;
	CExeA2 exe2;
}


} // namespace NExeA
