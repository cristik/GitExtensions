#include "GitObjects.h"


CGitRepository::CGitRepository(CGitCommands *gitCommands){
    this->gitCommands = gitCommands;
    _path = NULL;
    _branches = new vector<CGitBranch*>();
    _commits = new vector<CGitCommit*>();
    _status = GitRepositoryStatusNone;
    _activeBranch = NULL;
}

CGitRepository::~CGitRepository(void){
}

char* CGitRepository::path(){
    return _path;
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

CGitBranch *CGitRepository::activeBranch(){
    return _activeBranch;
}

void CGitRepository::open(const char* path){
    _path = strdup(path);
    this->refresh();
}

void CGitRepository::refresh(){
    refreshBranches();
}

void CGitRepository::refreshBranches(){
    const char *args[] = {"branch", "--no-color", "-v", "--no-abbrev", NULL};
    char *output = gitCommands->gitOutput(args, NULL);
    _branches->clear();
    vector<string> lines = split(string(output),'\n');
    vector<string>::iterator iter;
    for(iter=lines.begin(); iter != lines.end(); ++iter){
        string line = *iter;
        if(line.length() < 3) continue;
        CGitBranch *branch = new CGitBranch(this);
        if(branch->parseString(line)) {
            _branches->push_back(branch);
            if(branch->active())
                _activeBranch = branch;
        }
    }
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
void CGitRepository::stageFile(CGitFile *file){
    
}

void CGitRepository::unstageFile(CGitFile *file){
    
}

void CGitRepository::checkoutBranch(CGitBranch *branch){
    
}