//
//  GELaneTableViewCell.m
//  GitExtensions
//
//  Created by Cristian Kocza on 10/19/12.
//
//

#import "GELaneTableViewCell.h"
#import "GEObjects.h"

int laneColorsCount = 0;
NSColor **laneColors;

@implementation GELaneTableViewCell

+ (void)initialize{
    laneColorsCount = 10;
    laneColors = (NSColor**)malloc(laneColorsCount*sizeof(NSColor*));
    laneColors[0] = [NSColor redColor];
    laneColors[1] = [NSColor blueColor];
    laneColors[2] = [NSColor greenColor];
    laneColors[3] = [NSColor orangeColor];
    laneColors[4] = [NSColor magentaColor];
    laneColors[5] = [NSColor yellowColor];
    laneColors[6] = [NSColor cyanColor];
    laneColors[7] = [NSColor brownColor];
    laneColors[8] = [NSColor purpleColor];
    laneColors[9] = [NSColor blackColor];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    GECommit *commit = (GECommit*)self.objectValue;
    NSLog(@"Drawing in rect %@ for commit with index %d",NSStringFromRect(cellFrame),commit.index);
    NSColor *color = laneColors[commit.lane%laneColorsCount];
    [color set];
    int radius = 3;
    int x = 5+commit.lane*2*(radius+2);
    int y = 1+commit.index*20 + 9 - radius;
    NSLog(@"x=%d y=%d",x,y);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect:NSMakeRect(x, y, radius*2, radius*2)];
    for(GECommit *parentCommit in commit.parents){
        int parentX = 5+parentCommit.lane*2*(radius+2);
        int parentY = 1+parentCommit.index * 19 + 9 - radius;    
        NSLog(@"parentX=%d parentY=%d",parentX,parentY);    
        [path moveToPoint:NSMakePoint(x+radius, y+radius)];
        [path lineToPoint:NSMakePoint(parentX-radius, parentY-radius)];
    }
    [path stroke];
    //NSRectFill(cellFrame);
    //NSLog(@"%@",self.objectValue);
}

@end
