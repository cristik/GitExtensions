#include "GitWrapper.h"

GITWRAPPER_API void *CreateCGitCommands(const char *gitPath){
    return new CGitCommands(gitPath);
}

GITWRAPPER_API void* CreateCGitRepository(void *gitCommands){
    return new CGitRepository((CGitCommands*)gitCommands);
}

GITWRAPPER_API void DestroyCGitRepository(void *ptr){
    delete ptr;
}

GITWRAPPER_API char *CGitRepository_path(void *ptr){
    return ((CGitRepository*)ptr)->path();
}
    
GITWRAPPER_API GitRepositoryStatus CGitRepository_status(void *ptr){
    return ((CGitRepository*)ptr)->status();
}

GITWRAPPER_API CGitCommit **CGitRepository_commits(void *ptr, int *len){
    vector<CGitCommit*> commits = *((CGitRepository*)ptr)->commits();
    *len = commits.size();
    return *len?&commits[0]:NULL;
}

GITWRAPPER_API void *CGitRepository_branches(void *ptr, int *len){
    vector<CGitBranch*> *branches = ((CGitRepository*)ptr)->branches();
    if(len) *len = branches->size();
    return branches->size()?&branches[0][0]:NULL;
}

GITWRAPPER_API CGitBranch *CGitRepository_activeBranch(void *ptr){
    return ((CGitRepository*)ptr)->activeBranch();
}
    
GITWRAPPER_API void CGitRepository_open(void *ptr,const char* path){
    ((CGitRepository*)ptr)->open(path);
}

GITWRAPPER_API void CGitRepository_refresh(void *ptr){
    ((CGitRepository*)ptr)->refresh();
}

GITWRAPPER_API void CGitRepository_refreshBranches(void *ptr){
    ((CGitRepository*)ptr)->refreshBranches();
}

GITWRAPPER_API void CGitRepository_refreshStatus(void *ptr){
    ((CGitRepository*)ptr)->refreshStatus();
}
        
GITWRAPPER_API CGitBranch *CGitRepository_branchWithName(void *ptr, char* name){
    return ((CGitRepository*)ptr)->branchWithName(name);
}

GITWRAPPER_API CGitBranch **CGitRepository_branchesWithHash(void *ptr, char *sha1, int *len){
    vector<CGitBranch*> branches = *((CGitRepository*)ptr)->branchesWithHash(sha1);
    *len = branches.size();
    return &branches[0];
}

GITWRAPPER_API void CGitRepository_stageFile(void *ptr, CGitFile *file){
    ((CGitRepository*)ptr)->stageFile(file);
}

GITWRAPPER_API void CGitRepository_unstageFile(void *ptr, CGitFile *file){
    ((CGitRepository*)ptr)->unstageFile(file);
}

GITWRAPPER_API void CGitRepository_checkoutBranch(void *ptr, CGitBranch *branch){
    ((CGitRepository*)ptr)->checkoutBranch(branch);
}



GITWRAPPER_API const char *CGitBranch_name(void *ptr){
    return ((CGitBranch*)ptr)->name();
}

GITWRAPPER_API const char *CGitBranch_sha1(void *ptr){
    return ((CGitBranch*)ptr)->sha1();
}

GITWRAPPER_API bool CGitBranch_active(void *ptr){
    return ((CGitBranch*)ptr)->active();
}
