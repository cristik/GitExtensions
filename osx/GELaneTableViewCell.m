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
    laneColorsCount = 40;
    laneColors = (NSColor**)malloc(laneColorsCount*sizeof(NSColor*));
    laneColors[0] = [NSColor redColor];
    laneColors[1] = [NSColor blueColor];
    laneColors[2] = [NSColor greenColor];
    laneColors[3] = [NSColor orangeColor];
    laneColors[4] = [NSColor magentaColor];
    laneColors[5] = [NSColor grayColor];
    laneColors[6] = [NSColor cyanColor];
    laneColors[7] = [NSColor brownColor];
    laneColors[8] = [NSColor purpleColor];
    laneColors[9] = [NSColor blackColor];
    laneColors[10] = laneColors[0];
    laneColors[11] = laneColors[1];
    laneColors[12] = laneColors[2];
    laneColors[13] = laneColors[3];
    laneColors[14] = laneColors[4];
    laneColors[15] = laneColors[5];
    laneColors[16] = laneColors[6];
    laneColors[17] = laneColors[7];
    laneColors[18] = laneColors[8];
    laneColors[19] = laneColors[9];
    laneColors[20] = laneColors[0];
    laneColors[21] = laneColors[1];
    laneColors[22] = laneColors[2];
    laneColors[23] = laneColors[3];
    laneColors[24] = laneColors[4];
    laneColors[25] = laneColors[5];
    laneColors[26] = laneColors[6];
    laneColors[27] = laneColors[7];
    laneColors[28] = laneColors[8];
    laneColors[29] = laneColors[9];
    laneColors[30] = laneColors[0];
    laneColors[31] = laneColors[1];
    laneColors[32] = laneColors[2];
    laneColors[33] = laneColors[3];
    laneColors[34] = laneColors[4];
    laneColors[35] = laneColors[5];
    laneColors[36] = laneColors[6];
    laneColors[37] = laneColors[7];
    laneColors[38] = laneColors[8];
    laneColors[39] = laneColors[9];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    //NSLog(@"- (BOOL)isBezeled=%d",self.isBezeled);
    GECommit *commit = (GECommit*)self.objectValue;
    //NSLog(@"Drawing in rect %@ for commit with index %d",NSStringFromRect(cellFrame),commit.index);
    NSColor *color = laneColors[commit.lane%laneColorsCount];
    [color set];
    [color setFill];
    int radius = 3;
    int x = cellFrame.origin.x + 5 + commit.lane * 2 * (radius + 2);
    int y = cellFrame.origin.y + cellFrame.size.height / 2 - radius;
    //NSLog(@"x=%d y=%d",x,y);
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect:NSMakeRect(x, y, radius*2, radius*2)];
    [path fill];
    //NSLog(@"extraLanes: %@",commit.extraLanes);
    for(GECommit *parent in commit.parents){
        int laneTo = parent.lane>commit.lane?parent.lane:commit.lane;
        int xp = cellFrame.origin.x + 5 + laneTo * 2 * (radius + 2) + radius;
        [laneColors[laneTo%laneColorsCount] set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(x+radius, y+2*radius) toPoint:NSMakePoint(xp, NSMaxY(cellFrame))];
    }
    for(GECommit *child in commit.children){
        if(child.lane >= commit.lane){
            int xc = cellFrame.origin.x + 5 + child.lane * 2 * (radius + 2) + radius;
            [laneColors[child.lane%laneColorsCount] set];
            [NSBezierPath strokeLineFromPoint:NSMakePoint(x+radius, y) toPoint:NSMakePoint(xc, NSMinY(cellFrame))];
        }else{
            int xc = cellFrame.origin.x + 5 + commit.lane * 2 * (radius + 2) + radius;
            [laneColors[commit.lane%laneColorsCount] set];
            [NSBezierPath strokeLineFromPoint:NSMakePoint(x+radius, y) toPoint:NSMakePoint(xc, NSMinY(cellFrame))];            
        }
    }
    for(NSNumber *extraLane in commit.extraLanes){        
        int x = cellFrame.origin.x + 5 + [extraLane intValue] * 2 * (radius + 2) + radius;
        [laneColors[[extraLane intValue]%laneColorsCount] set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(x, cellFrame.origin.y) toPoint:NSMakePoint(x, NSMaxY(cellFrame))];
    }
    
    //NSRectFill(cellFrame);
    //NSLog(@"%@",self.objectValue);
}

@end
