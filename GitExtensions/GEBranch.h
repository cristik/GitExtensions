//
//  GEBranch.h
//  GitExtensions
//
//  Created by Cristian Kocza on 19.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GEGitRepository;

@interface GEBranch : NSObject{
@private 
    GEGitRepository *repository;
    NSString *name;
    NSString *sha1;
}

@property(nonatomic, retain, readonly) GEGitRepository *repository;
@property(nonatomic, retain, readonly) NSString *name;
@property(nonatomic, retain, readonly) NSString *sha1;
@property(nonatomic, assign, readonly) BOOL active;

+ (id)branchWithRepository:(GEGitRepository*)repository;
- (id)initWithRepository:(GEGitRepository*)repository;

- (BOOL)parseLine:(NSString*)line;
@end
