//
//  GEMainWindowController.m
//  GitExtensions
//
//  Created by Cristian Kocza on 20.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GEMainWindowController.h"
#import "GitObjects.h"
#import "GECommitController.h"
#import "GEOperationResultController.h"
#import "Cocoa+GitExtensions.h"

@implementation GEMainWindowController

@synthesize repository;

- (void)awakeFromNib{
    branchesToolbarItem.view = branchesPopup;
    branchesToolbarItem.minSize = NSMakeSize(150, 20);
    branchesToolbarItem.maxSize = NSMakeSize(150, 20);
}

#pragma mark Actions
- (IBAction)onOpenRepository:(id)sender{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.canCreateDirectories = YES;
    [openPanel beginSheetModalForWindow:self.window completionHandler:^void(NSInteger result){
        if(result == NSFileHandlingPanelOKButton){
            [self.repository openRepository:openPanel.URL.path];
            [[NSUserDefaults standardUserDefaults] addRepositoryToLatest:openPanel.URL.path];
        }
    }];
}

- (IBAction)onRefresh:(id)sender{
    [self.repository reload];
}

- (IBAction)onCommit:(id)sender{
    GECommitController *controller = [GECommitController controller];
    [controller showForRepository:self.repository];
}

- (IBAction)onChangeBranch:(id)sender{
    NSString *branchName = [[sender selectedItem] title];
    GEBranch *branch = [self.repository branchNamed:branchName];
    [self.repository checkoutBranch:branch];
    [[GEOperationResultController controller] showForRepository:self.repository];
    [self.repository reloadBranches];
}

@end
