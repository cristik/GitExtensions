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
static int minLane = 0;
static int maxOccupied = -1;

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

- (void)laneCommit2:(GECommit*)commit lane:(int)lane{
    //get the first available lane
    if(lane == -1) lane = [self grabLane];
    int originalLane = lane;
    //don't re-lane if already laned
    if(commit.lane < 0) commit.lane = lane;
    for(GECommit *parent in commit.parents){
        //the parent was already lane, release the current one
        if(parent.lane >= 0){
            //[self returnLane:commit.lane];
            //return;
        }
        //first parent will have the same lane as the current commit
        if(parent.lane < 0){
            parent.lane = lane;
            lane = [self grabLane];
            //[commitQueue addObject:parent];
        }        
    }
    for(GECommit *child in commit.children){
        if(child.lane != commit.lane)
            [self returnLane:child.lane];
    }
    //the last lane grab is not desired
    if(lane != originalLane) [self returnLane:lane];
    /*[commitQueue sortWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return ((GECommit*)obj1).index - ((GECommit*)obj2).index;
    }];*/

    /*while(commitQueue.count){
        GECommit *queuedCommit = [commitQueue objectAtIndex:0];
        [commitQueue removeObjectAtIndex:0];
        [self laneCommit2:queuedCommit lane:queuedCommit.lane];
    }*/
}

- (void)laneCommit3:(GECommit*)commit{
    if(commit.lane < 0) commit.lane = [self grabLane];
    GECommit *child = commit.firstChild;
    while(child){
        child.lane = commit.lane;
        child = child.firstChild;
    }
}

- (void)laneCommit4:(GECommit*)commit{
    int lane = [self grabLane4:commit.lane];
    if(lane != commit.lane){
        [self returnLane:commit.lane];
        commit.lane = lane;
    }
    for(GECommit *child in commit.children){
        if(child.lane < 0 || child.lane > lane){
            if(child.lane >= 0) [self returnLane:child.lane];
            child.lane = lane;
            lane = [self grabLane3:commit.lane];
        }
    }
    if(lane != commit.lane) [self returnLane:lane];
    else [self returnLane:commit.lane];
}

- (void)laneCommit5:(GECommit*)commit{
    commit.lane = [self grabLane4:commit.lane];
    [self returnLane:commit.lane];
    for(GECommit *parent in commit.parents){
        if(parent.lane < 0 || parent.lane > commit.lane){
            parent.lane = [self grabLane3:commit.lane];
        }
    }
}

//also populates the parents
- (void)laneCommit:(GECommit*)commit lane:(int*)lane{
    if(commit.lane >= 0) return;
    commit.lane = *lane;
    for(int i=0; i<commit.parents.count;i++){
        [self laneCommit:[commit.parents objectAtIndex:i] lane:lane];
        *lane = *lane + 1;
    }
    if(!commit.parents.count)
        *lane = *lane + 1;
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
}

- (void)reload{
    //parse the branches
    [self reloadBranches];
    NSString *output = [self gitOutput:[NSArray arrayWithObjects:@"log", @"--all", @"--parents", @"--no-color",@"--format=fuller", nil]];
    NSArray *lines = [output componentsSeparatedByString:@"\n"];
    int index = 0;
    NSMutableArray *repCommits = [NSMutableArray array];
    while(index<lines.count){
        GECommit *commit = [GECommit commitWithLines:lines index:&index];
        commit.repository = self;
        if(commit == nil) break;
        [repCommits addObject:commit];
    }
    NSLog(@"before");
    //setup the UI - the lanes
    index = 0;
    for(GECommit *commit in repCommits){
        commit.index = index++;
        NSMutableArray *parentCommits = [NSMutableArray array];
        for(NSString *sha1 in commit.parents){
            GECommit *parentCommit = [repCommits objectWithValue:sha1 forKey:@"sha1"];
            [parentCommits addObject:parentCommit];
            if(!parentCommit.children) parentCommit.children = [NSArray arrayWithObject:commit];
            else parentCommit.children = [parentCommit.children arrayByAddingObject:commit];
        }
        //NSLog(@"commit.index=%d",commit.index);
        commit.parents = parentCommits;
    }
    NSLog(@"lanes");
    memset(&availableLanes,1,1000);
    if(!commitQueue) commitQueue = [[NSMutableArray alloc] init];
    /*for(NSUInteger i=repCommits.count;--i>0;){
        GECommit *commit = [repCommits objectAtIndex:i];
        //this makes sure that branches don't overlap
        //minLane = maxOccupied+1;
        //if(commit.lane < 0)
            [self laneCommit5:commit];
        NSLog(@"Lane %d for commit %@",commit.lane,commit.subject);
    }*/
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
