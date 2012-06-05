//
//  GEFileInfo.h
//  GitExtensions
//
//  Created by Cristian Kocza on 19.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    GEFileStatusUnmodified          = ' ',
    GEFileStatusModified            = 'M',    
    GEFileStatusAdded               = 'A',
    GEFileStatusDeleted             = 'D',
    GEFileStatusRenamed             = 'R',
    GEFileStatusCopied              = 'C',
    GEFileStatusUpdatedButUnmerged  = 'U',
    GEFileStatusUntracked           = '?'
};

typedef NSUInteger GEFileStatus;

@class GEGitRepository;

@interface GERepositoryFile : NSObject{
    GEGitRepository *parentRepository;
    NSString *path;
    NSString *fromPath;
    GEFileStatus indexStatus;
    GEFileStatus workTreeStatus;
}

@property(nonatomic,retain,readwrite) GEGitRepository *parentRepository;
@property(nonatomic,retain,readwrite) NSString *path;
@property(nonatomic,retain,readwrite) NSString *fromPath;
@property(nonatomic,assign,readwrite) GEFileStatus indexStatus;
@property(nonatomic,assign,readwrite) GEFileStatus workTreeStatus;
@property(nonatomic,assign,readonly) NSString *indexDiff;
@property(nonatomic,assign,readonly) NSString *workTreeDiff;


+ (id)fileWithRepository:(GEGitRepository*)repository path:(NSString*)path;
- (id)initWithRepository:(GEGitRepository*)repository path:(NSString*)path;

@end
