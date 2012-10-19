//
//  NSString+GitExtensions.h
//  GitExtensions
//
//  Created by Cristian Kocza on 10/19/12.
//
//

#import <Foundation/Foundation.h>

@interface NSString (GitExtensions)
- (NSString*)trim;
- (NSString*)ellipsisToIndex:(NSUInteger)index;
- (NSString*)ellipsisTo50;
@end
