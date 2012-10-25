//
//  GitRepository.h
//  GitExtensions
//
//  Created by Cristian Kocza on 10/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#ifndef GitExtensions_GitRepository_h_
#define GitExtensions_GitRepository_h_

typedef enum{
    GitRepositoryStatusNone,
    GitRepositoryStatusNoRepository,
    GitRepositoryStatusEmpty,
    GitRepositoryStatusRegular
}GitRepositoryStatus;

class CGitCommands;
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
    vector<CGitBranch*> *_remoteBranches;
    CGitBranch *_activeBranch;
    
    void retrieveBranches(vector<CGitBranch*> *branches, const char *type=NULL);
public:
    CGitRepository(CGitCommands *gitCommands);
    ~CGitRepository(void);
    
    char *path();
    GitRepositoryStatus status();
    vector<CGitCommit*> *commits();
    vector<CGitBranch*> *branches();
    vector<CGitBranch*> *remoteBranches();
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

#endif