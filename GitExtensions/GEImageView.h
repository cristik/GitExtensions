//
//  GEImageView.h
//  GitExtensions
//
//  Created by Cristian Kocza on 13.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GEImageView : NSImageView {
@private
    NSTimer *_animationTimer;
    int _frameCount;
    int _currentFrame;
    NSBitmapImageRep *_bitmapRep;
}

@end
