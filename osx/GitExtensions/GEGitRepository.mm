//
//  GEGitRepository.m
//  GitExtensions
//
//  Created by Cristian Kocza on 18.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GEObjects.h"
#import "GitObjects.h"
#import "Cocoa+GitExtensions.h"

@interface GEGitRepository()
@property(nonatomic,assign,readwrite) GERepositoryStatus status;
@property(nonatomic,retain,readwrite) NSString *repositoryPath;
@property(nonatomic,retain,readwrite) NSArray *commits;
@property(nonatomic,retain,readwrite) NSArray *branches;
@property(nonatomic,retain,readwrite) NSArray *remoteBranches;
@property(nonatomic,retain,readwrite) GEBranch *activeBranch;

@property(nonatomic,retain,readwrite) NSString *commandInProgress; 
@property(nonatomic,retain,readwrite) NSString *latestOutput;
@property(nonatomic,assign,readwrite) int latestExitCode;
@end

@implementation GEGitRepository

@synthesize status, repositoryPath, commits, branches, remoteBranches, activeBranch;
@synthesize commandInProgress,latestOutput,latestExitCode;

- (id)init{
    if((self = [super init])){
        gitCommands = new CGitCommands("/usr/bin/git");
        gitRepository = new CGitRepository((CGitCommands*)gitCommands);
        status = (NSUInteger)((CGitRepository*)gitRepository)->status();
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
    ((CGitRepository*)gitRepository)->open([path cStringUsingEncoding:NSUTF8StringEncoding]);
    self.repositoryPath = path;    
    [self reload];
}

static BOOL availableLanes[1000];
static NSMutableArray *commitQueue = nil;

- (int)grabLane{
    int i=999;
    for(;i>=0;i--){
        if(!availableLanes[i]){
            break;
        }
    }
    availableLanes[i+1] = NO;
    return i+1;
}

- (int)grabLane3:(int)startLane{
    int i=startLane;
    for(;i<1000;i++){
        if(availableLanes[i]){
            break;
        }
    }
    availableLanes[i] = NO;
    return i;
}

- (int)grabLane4:(int)lane{
    int i=lane>=0?lane-1:999;
    for(;i>=0;i--){
        if(!availableLanes[i]){
            break;
        }
    }
    availableLanes[lane] = YES;
    availableLanes[i+1] = NO;
    return i+1;
}

- (void)returnLane:(NSInteger)lane{
    availableLanes[lane] = YES;
}

- (void)laneCommit5:(GECommit*)commit{
    commit.lane = [self grabLane4:commit.lane];
    [self returnLane:commit.lane];
    for(GECommit *parent in commit.parents){
        if(parent.lane < 0 || parent.lane > commit.lane){
            if(parent.lane >=0) [self returnLane:parent.lane];
            parent.lane = [self grabLane3:commit.lane];
        }
    }
}

- (void)reloadBranches{
    CGitRepository *rep = (CGitRepository*)gitRepository;
    rep->refreshBranches();
    vector<CGitBranch*> *rawBranches = rep->branches();
    vector<CGitBranch*>::iterator it;
    NSMutableArray *newBranches = [NSMutableArray array];
    GEBranch *newActiveBranch = nil;
    for(it=rawBranches->begin(); it!=rawBranches->end(); ++it){
        GEBranch *branch = [GEBranch branchWithRepository:self rawBranch:*it];
        if((*it)->active())
            newActiveBranch = branch;
        [newBranches addObject:branch];
    }
    self.activeBranch = newActiveBranch;
    self.branches = newBranches;
    
    newBranches = [NSMutableArray array];
    rawBranches = rep->remoteBranches();
    for(it=rawBranches->begin(); it!=rawBranches->end(); ++it){
        GEBranch *branch = [GEBranch branchWithRepository:self rawBranch:*it];
        [newBranches addObject:branch];
    }
    self.remoteBranches = newBranches;
}

- (void)reload{
    //parse the branches
    [self reloadBranches];
    NSString *output = [self gitOutput:[NSArray arrayWithObjects:@"log", @"--all", @"--parents", @"--no-color",@"--format=fuller", nil]];
    NSArray *lines = [output componentsSeparatedByString:@"\n"];
    int index = 0;
    NSMutableArray *repCommits = [NSMutableArray array];
    NSMutableDictionary *commitsDict = [NSMutableDictionary dictionaryWithCapacity:repCommits.count];
    while(index<lines.count){
        GECommit *commit = [GECommit commitWithLines:lines index:&index];
        commit.repository = self;
        if(commit == nil) break;
        [repCommits addObject:commit];
        [commitsDict setObject:commit forKey:commit.sha1];
    }
    NSLog(@"before");
    //setup the UI - the lanes
    index = 0;
    for(GECommit *commit in repCommits){
        commit.index = index++;
        NSMutableArray *parentCommits = [NSMutableArray array];
        for(NSString *sha1 in commit.parents){
            GECommit *parentCommit = [commitsDict objectForKey:sha1];//[repCommits objectWithValue:sha1 forKey:@"sha1"];
            [parentCommits addObject:parentCommit];
            if(!parentCommit.children) parentCommit.children = [NSArray arrayWithObject:commit];
            else parentCommit.children = [parentCommit.children arrayByAddingObject:commit];
            //no parent should be above it's children
            if(parentCommit.index < commit.index){
                
            }
        }
        //NSLog(@"commit.index=%d",commit.index);
        commit.parents = parentCommits;
    }
    NSLog(@"lanes");
    memset(&availableLanes,1,1000);
    for(GECommit *commit in repCommits){
        [self laneCommit5:commit];
    }
    
    for(GECommit *commit in repCommits){
        for(GECommit *parent in commit.parents){
            for(int i=commit.index+1;i<parent.index;i++){
                GECommit *otherCommit = [repCommits objectAtIndex:i];
                NSNumber *extraLane = [NSNumber numberWithInt:parent.lane>commit.lane?parent.lane:commit.lane];
                if(otherCommit.extraLanes) otherCommit.extraLanes = [otherCommit.extraLanes arrayByAddingObject:extraLane];
                else otherCommit.extraLanes = [NSArray arrayWithObject:extraLane];
            }
        }
    }
    NSLog(@"after");
    
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
        if([branch.sha1 isEqual:sha1]) [result addObject:branch];
    }
    for(GEBranch *branch in self.remoteBranches){
        if([branch.sha1 isEqual:sha1]) [result addObject:branch];
    }
    return result;
}

- (GECommit*)commitHashed:(NSString*)sha1{
    for(GECommit *commit in self.commits){
        if([commit.sha1 isEqual:sha1]) return commit;
    }
    return nil;
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

- (void)checkoutRevision:(NSString*)revision{
    [self gitOutput:[NSArray arrayWithObjects:@"checkout", revision, nil]];
}
    
#pragma mark Helpers

- (NSString*)gitOutput:(NSArray*)arguments{
    NSString *result = [[[NSString alloc] initWithData:[self rawGitOutput:arguments] encoding:NSUTF8StringEncoding] autorelease];
    self.latestOutput = result;
    NSLog(@"git %@:\n%@",[arguments componentsJoinedByString:@" "],[result substringToIndex:MIN(result.length,512)]);
    return result;
}

- (NSData*)rawGitOutput:(NSArray*)arguments{
    const char **argv = (const char**)calloc(arguments.count+1,sizeof(char*));
    const char **ptr = argv;
    for(NSString *argument in arguments){
        *ptr = strdup([argument cStringUsingEncoding:NSUTF8StringEncoding]);
        ptr++;
    }
    long len = 0;
    int exitCode = 0;
    uint8_t *result = ((CGitCommands*)gitCommands)->rawGitOutput([repositoryPath cStringUsingEncoding:NSUTF8StringEncoding],argv, &len, &exitCode);
    self.latestExitCode = exitCode;
    return [NSData dataWithBytes:result length:len];
}

#pragma mark UI

- (NSAttributedString*)latestOutputAttributed{
    return [[[NSAttributedString alloc] initWithString:self.latestOutput] autorelease];
}
@end
