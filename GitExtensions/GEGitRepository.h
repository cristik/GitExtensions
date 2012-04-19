//
//  GEGitRepository.h
//  GitExtensions
//
//  Created by Cristian Kocza on 18.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    GERepositoryStatusNone,
    GERepositoryStatusNoRepository,
    GERepositoryStatusEmpty,
    GERepositoryStatusRegular
};

typedef NSUInteger GERepositoryStatus;

@class GERepositoryFile;

@interface GEGitRepository : NSObject{
    @private
    GERepositoryStatus status;
    NSString *repositoryPath;
    NSArray *commits;
}

@property(nonatomic,assign,readonly) GERepositoryStatus status;
@property(nonatomic,retain,readonly) NSString *repositoryPath;
@property(nonatomic,retain,readonly) NSArray *commits;
@property(nonatomic,assign,readonly) BOOL validRepository;

- (NSData*)rawGitOutput:(NSArray*)arguments;
- (NSString*)gitOutput:(NSArray*)arguments;
- (void)openRepository:(NSString*)path;
- (IBAction)reload:(id)sender;
- (NSArray*)retrieveStatus;
- (void)stageFile:(GERepositoryFile*)fileInfo;
- (void)unstageFile:(GERepositoryFile*)fileInfo;
@end
