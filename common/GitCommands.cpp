// GitWrapper.cpp : Defines the exported functions for the DLL application.
//

#include "GitObjects.h"

// This is the constructor of a class that has been exported.
// see GitWrapper.h for the class definition
CGitCommands::CGitCommands(const char *gitPath){
    log("Creating CGitCommands");
    log(gitPath);
	this->gitPath = _strdup(gitPath);
}

uint8_t* CGitCommands::rawGitOutput(const char** argv, long *length, int *exitCode){
    const char **arg = argv;
    char cmd[65536];
    memset(cmd, 0, 65536);
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
    int code = pclose(file);
    if(length) *length = totalRead;
    if(exitCode) *exitCode = code;
    return res;
}

char* CGitCommands::gitOutput(const char** argv, int *exitCode){
    long length = 0;
    uint8_t *data = this->rawGitOutput(argv, &length, exitCode);
    if(data == NULL)
        return NULL;
    char *res = (char*)malloc(length+1);
    memcpy(res,data, length);
    res[length] = 0;
    log(res);
    return res;
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