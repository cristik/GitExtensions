//
//  NSString+GitExtensions.m
//  GitExtensions
//
//  Created by Cristian Kocza on 10/19/12.
//
//

#import "NSString+GitExtensions.h"

@implementation NSString (GitExtensions)
- (NSString*)trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString*)ellipsisToIndex:(NSUInteger)index{
    if(self.length < index-3)
        return self;
    return [[self substringToIndex:index-3] stringByAppendingString:@"..."];
}

- (NSString*)ellipsisTo50{
    return [self ellipsisToIndex:50];
}
@end
