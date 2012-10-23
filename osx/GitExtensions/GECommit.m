//
//  GECommit.m
//  GitExtensions
//
//  Created by Cristian Kocza on 18.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GEObjects.h"
#import "Cocoa+GitExtensions.h"

@interface GECommit()
@property(nonatomic,retain,readwrite) NSString *sha1;
//TODO: remove somehow the readwrite from here
@property(nonatomic,retain,readwrite) NSString *author;
@property(nonatomic,retain,readwrite) NSString *authorDate;
@property(nonatomic,retain,readwrite) NSString *commiter;
@property(nonatomic,retain,readwrite) NSString *commitDate;
@property(nonatomic,retain,readwrite) NSString *subject;
@property(nonatomic,retain,readwrite) NSString *message;
@end

@implementation GECommit

@synthesize repository, sha1,parents,children,author,authorDate,commiter,commitDate,subject,message;
@synthesize lane = _lane, index = _index, extraLanes = _extraLanes;

- (GECommit*)firstParent{
    return self.parents.count?[self.parents objectAtIndex:0]:nil;
}

- (GECommit*)firstChild{
    return self.children.count?[self.children objectAtIndex:0]:nil;
}

+ (id)commitWithLines:(NSArray*)lines index:(int*)index{
    return [[[self alloc] initWithLines:lines index:index] autorelease];
}

- (id)initWithLines:(NSArray*)lines index:(int*)index{
    if(self == [super init]){
        int idx = *index;
        //get the sha1
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
            comps = [line componentsSeparatedByString:@":"];
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
        _lane = -1;
    }
    return self;
}

- (NSString*)description{
    return [NSString stringWithFormat:@"%@: %@",self.sha1,self.message];
}

#pragma mark UI

- (NSString*)fullDescription{
    NSArray *branches = [[self.repository branchesHashed:self.sha1] valueForKey:@"name"];
    if(branches.count)
        return [NSString stringWithFormat:@"[%@] %@",[branches componentsJoinedByString:@"]["], self.subject];
    else
        return self.subject;
}

- (NSString*)parentsString{
    return [NSString stringWithFormat:@"Parents: %@",[[self.parents valueForKeyPath:@"subject.ellipsisTo50"] componentsJoinedByString:@"; "]];
}

#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone{
    GECommit *copy = [[GECommit allocWithZone:zone] init];
    copy.repository = self.repository;
    copy.sha1 = self.sha1;
    copy.parents = self.parents;
    copy.children = self.children;
    copy.author = self.author;
    copy.authorDate = self.authorDate;
    copy.commiter = self.commiter;
    copy.commitDate = self.commitDate;
    copy.subject = self.subject;
    copy.message = self.message;
    copy.lane = self.lane;
    copy.index = self.index;
    copy.extraLanes = self.extraLanes;
    return copy;
}
@end
