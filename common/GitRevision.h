//
//  GitObject.h
//  GitExtensions
//
//  Created by Cristian Kocza on 10/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#ifndef GitExtensions_GitRevision_h_
#define GitExtensions_GitRevision_h_

class CGitRepository;

class GITWRAPPER_API CGitRevision: public CGitObject{
public:
    CGitRepository *_repository;
    string *_sha1;
    vector<CGitRevision*> *_parents;
    string *_author;
    string *_authorDate;
    string *_commiter;
    string *_commitDate;
    string *_message;
   
    int _lane;
    int _index;
public:
    CGitRevision(CGitRepository *repository);
    virtual GitStringParseResult parseString(string s);
};

#endif