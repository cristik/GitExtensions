//
//  GELaneTableViewCell.m
//  GitExtensions
//
//  Created by Cristian Kocza on 10/19/12.
//
//

#import "GELaneTableViewCell.h"
#import "GEObjects.h"
#import "Cocoa+GitExtensions.h"

@implementation GELaneTableViewCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    GECommit *commit = (GECommit*)self.objectValue;
    NSColor *color = [NSColor colorForLane:commit.lane];
    [color set];
    [color setFill];
    int radius = 4;
    int lineWidth = 2;
    int x = cellFrame.origin.x + 5 + commit.lane * 2 * (radius + 2);
    int y = cellFrame.origin.y + cellFrame.size.height / 2 - radius;
    
    [NSBezierPath setDefaultLineWidth:lineWidth];
    NSBezierPath *path = [NSBezierPath bezierPath];
    if([commit.repository branchesHashed:commit.sha1].count > 0){
        [path appendBezierPathWithRect:NSMakeRect(x, y, radius*2, radius*2)];
    }else{
        [path appendBezierPathWithOvalInRect:NSMakeRect(x, y, radius*2, radius*2)];   
    }
    
    [path fill];
    for(GECommit *parent in commit.parents){
        int laneTo = parent.lane>commit.lane?parent.lane:commit.lane;
        int xp = cellFrame.origin.x + 5 + laneTo * 2 * (radius + 2) + radius;
        [[NSColor colorForLane:laneTo] set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(x+radius, y+2*radius) toPoint:NSMakePoint(xp, NSMaxY(cellFrame))];
    }
    for(GECommit *child in commit.children){
        if(child.lane >= commit.lane){
            int xc = cellFrame.origin.x + 5 + child.lane * 2 * (radius + 2) + radius;
            [[NSColor colorForLane:child.lane] set];
            [NSBezierPath strokeLineFromPoint:NSMakePoint(x+radius, y) toPoint:NSMakePoint(xc, NSMinY(cellFrame))];
        }else{
            int xc = cellFrame.origin.x + 5 + commit.lane * 2 * (radius + 2) + radius;
            [[NSColor colorForLane:commit.lane] set];
            [NSBezierPath strokeLineFromPoint:NSMakePoint(x+radius, y) toPoint:NSMakePoint(xc, NSMinY(cellFrame))];            
        }
    }
    for(NSNumber *extraLane in commit.extraLanes){        
        int x = cellFrame.origin.x + 5 + [extraLane intValue] * 2 * (radius + 2) + radius;
        [[NSColor colorForLane:[extraLane intValue]] set];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(x, cellFrame.origin.y) toPoint:NSMakePoint(x, NSMaxY(cellFrame))];
    }
}

@end
