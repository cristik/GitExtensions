#ifndef GITWRAPPER_API
#define GITWRAPPER_API
#endif

#include "GitRepository.h"

class GITWRAPPER_API CGitWrapper {
private:
public:
	CGitWrapper(void);
};

extern GITWRAPPER_API int nGitWrapper;

GITWRAPPER_API int fnGitWrapper(void);
