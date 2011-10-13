//
//  GEMainWindowController.m
//  GitExtensions
//
//  Created by Cristian Kocza on 13.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GEMainWindowController.h"


@implementation GEMainWindowController

- (id)init{
    if((self = [super init])){
        _revisionsViewController = [[GERevisionsViewController controller] retain];
    }
    return self;
}


- (void)dealloc{
    [super dealloc];
}

- (void)awakeFromNib{
    NSView *view = [[_mainSplitView subviews] objectAtIndex:0];
    [view addSubview:_revisionsViewController.view];
    [_revisionsViewController.view setFrame:view.bounds];
    [_revisionsViewController.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
}

@end
