// GitWrapper.cpp : Defines the exported functions for the DLL application.
//

#include "GitObjects.h"
#include <direct.h>

// This is the constructor of a class that has been exported.
// see GitWrapper.h for the class definition
CGitCommands::CGitCommands(const char *gitPath){
	this->gitPath = strdup(gitPath);
    this->workingDir = NULL;
}

bool CGitCommands::executeGitCommand(...){ 
#ifdef WIN32
    /*CreateProcess(NULL, //lpApplicationName
        gitPath,*/        //lpCommandLine
#else
    int pipe_err[2], pipe_out[2], pipe_in[2];

    if (pipe(pipe_err) || pipe(pipe_out) || pipe(pipe_in)) { // abbreviated error detection
         perror("pipe");
         return false;
    }

    pid_t pid = fork();
    if (!pid) { // in child
        dup2(pipe_err[1], 2);
        dup2(pipe_out[1], 1);
        dup2(pipe_in[0], 0);
        close(pipe_err[0]);
        close(pipe_err[1]);
        close(pipe_out[0]);
        close(pipe_out[1]);
        close(pipe_in[0]);
        close(pipe_in[1]);

        // close any other files that you don't want the new program
        // to get access to here unless you know that they have the
        // O_CLOEXE bit set

        execl(program_path, program_name, arg1, arg2, arg3);
        /* only gets here if there is an error executing the program */
     } else { // in the parent
         if (pid < 0) {
               perror("fork");
               return false;
         }
         child_err = pipe_err[0];
         close(pipe_err[1]);
         child_out = pipe_out[0];
         close(pipe_out[1]);
         child_in = pipe_in[1];
         close(pipe_in[0]);
    }
#endif
    return true;
}

int CGitCommands::readFromOutput(uint8_t *buff, int length){
    return 0;
}

int CGitCommands::readFromError(uint8_t *buff, int length){
    return 0;
}

int CGitCommands::getExitCode(){
    return this->exitCode;
}

char *CGitCommands::getWorkingDir(){
    return workingDir;
}

void CGitCommands::setWorkingDir(const char *value){
    if(workingDir != NULL) free(workingDir);
    if(value) workingDir = strdup(value);
}

char *strtrim(const char *str){
    const char *p1 = strchr(str, ' ');
    const char *p2 = strrchr(str, ' ');
    if(p1 == NULL) p1 = str;
    if(p2 == NULL) p2 = str+strlen(str);
    char *res = (char*)malloc(p2-p1+1);
    memcpy(res,p1, p2-p1);
    res[p2-p1] = 0;
    return res;
}

vector<string> &split(const string &s, char delim, vector<string> &elems){
    stringstream ss(s);
    string item;
    while(getline(ss, item, delim)){
        elems.push_back(item);
    }
    return elems;
}

vector<string> split(const string &s, char delim){
    vector<string> elems;
    return split(s, delim, elems);
}

void log(const char *text){
    FILE *f = fopen("c:\\gelog.txt","a");
    fprintf(f,"%s\n",text);
    fclose(f);
}