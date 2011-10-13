//
//  GEImageView.m
//  GitExtensions
//
//  Created by Cristian Kocza on 13.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GEImageView.h"


@implementation GEImageView

- (void)awakeFromNib{
    self.image = self.image;
}

- (void)setImage:(NSImage *)newImage{
    [super setImage:newImage];
    NSArray *representations = [newImage representations];
    [_bitmapRep release];
    _bitmapRep = nil;
    for(id rep in representations){
        if([rep isKindOfClass:[NSBitmapImageRep class]]){
            _bitmapRep = rep;
            break;
        }
    }
    _frameCount = [[_bitmapRep valueForProperty:NSImageFrameCount] intValue];
    if(_frameCount > 1){
        double frameDuration = [[_bitmapRep valueForProperty:NSImageCurrentFrameDuration] doubleValue];
        [_bitmapRep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithInt:_currentFrame = 0]];
        
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:frameDuration target:self selector:@selector(nextFrame:) userInfo:nil repeats:YES];
    }else{
        [_animationTimer invalidate];
        [_animationTimer release];
        _animationTimer = nil;
        [_bitmapRep release];
        _bitmapRep = nil;
    }
}

- (void)dealloc{
    [_animationTimer invalidate];
    [_animationTimer release];
    [super dealloc];
}

- (void)nextFrame:(NSTimer*)sender{
    _currentFrame = (_currentFrame + 1) % _frameCount;
    [_bitmapRep setProperty:NSImageCurrentFrame withValue:[NSNumber numberWithInt:_currentFrame]];
    [self setNeedsDisplay];
}
@end
