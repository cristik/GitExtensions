#include "GitObjects.h"


CGitRepository::CGitRepository(char *gitPath){
    _gitPath = strdup(gitPath);
    _repositoryPath = NULL;
    _branches = new vector<CGitBranch*>();
    _remoteBranches = NULL;
    _commits = new vector<CGitCommit*>();
    _status = GitRepositoryStatusNone;
    _activeBranch = NULL;
}

CGitRepository::~CGitRepository(void){
}

char* CGitRepository::repositoryPath(){
    return _repositoryPath;
}

GitRepositoryStatus CGitRepository::status(){
    return this->_status;
}

vector<CGitCommit*> *CGitRepository::commits(){
    return _commits;
}

vector<CGitBranch*> *CGitRepository::branches(){
    return _branches;
}


vector<CGitBranch*> *CGitRepository::remoteBranches(){
    if(_remoteBranches == NULL){
        _remoteBranches = new vector<CGitBranch*>();
        retrieveBranches(_remoteBranches, "-r");
    }
    return _remoteBranches;
}

CGitBranch *CGitRepository::activeBranch(){
    return _activeBranch;
}

void CGitRepository::open(const char* path){
    _repositoryPath = strdup(path);
    this->refresh();
}

void CGitRepository::refresh(){
    refreshBranches();
}

void CGitRepository::retrieveBranches(vector<CGitBranch*> *branches, const char *type){
    const char *args[] = {"branch", "--no-color", "-v", "--no-abbrev", type, NULL};
    CGitProcess *process = new CGitProcess(_gitPath,(char**)args,_repositoryPath,true);
    char *output = process->grabOutput();
    //printf("_exitCode: %d\noutput: %s\n",process->exitCode(),output);
    branches->clear();
    vector<string> lines = split(string(output),'\n');
    vector<string>::iterator iter;
    for(iter=lines.begin(); iter != lines.end(); ++iter){
        string line = *iter;
        if(line.length() < 3) continue;
        CGitBranch *branch = new CGitBranch(this);
        if(branch->parseString(line)) {
            branches->push_back(branch);
        }
    }
}

void CGitRepository::refreshBranches(){
    retrieveBranches(_branches);
    vector<CGitBranch*>::iterator iter;
    for(iter=_branches->begin(); iter != _branches->end(); ++iter){
        if((*iter)->active())
            _activeBranch = *iter;

    }    
    delete _remoteBranches;
    _remoteBranches = NULL;
}

void CGitRepository::refreshStatus(){
    
}

CGitBranch *CGitRepository::branchWithName(char* name){
    return NULL;
}

vector<CGitBranch*> *CGitRepository::branchesWithHash(char *sha1){
    return NULL;
}

//commands

CGitProcess *CGitRepository::customCommand(char *args[]){
    return new CGitProcess(_gitPath,(char**)args,_repositoryPath,false);
}

void CGitRepository::stageFile(CGitFile *file){
    
}

void CGitRepository::unstageFile(CGitFile *file){
    
}

void CGitRepository::checkoutBranch(CGitBranch *branch){
    
}