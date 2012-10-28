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
class CGitBranch;
class CGitFile;
class CGitRevision;

class GITWRAPPER_API CGitRepository: public CGitObject{
private:
    char *_gitPath;
    char *_repositoryPath;
    GitRepositoryStatus _status;
    vector<CGitRevision*> *_commits;
    map<string, CGitRevision*> *_revisionMap;
    vector<CGitBranch*> *_branches;
    vector<CGitBranch*> *_remoteBranches;
    CGitBranch *_activeBranch;
    
    void retrieveBranches(vector<CGitBranch*> *branches, const char *type=NULL);
    void retrieveRevisions();
    GitRepositoryStatus processGitCode(int code);
    void setStatus(GitRepositoryStatus value);
public:
    CGitRepository(char *gitPath);
    ~CGitRepository(void);
    
    char *repositoryPath();
    GitRepositoryStatus status();
    vector<CGitRevision*> *commits();
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
    CGitProcess *customCommand(char *args[]);
    void stageFile(CGitFile *file);
    void unstageFile(CGitFile *file);
    void checkoutBranch(CGitBranch *branch);
};

#endif