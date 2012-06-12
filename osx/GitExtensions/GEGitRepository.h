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
@class GEBranch;

@interface GEGitRepository : NSObject{
    @private
    void *gitCommands;
    void *gitRepository;
    GERepositoryStatus status;
    NSString *repositoryPath;
    NSArray *commits;
    NSArray *branches;
    GEBranch *activeBranch;
    
    NSString *commandInProgress; 
    NSString *latestOutput;
    int latestExitCode;
}

@property(nonatomic,assign,readonly) GERepositoryStatus status;
@property(nonatomic,retain,readonly) NSString *repositoryPath;
@property(nonatomic,retain,readonly) NSArray *commits;
@property(nonatomic,retain,readonly) NSArray *branches;
@property(nonatomic,retain,readonly) GEBranch *activeBranch;
@property(nonatomic,assign,readonly) BOOL validRepository;

@property(nonatomic,retain,readonly) NSString *commandInProgress; 
@property(nonatomic,retain,readonly) NSString *latestOutput;
@property(nonatomic,assign,readonly) int latestExitCode;

- (NSData*)rawGitOutput:(NSArray*)arguments;
- (NSString*)gitOutput:(NSArray*)arguments;
- (void)openRepository:(NSString*)path;
- (void)reloadBranches;
- (void)reload;
- (NSArray*)retrieveStatus;
- (GEBranch*)branchNamed:(NSString*)name;
- (NSArray*)branchesHashed:(NSString*)sha1;
//commands
- (void)stageFile:(GERepositoryFile*)fileInfo;
- (void)unstageFile:(GERepositoryFile*)fileInfo;
- (void)checkoutBranch:(GEBranch*)branch;
@end
