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
#include <wchar.h>
#include <iostream>
#include <string>
#include <sstream>
#include <algorithm>
#include <iterator>
using namespace std;

#ifdef WIN32
#define popen _popen
#define pclose _pclose
typedef unsigned char uint8_t;
#endif

class GITWRAPPER_API CGitCommands {
private:
    char *gitPath;
public:
	CGitCommands(const char *gitPath);
    uint8_t* rawGitOutput(const char *workingDir, const char** argv, long *length, int *exitCode);
    char* gitOutput(const char *workingDir, const char** argv, int *exitCode);
};

typedef void (PropChangedFunc)(char *propName, void *context);

class GITWRAPPER_API CGitObject{
public:
    PropChangedFunc propChangedFunc;
    void *propChangedContext;
    bool parseString(string s);
};

typedef enum{
    GitRepositoryStatusNone,
    GitRepositoryStatusNoRepository,
    GitRepositoryStatusEmpty,
    GitRepositoryStatusRegular
}GitRepositoryStatus;

class CGitCommit;
class CGitBranch;
class CGitFile;

class GITWRAPPER_API CGitRepository{
private:
    CGitCommands *gitCommands;
    char *_path;
    GitRepositoryStatus _status;
    vector<CGitCommit*> *_commits;
    vector<CGitBranch*> *_branches;
    CGitBranch *_activeBranch;
public:
    CGitRepository(CGitCommands *gitCommands);
    ~CGitRepository(void);
    
    char *path();
    GitRepositoryStatus status();
    vector<CGitCommit*> *commits();
    vector<CGitBranch*> *branches();
    CGitBranch *activeBranch();
    
    void open(const char* path);
    void refresh();
    void refreshBranches();
    void refreshStatus();
        
    CGitBranch *branchWithName(char* name);
    vector<CGitBranch*> *branchesWithHash(char *sha1);

    //commands
    void stageFile(CGitFile *file);
    void unstageFile(CGitFile *file);
    void checkoutBranch(CGitBranch *branch);
};

class GITWRAPPER_API CGitCommit: public CGitObject{
private:
public:

};

class GITWRAPPER_API CGitBranch: public CGitObject{
private:
    CGitRepository *_repository;
    const char *_name;
    const char *_sha1;
    bool _active;
public:
    CGitBranch(CGitRepository *repository);
    bool parseString(string s);
    const char *name();
    const char *sha1();    
    bool active();
};

class GITWRAPPER_API CGitFile: public CGitObject{
    
};

char *strtrim(const char *str);
vector<string> &split(const string &s, char delim, vector<string> &elems);
vector<string> split(const string &s, char delim);

void log(const char *text);
#endif
