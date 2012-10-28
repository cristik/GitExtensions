#include "GitObjects.h"


CGitRepository::CGitRepository(char *gitPath){
    _gitPath = strdup(gitPath);
    _repositoryPath = NULL;
    _branches = new vector<CGitBranch*>();
    _remoteBranches = NULL;
    _commits = new vector<CGitRevision*>();
    _revisionMap = new map<string, CGitRevision*>();
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

vector<CGitRevision*> *CGitRepository::commits(){
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
    retrieveRevisions();
    printf("having %lu commits",_commits->size());
}

GitRepositoryStatus CGitRepository::processGitCode(int code){
    if(code == 0){
        return GitRepositoryStatusRegular;
    }else if(code == 128){
        return GitRepositoryStatusNoRepository;
    }
    return GitRepositoryStatusNone;
}

void CGitRepository::setStatus(GitRepositoryStatus value){
    _status = value;
    if(_propChangedFunc){
        _propChangedFunc((char*)"status", _propChangedContext);
    }
}

void CGitRepository::retrieveBranches(vector<CGitBranch*> *branches, const char *type){
    const char *args[] = {"branch", "--no-color", "-v", "--no-abbrev", type, NULL};
    CGitProcess *process = new CGitProcess(_gitPath,(char**)args,_repositoryPath,true);
    char *output = process->grabOutput();
    //printf("_exitCode: %d\noutput: %s\n",process->exitCode(),output);
    setStatus(processGitCode(process->exitCode()));
    if( _status != GitRepositoryStatusRegular){
        return;
    }
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

void CGitRepository::retrieveRevisions(){
    const char *args[] = {"log", "--all", "--parents", "--no-color", "--format=fuller", NULL};
    CGitProcess *process = new CGitProcess(_gitPath,(char**)args,_repositoryPath,true);
    char *output = process->grabOutput();
    setStatus(processGitCode(process->exitCode()));
    if( _status != GitRepositoryStatusRegular){
        return;
    }
    vector<string> lines = split(string(output),'\n');
    lines.push_back("");
    vector<string>::iterator iter;
    _commits->clear();
    CGitRevision *revision = NULL;
    for(iter=lines.begin(); iter != lines.end(); ++iter){
        if(!revision) revision = new CGitRevision(this);
        GitStringParseResult res = revision->parseString(*iter);
        //printf("parsed\n");
        if(res == GitStringParseParsed){
            revision->_index = (int)_commits->size();
            _commits->push_back(revision);
            _revisionMap->insert(make_pair(*revision->_sha1, revision));
            revision = new CGitRevision(this);
        }else if(res == GitStringParseFailed){
            delete revision;
            revision = new CGitRevision(this);
        }
    }
    for(int i=0;i<_commits->size();i++){
        CGitRevision *rev = (*_commits)[i];
        for(int j=0;j<rev->_parents->size();j++){
            CGitRevision *parent = (*rev->_parents)[j];
            (*rev->_parents)[j] = (*_revisionMap)[*parent->_sha1];
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