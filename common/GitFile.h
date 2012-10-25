//
//  GitObject.h
//  GitExtensions
//
//  Created by Cristian Kocza on 10/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#ifndef GitExtensions_GitFile_h_
#define GitExtensions_GitFile_h_

class CGitRepository;

class GITWRAPPER_API CGitFile: public CGitObject{
private:
    CGitRepository *_repository;
};

#endif