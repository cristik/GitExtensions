//
//  GitObjects.h
//  GitExtensions
//
//  Created by Cristian Kocza on 05.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef GitExtensions_GitObjects_h_
#define GitExtensions_GitObjects_h_

#ifndef GITWRAPPER_API
#define GITWRAPPER_API
#endif

#include <vector>
#include <map>
#include <wchar.h>
#include <iostream>
#include <string>
#include <sstream>
#include <algorithm>
#include <iterator>
#ifdef WIN32
#include <windows.h>
#endif
using namespace std;

#ifdef WIN32
#define popen _popen
#define pclose _pclose
typedef unsigned char uint8_t;
#endif

#include "GitObject.h"
#include "GitBranch.h"
#include "GitFile.h"
#include "GitProcess.h"
#include "GitRemote.h"
#include "GitRepository.h"
#include "GitRevision.h"


char *strtrim(const char *str);
vector<string> &split(const string &s, char delim, vector<string> &elems);
vector<string> split(const string &s, char delim);

void log(const char *text);
#endif
