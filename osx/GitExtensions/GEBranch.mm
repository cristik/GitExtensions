//
//  GEBranch.m
//  GitExtensions
//
//  Created by Cristian Kocza on 19.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GEObjects.h"
#import "GitObjects.h"

@interface GEBranch()
@property(nonatomic, retain, readwrite) NSString *name;
@property(nonatomic, retain, readwrite) NSString *sha1;
@end

@implementation GEBranch

@synthesize repository, name, sha1, active;

+ (id)branchWithRepository:(GEGitRepository*)repository rawBranch:(void*)rawBranch{
    return [[[self alloc] initWithRepository:repository rawBranch:rawBranch] autorelease];
}

- (id)initWithRepository:(GEGitRepository*)aRepository rawBranch:(void*)rBranch{
    if((self = [super init])){
        self->rawBranch = rBranch;
        repository = [aRepository retain];
        CGitBranch *branch = (CGitBranch*)rBranch;
        name = [[NSString stringWithCString:branch->name() encoding:NSUTF8StringEncoding] retain];
        sha1 = [[NSString stringWithCString:branch->sha1() encoding:NSUTF8StringEncoding] retain];
        active = branch->active();
    }
    return self;
}

@end
