//
//  GitRevision.cpp
//  GitExtensions
//
//  Created by Cristian Kocza on 10/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#include "GitObjects.h"

#define foreach(variable,iterable) variable; for(typeof(iterable)::iterator it=iterable.begin(); it!=iterable.end();it++){

CGitRevision::CGitRevision(CGitRepository *repository){
    _repository = repository;
    _sha1 = NULL;
    _parents = new vector<CGitRevision*>();
    _author = NULL;
    _authorDate = NULL;
    _commiter = NULL;
    _commitDate = NULL;
    _message = NULL;
}

GitStringParseResult CGitRevision::parseString(string s){
    vector<string> comps;
    //printf("parsing %s\n",s.c_str());
    if(_sha1 == NULL){
        comps = split(s, ' ');
        //printf("1\n");
        if(comps.size() < 2 || comps[0] != "commit"){
            return GitStringParseFailed;
        }
        //printf("2\n");
        _sha1 = new string(comps[1]);
        //printf("3\n");
        _parents->clear();
        for(int i=2;i<comps.size();i++){
            string sha1 = comps[i];
            CGitRevision *parent = new CGitRevision(_repository);
            parent->_sha1 = new string(sha1);
            //printf("comp: %s",sha1.c_str());
        }
        //_parentsSha1 = new vector<string>(&comps[2],&comps[comps.size()-1]);
        //printf("4\n");
        return GitStringParseNeedMore;
    }
    if(s.length() == 0) return _message?GitStringParseParsed:GitStringParseNeedMore;
    if(s.find("    ") > 0){
        int p = (int)s.find(':');
        if(p >= 0){
            string prop = s.substr(0,p);
            string val = s.substr(p+1);
            if(prop == "Merge"){
                
            }else if(prop == "Author"){
                _author = new string(val);
            }else if(prop == "AuthorDate"){
                _authorDate = new string(val);                
            }else if(prop == "Commit"){
                _commiter = new string(val);
            }else if(prop == "CommitDate"){
                _commitDate = new string(val);
            }
            return GitStringParseNeedMore;
        }
    }else if(s.find("    ") == 0){
        if(!_message) _message = new string(s);
        else { 
            string *tmp = _message; 
            _message = new string(*_message+s.substr(4)); 
            delete tmp;
        }
        return GitStringParseNeedMore;
    
    }
    return GitStringParseFailed;
        
    /*//get the sha1
    NSArray *comps = [[lines objectAtIndex:idx] componentsSeparatedByString:@" "];
    if(![[comps objectAtIndex:0] isEqual:@"commit"] || comps.count<2){
        [self autorelease];
        return nil;
    }
    //TODO: add -[NSArray trimmedStringAtIndex:]
    sha1 = [[[comps objectAtIndex:1] trim] retain];
    idx++;
    parents = [[comps subarrayWithRange:NSMakeRange(2, comps.count-2)] retain];
    
    //get the rest of details
    NSString *line = nil;
    while(idx<lines.count && (line=[lines objectAtIndex:idx]) && line.length){
        int p = (int)[line rangeOfString:@":"].location;
        if(p != NSNotFound){
            comps = [NSArray arrayWithObjects:[line substringToIndex:p], [line substringFromIndex:p+1],nil];
        }else{
            comps = [NSArray arrayWithObject:line];
        }
        NSString *prop = [comps objectAtIndex:0];
        if(comps.count < 2) continue;
        NSString *val = [[comps objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([prop isEqual:@"Merge"]){
            
        }else if([prop isEqual:@"Author"]){
            author = [val retain];
        }else if([prop isEqual:@"AuthorDate"]){
            authorDate = [val retain];                
        }else if([prop isEqual:@"Commit"]){
            commiter = [val retain];
        }else if([prop isEqual:@"CommitDate"]){
            commitDate = [val retain];
        }
        idx++;
    }
    idx++;
    
    //get the message
    NSString *subj = nil;
    NSMutableString *msg = [NSMutableString string];
    while(idx<lines.count && (line=[lines objectAtIndex:idx]) && line.length && [line rangeOfString:@"    "].location==0){
        if(!subj)
            subj = [line substringFromIndex:4];
        else
            [msg appendFormat:@"%@\n",[line substringFromIndex:4]];
        idx++;
    }
    //delete the last \n
    if(msg.length) [msg deleteCharactersInRange:NSMakeRange(msg.length-1, 1)];
    subject = [subj retain];
    message = [[msg description] retain];
    
    //there are some commits that don't have a message and only one empty line is present
    if(!line.length)
        idx++;
    
    *index = idx;
    
    //dont belong to a lane, yet
    _lane = -1;*/
    
    return GitStringParseNotNeeded;
}