//
//  GECommit.m
//  GitExtensions
//
//  Created by Cristian Kocza on 18.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GitObjects.h"

@implementation GECommit

@synthesize repository, sha1,parents,author,authorDate,commiter,commitDate,subject,message;

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
        sha1 = [[[comps objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] retain];
        idx++;
        
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
@end
