//
//  GitObject.cpp
//  GitExtensions
//
//  Created by Cristian Kocza on 05.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "GitObjects.h"

GitStringParseResult CGitObject::parseString(string s){
    return GitStringParseNotNeeded;
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