//
//  GEBranch.m
//  GitExtensions
//
//  Created by Cristian Kocza on 19.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GitObjects.h"

@interface GEBranch()
@property(nonatomic, retain, readwrite) NSString *name;
@property(nonatomic, retain, readwrite) NSString *sha1;
@end

@implementation GEBranch

@synthesize repository, name, sha1;

+ (id)branchWithRepository:(GEGitRepository*)repository{
    return [[[self alloc] initWithRepository:repository] autorelease];
}

- (id)initWithRepository:(GEGitRepository*)aRepository{
    if(self = [super init]){
        repository = [aRepository retain];
    }
    return self;
}

- (BOOL)parseLine:(NSString*)line{
    if(line.length < 3) return NO;
    NSArray *components = [[line substringFromIndex:2] componentsSeparatedByString:@" "];
    self.name = [components objectAtIndex:0];
    int i = 1;
    while(i<components.count && [[components objectAtIndex:i] length]==0) i++;
    if(i>=components.count) return NO;
    self.sha1 = [[components objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return YES;
}

- (BOOL)active{
    return repository.activeBranch == self;
}

@end
