//
//  GitObject.h
//  GitExtensions
//
//  Created by Cristian Kocza on 10/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#ifndef GitExtensions_GitBranch_h_
#define GitExtensions_GitBranch_h_

class CGitRepository;

class GITWRAPPER_API CGitBranch: public CGitObject{
private:
    CGitRepository *_repository;
    const char *_name;
    const char *_sha1;
    bool _active;
public:
    CGitBranch(CGitRepository *repository);
    bool parseString(string s);
    const char *name();
    const char *sha1();    
    bool active();
};

#endif