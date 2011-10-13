//
//  GEMainWindowController.h
//  GitExtensions
//
//  Created by Cristian Kocza on 13.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GERevisionsViewController.h"

@interface GEMainWindowController : NSWindowController {
@public
    IBOutlet NSSplitView *_mainSplitView;
@private
    GERevisionsViewController *_revisionsViewController;
}

@end
