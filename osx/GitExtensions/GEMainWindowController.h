//
//  GEMainWindowController.h
//  GitExtensions
//
//  Created by Cristian Kocza on 20.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "GitObjects.h"

@class GEGitRepository;

@interface GEMainWindowController : NSWindowController{
    CGitRepository *gitRepository;
    IBOutlet GEGitRepository *repository;
    IBOutlet NSToolbarItem *branchesToolbarItem;
    IBOutlet NSPopUpButton *branchesPopup;
    IBOutlet NSTableColumn *laneColumn;
    IBOutlet NSArrayController *commitsController;
}

@property(nonatomic,assign,readwrite) GEGitRepository *repository;

- (IBAction)onOpenRepository:(id)sender;
- (IBAction)onRefresh:(id)sender;
- (IBAction)onCommit:(id)sender;
- (IBAction)onChangeBranch:(id)sender;

@end
