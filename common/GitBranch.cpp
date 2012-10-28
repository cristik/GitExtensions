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

GitStringParseResult CGitBranch::parseString(string s){
    if(s.length() < 3) return GitStringParseFailed;
    vector<string> comps = split(s, ' ');
    unsigned int i = 1;
    while(i<comps.size() && comps[i].length()==0) i++;
    if(i>=comps.size()) return GitStringParseFailed;
    _name = strdup(comps[i].c_str());
    i++;
    while(i<comps.size() && comps[i].length()==0) i++;
    if(i>=comps.size()) return GitStringParseFailed;
    _sha1 = strtrim(comps[i].c_str());
    _active = s[0] == '*';
    return GitStringParseParsed;   
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