//
//  GEFileInfo.m
//  GitExtensions
//
//  Created by Cristian Kocza on 19.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GEObjects.h"

@implementation GERepositoryFile

@synthesize parentRepository, path, fromPath, indexStatus, workTreeStatus;

+ (id)fileWithRepository:(GEGitRepository*)repository path:(NSString*)path{
    return [[[self alloc] initWithRepository:repository path:path] autorelease];
}

- (id)initWithRepository:(GEGitRepository*)repository path:(NSString*)aPath{
    if((self = [super init])){
        parentRepository = [repository retain];
        path = [aPath retain];
    }
    return self;
}

- (NSImage*)statusImage:(GEFileStatus)status{
    switch(status){
        case GEFileStatusUnmodified:
            return [NSImage imageNamed:@"file_status_unmodified"];
        case GEFileStatusModified:
            return [NSImage imageNamed:@"file_status_modified"];
        case GEFileStatusAdded:
            return [NSImage imageNamed:@"file_status_added"];
        case GEFileStatusDeleted:
            return [NSImage imageNamed:@"file_status_deleted"];
        case GEFileStatusRenamed:
            return [NSImage imageNamed:@"file_status_renamed"];
        case GEFileStatusCopied:
            return [NSImage imageNamed:@"file_status_copied"];
        case GEFileStatusUpdatedButUnmerged:
            return [NSImage imageNamed:@"file_status_updated_unmerged"];
        default:
            return [NSImage imageNamed:@"file_status_none"];
    }
}

- (NSImage*)indexStatusImage{
    return [self statusImage:self.indexStatus];
}

+ (NSSet*)keyPathsForValuesAffectingIndexStatusImage{
    return [NSSet setWithObject:@"indexStatus"];
}

- (NSImage*)workTreeStatusImage{
    return [self statusImage:self.workTreeStatus];
}

+ (NSSet*)keyPathsForValuesAffectingWorkTreeStatusImage{
    return [NSSet setWithObject:@"workTreeStatus"];
}

- (NSString*)workTreeDiff{
    NSString *contents = nil;
    if(self.workTreeStatus == GEFileStatusAdded || self.workTreeStatus == GEFileStatusUntracked){
        contents = [NSString stringWithContentsOfFile:[self.parentRepository.repositoryPath stringByAppendingPathComponent:self.path]
                                             encoding:NSUTF8StringEncoding error:nil];
    }else{
        contents = [parentRepository gitOutput:[NSArray arrayWithObjects:@"diff", @"--", self.path, nil]];
    }
    return contents;
}

- (NSString*)indexDiff{
    return [parentRepository gitOutput:[NSArray arrayWithObjects:@"diff",@"--cached", @"--", self.path, nil]];
}

- (NSString*)description{
    return self.path;
}

@end
