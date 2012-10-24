//
//  NSColor+GitExtensions.h
//  GitExtensions
//
//  Created by Cristian Kocza on 10/24/12.
//
//

#import <Cocoa/Cocoa.h>

@interface NSColor (GitExtensions)
+ (NSArray*)laneColors;
+ (NSColor*)colorForLane:(int)lane;
@end
