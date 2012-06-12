// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the GITWRAPPER_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// GITWRAPPER_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef GITWRAPPER_EXPORTS
#define GITWRAPPER_API __declspec(dllexport)
#else
#define GITWRAPPER_API __declspec(dllimport)
#endif

#include "../../common/GitObjects.h"

GITWRAPPER_API void *CreateCGitCommands(const char *gitPath);

GITWRAPPER_API void* CreateCGitRepository(void *gitCommands);
GITWRAPPER_API void DestroyCGitRepository(void *ptr);
    
GITWRAPPER_API char *CGitRepository_path(void *ptr);
GITWRAPPER_API GitRepositoryStatus CGitRepository_status(void *ptr);
GITWRAPPER_API CGitCommit **CGitRepository_commits(void *ptr, int *len);
GITWRAPPER_API CGitBranch **CGitRepository_branches(void *ptr, int *len);
GITWRAPPER_API CGitBranch *CGitRepository_activeBranch(void *ptr);
    
GITWRAPPER_API void CGitRepository_open(void *ptr,const char* path);
GITWRAPPER_API void CGitRepository_refresh(void *ptr);
GITWRAPPER_API void CGitRepository_refreshBranches(void *ptr);
GITWRAPPER_API void CGitRepository_refreshStatus(void *ptr);
        
GITWRAPPER_API CGitBranch *CGitRepository_branchWithName(void *ptr, char* name);
GITWRAPPER_API CGitBranch **CGitRepository_branchesWithHash(void *ptr, char *sha1, int *len);

    //commands
GITWRAPPER_API void CGitRepository_stageFile(void *ptr, CGitFile *file);
GITWRAPPER_API void CGitRepository_unstageFile(void *ptr, CGitFile *file);
GITWRAPPER_API void CGitRepository_checkoutBranch(void *ptr, CGitBranch *branch);