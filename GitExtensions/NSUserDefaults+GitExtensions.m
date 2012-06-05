//
//  NSUserDefaults+GitExtensions.m
//  GitExtensions
//
//  Created by Cristian Kocza on 02.05.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSUserDefaults+GitExtensions.h"

NSString * const GELatestRepositoriesKey = @"GELatestRepositories";

@implementation NSUserDefaults(GitExtensions)

- (NSArray*)latestRepositories{
    return [self objectForKey:GELatestRepositoriesKey];
}

- (void)addRepositoryToLatest:(NSString*)repository{
    NSMutableArray *latestRepositories = [NSMutableArray arrayWithArray:[self latestRepositories]];
    [latestRepositories removeObject:repository];
    [latestRepositories insertObject:repository atIndex:0];
    [self setObject:latestRepositories forKey:GELatestRepositoriesKey];
    [self synchronize];
}

- (void)removeRepositoryFromLatest:(NSString*)repository{
    NSMutableArray *latestRepositories = [NSMutableArray arrayWithArray:[self latestRepositories]];
    [latestRepositories removeObject:repository];
    [self setObject:latestRepositories forKey:GELatestRepositoriesKey];
    [self synchronize];    
}

@end
