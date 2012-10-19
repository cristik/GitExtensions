//
//  NSArray+GitExtensions.m
//  GitExtensions
//
//  Created by Cristian Kocza on 11.06.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSArray+GitExtensions.h"

@implementation NSArray(GitExtensions)

- (id)objectWithValue:(id)value forKey:(NSString*)key{
    for(id obj in self){
        if([[obj valueForKey:key] isEqual:value]) return obj;
    }
    return nil;
}
@end
