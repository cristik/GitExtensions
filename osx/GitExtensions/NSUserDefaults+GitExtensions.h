//
//  NSUserDefaults+GitExtensions.h
//  GitExtensions
//
//  Created by Cristian Kocza on 02.05.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults(GitExtensions)

- (NSArray*)latestRepositories;
- (void)addRepositoryToLatest:(NSString*)repository;
- (void)removeRepositoryFromLatest:(NSString*)repository;
@end
