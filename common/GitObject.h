//
//  GitObject.h
//  GitExtensions
//
//  Created by Cristian Kocza on 10/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#ifndef GitExtensions_GitObject_h_
#define GitExtensions_GitObject_h_

typedef void (PropChangedFunc)(char *propName, void *context);

class GITWRAPPER_API CGitObject{
public:
    PropChangedFunc *_propChangedFunc;
    void *_propChangedContext;
    bool parseString(string s);
};

#endif