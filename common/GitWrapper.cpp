// GitWrapper.cpp : Defines the exported functions for the DLL application.
//

#include "GitWrapper.h"


// This is an example of an exported variable
GITWRAPPER_API int nGitWrapper=0;

// This is an example of an exported function.
GITWRAPPER_API int fnGitWrapper(void)
{
	return 42;
}

// This is the constructor of a class that has been exported.
// see GitWrapper.h for the class definition
CGitWrapper::CGitWrapper()
{
	return;
}
