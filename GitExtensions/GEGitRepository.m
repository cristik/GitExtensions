//
//  GEGitRepository.m
//  GitExtensions
//
//  Created by Cristian Kocza on 18.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GitObjects.h"

@interface GEGitRepository()
@property(nonatomic,assign,readwrite) GERepositoryStatus status;
@property(nonatomic,retain,readwrite) NSString *repositoryPath;
@property(nonatomic,retain,readwrite) NSArray *commits;
@property(nonatomic,retain,readwrite) NSArray *branches;
@property(nonatomic,retain,readwrite) GEBranch *activeBranch;

@property(nonatomic,retain,readwrite) NSString *commandInProgress; 
@property(nonatomic,retain,readwrite) NSString *latestOutput;
@property(nonatomic,assign,readwrite) int latestExitCode;
@end

@implementation GEGitRepository

@synthesize status, repositoryPath, commits, branches, activeBranch;
@synthesize commandInProgress,latestOutput,latestExitCode;

- (id)init{
    if((self = [super init])){
        status = GERepositoryStatusNone;
    }
    return self;
}

+ (NSSet*)keyPathsForValuesAffectingValidRepository{
    return [NSSet setWithObject:@"status"];
}

- (BOOL)validRepository{
    return self.status == GERepositoryStatusRegular || self.status == GERepositoryStatusEmpty;
}

- (void)openRepository:(NSString*)path{
    self.repositoryPath = path;
    [self reload];
}

- (void)reloadBranches{
    NSString *output = [self gitOutput:[NSArray arrayWithObjects:@"branch", @"--no-color", @"-v", @"--no-abbrev", nil]];
    NSArray *lines = [output componentsSeparatedByString:@"\n"];
    NSMutableArray *newBranches = [NSMutableArray array];
    GEBranch *newActiveBranch = nil;
    for(NSString *line in lines){
        if(line.length < 3) continue;
        GEBranch *branch = [GEBranch branchWithRepository:self];
        if([branch parseLine:line]){
            [newBranches addObject:branch];
            if([line characterAtIndex:0] == '*')
                newActiveBranch = branch;
        }
    }
    self.activeBranch = newActiveBranch;
    self.branches = newBranches;    
}

- (void)reload{
    //parse the branches
    [self reloadBranches];
    NSString *output = [self gitOutput:[NSArray arrayWithObjects:@"log", @"--parents", @"--no-color",@"--format=fuller", nil]];
    NSArray *lines = [output componentsSeparatedByString:@"\n"];
    int index = 0;
    NSMutableArray *repCommits = [NSMutableArray array];
    while(index<lines.count){
        GECommit *commit = [GECommit commitWithLines:lines index:&index];
        commit.repository = self;
        if(commit == nil) break;
        [repCommits addObject:commit];
    }
    self.commits = repCommits;
    if(self.commits.count) self.status = GERepositoryStatusRegular;
    else self.status = GERepositoryStatusEmpty;
}

- (NSArray*)retrieveStatus{
    NSData *output = [self rawGitOutput:[NSArray arrayWithObjects:@"status",@"-uall",@"--porcelain",@"-z", nil]];
    char *bytes = (char*)[output bytes];
    int pos = 0;
    NSMutableArray *result = [NSMutableArray array];
    while(pos<output.length){
        GEFileStatus indexStatus = bytes[pos], workTreeStatus = bytes[pos+1];
        NSString *path = nil;
        NSString *fromPath = nil;
        pos += 3;
        int pos2 = pos;
        while(pos2<output.length && bytes[pos2]) pos2++;
        path = [NSString stringWithCString:bytes+pos encoding:NSUTF8StringEncoding];
        pos = ++pos2;
        if(indexStatus == GEFileStatusRenamed){
            while(pos2<output.length && bytes[pos2]) pos2++;
            fromPath = [NSString stringWithCString:bytes+pos encoding:NSUTF8StringEncoding];
            pos = ++pos2;
        }
        GERepositoryFile *fileInfo = [GERepositoryFile fileWithRepository:self path:path];
        fileInfo.indexStatus = indexStatus;
        fileInfo.workTreeStatus = workTreeStatus;
        fileInfo.fromPath = fromPath;
        [result addObject:fileInfo];
    }
    return result;
}

- (GEBranch*)branchNamed:(NSString*)name{
    for(GEBranch *branch in self.branches){
        if([branch.name isEqual:name]) return branch;
    }
    return nil;
}

- (NSArray*)branchesHashed:(NSString*)sha1{
    NSMutableArray *result = [NSMutableArray array];
    for(GEBranch *branch in self.branches){
        if([branch.sha1 isEqual:sha1]) [result addObject:branch];;
    }
    return result;
}

#pragma mark Commands

- (void)stageFile:(GERepositoryFile*)fileInfo{
    [self gitOutput:[NSArray arrayWithObjects:fileInfo.workTreeStatus==GEFileStatusDeleted?@"rm":@"add",fileInfo.path,nil]];
}

- (void)unstageFile:(GERepositoryFile*)fileInfo{
    [self gitOutput:[NSArray arrayWithObjects:@"reset",@"--",fileInfo.path,nil]];    
}

- (void)checkoutBranch:(GEBranch*)branch{
    [self gitOutput:[NSArray arrayWithObjects:@"checkout", branch.name, nil]];
}
    
#pragma mark Helpers

- (NSString*)gitOutput:(NSArray*)arguments{
    NSString *result = [[[NSString alloc] initWithData:[self rawGitOutput:arguments] encoding:NSUTF8StringEncoding] autorelease];
    self.latestOutput = result;
    NSLog(@"git %@:\n%@",[arguments componentsJoinedByString:@" "],[result substringToIndex:MIN(result.length,512)]);
    return result;
}

- (NSData*)rawGitOutput:(NSArray*)arguments{
    NSTask *task = [[[NSTask alloc] init] autorelease];
    //TODO: option to change this
    task.launchPath = @"/usr/bin/git";
    task.arguments = arguments;
    task.currentDirectoryPath = self.repositoryPath;
    NSPipe *pipe = [[NSPipe alloc] init];
    task.standardOutput = pipe;
    task.standardError = pipe;
    [task launch];    
    NSData *data = [pipe.fileHandleForReading readDataToEndOfFile];
    [pipe release]; pipe = nil;
    [task waitUntilExit];
    self.latestExitCode = task.terminationStatus;
    return data;
}

#pragma mark UI

- (NSAttributedString*)latestOutputAttributed{
    return [[[NSAttributedString alloc] initWithString:self.latestOutput] autorelease];
}
@end
