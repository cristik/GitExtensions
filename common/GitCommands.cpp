// GitWrapper.cpp : Defines the exported functions for the DLL application.
//

#include "GitObjects.h"

// This is the constructor of a class that has been exported.
// see GitWrapper.h for the class definition
CGitCommands::CGitCommands(char *gitPath){
	this->gitPath = strdup(gitPath);
}

uint8_t* CGitCommands::rawGitOutput(char** argv, long *length, int *exitCode){
    char **arg = argv;
    char cmd[65536];
    bzero(cmd, 65536);
    strcat(cmd, this->gitPath);
    while(*arg != NULL){
        bool hasSpace = strchr(*arg, ' ') != NULL;
        if(hasSpace) strcat(cmd," \"");
        else strcat(cmd," ");
        strcat(cmd, *arg);
        if(hasSpace) strcat(cmd,"\"");
        arg++;
    }
    strcat(cmd, " 2>&1");
    FILE *file = popen(cmd, "r");
    if(file == NULL)
        return NULL;
    char buf[1024];
    uint8_t *res = NULL;
    long totalRead = 0;
    while(!feof(file)){
        long read = fread(buf, 1, 1024, file);
        if(read == 0) continue;
        if(res == NULL){
            res = (uint8_t*)malloc(read);
        } else{
            uint8_t *tmp = res;
            res = (uint8_t*)malloc(totalRead+read);
            memcpy(res, tmp, totalRead);
            free(tmp);
        }
        memcpy(res+totalRead, buf, read);
        totalRead += read;
    }
    pclose(file);
    if(length) *length = totalRead;
    return res;
}

char* CGitCommands::gitOutput(char** argv, int *exitCode){
    long length = 0;
    uint8_t *data = this->rawGitOutput(argv, &length, exitCode);
    if(data == NULL)
        return NULL;
    char *res = (char*)malloc(length+1);
    memcpy(res,data, length);
    res[length] = 0;
    return res;
}
