//
//  GEAppDelegate.m
//  GitExtensions
//
//  Created by Cristian Kocza on 18.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GEAppDelegate.h"
#import "GitObjects.h"
#import "GECommitController.h"

@implementation GEAppDelegate

@synthesize window = _window;
@synthesize repository;

- (void)dealloc{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    // Insert code here to initialize your application
}

- (IBAction)onOpenRepository:(id)sender{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.canCreateDirectories = YES;
    [openPanel beginSheetModalForWindow:self.window completionHandler:^void(NSInteger result){
        if(result == NSFileHandlingPanelOKButton){
            [self.repository openRepository:openPanel.URL.path];
        }
    }];
}

- (IBAction)onCommit:(id)sender{
    GECommitController *controller = [GECommitController controller];
    controller.repository = self.repository;
    [controller show];
}

@end
