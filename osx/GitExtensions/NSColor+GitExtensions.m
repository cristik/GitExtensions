//
//  NSColor+GitExtensions.m
//  GitExtensions
//
//  Created by Cristian Kocza on 10/24/12.
//
//

#import "NSColor+GitExtensions.h"

@implementation NSColor (GitExtensions)

+ (NSArray*)laneColors{
    static NSArray *laneColors = nil;
    if(laneColors == nil) laneColors = [[NSArray alloc] initWithObjects:
                                        [NSColor redColor],
                                        [NSColor blueColor],
                                        [NSColor greenColor],
                                        [NSColor orangeColor],
                                        [NSColor magentaColor],
                                        [NSColor grayColor],
                                        [NSColor cyanColor],
                                        [NSColor brownColor],
                                        [NSColor purpleColor],
                                        [NSColor blackColor], nil];
    return laneColors;
}

+ (NSColor*)colorForLane:(int)lane{
    NSArray *laneColors = [self laneColors];
    return [laneColors objectAtIndex:lane%laneColors.count];
}
@end
