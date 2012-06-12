//
//  GitBranch.cpp
//  GitExtensions
//
//  Created by Cristian Kocza on 06.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include "GitObjects.h"

CGitBranch::CGitBranch(CGitRepository *repository){
    _repository = repository;
    _name = NULL;
    _sha1 = NULL;
    _active = false;
}

bool CGitBranch::parseString(string s){
    if(s.length() < 3) return false;
    vector<string> comps = split(s, ' ');
    unsigned int i = 1;
    while(i<comps.size() && comps[i].length()==0) i++;
    if(i>=comps.size()) return false;
    _name = _strdup(comps[i].c_str());
    while(i<comps.size() && comps[i].length()==0) i++;
    if(i>=comps.size()) return false;
    _sha1 = strtrim(comps[i].c_str());
    _active = s[0] == '*';
    return true;   
}

const char *CGitBranch::name(){
    return _name;
}

const char *CGitBranch::sha1(){
    return _sha1;
}

bool CGitBranch::active(){
    return _active;
}