//
//  GECommitController.h
//  GitExtensions
//
//  Created by Cristian Kocza on 18.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GEGitRepository;

@interface GECommitController : NSWindowController{
    GEGitRepository *repository;
    NSMutableArray *unstagedFiles;
    NSMutableArray *stagedFiles;
    NSAttributedString *currentFileDiff;
    
    IBOutlet NSTableView *unstagedFilesTableView;
    IBOutlet NSTableView *stagedFilesTableView;
    IBOutlet NSArrayController *unstagedFilesController;
    IBOutlet NSArrayController *stagedFilesController;
}

@property(nonatomic,retain,readwrite) GEGitRepository *repository;
@property(nonatomic,retain,readwrite) NSAttributedString *currentFileDiff;

+ (id)controller;
- (void)showForRepository:(GEGitRepository*)aRepository;

- (IBAction)onUnstagedDblClick:(id)sender;
- (IBAction)onStagedDblClick:(id)sender;

@end
