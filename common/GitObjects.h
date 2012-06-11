//
//  GitObjects.h
//  GitExtensions
//
//  Created by Cristian Kocza on 05.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef GitExtensions_GitObjects_h_
#define GitExtensions_GitObjects_h_

#ifndef GITWRAPPER_API
#define GITWRAPPER_API
#endif

#include <vector>
using namespace std;

class GITWRAPPER_API CGitCommands {
private:
    char *gitPath;
public:
	CGitCommands(char *gitPath);
    uint8_t* rawGitOutput(char** argv, long *length, int *exitCode);
    char* gitOutput(char** argv, int *exitCode);
};

typedef void (PropChangedFunc)(char *propName, void *context);

class GITWRAPPER_API CGitObject{
public:
    PropChangedFunc propChangedFunc;
    void *propChangedContext;
};

typedef enum{
    GitRepositoryStatusNone,
    GitRepositoryStatusNoRepository,
    GitRepositoryStatusEmpty,
    GitRepositoryStatusRegular
}GitRepositoryStatus;

class CGitCommit;
class CGitBranch;

class GITWRAPPER_API CGitRepository{
private:
    char *path;
    GitRepositoryStatus status;
    vector<CGitCommit> commits;
    vector<CGitBranch> branches;
public:
    CGitRepository(char *path);
    ~CGitRepository(void);
};

class GITWRAPPER_API CGitCommit: public CGitObject{
    
};

class GITWRAPPER_API CGitBranch: public CGitObject{
    
};

class GITWRAPPER_API CGitFile: public CGitObject{
    
};


#endif
