//
//  GEOperationResultController.m
//  GitExtensions
//
//  Created by Cristian Kocza on 20.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GEOperationResultController.h"
#import "GitObjects.h"

@implementation GEOperationResultController

@synthesize repository;

+ (id)controller{
    return [[[self alloc] initWithWindowNibName:@"OperationResult"] autorelease];
}

- (void)windowDidLoad{
    [errorTextView setString:self.repository.latestOutput];
    [errorTextView setEditable:NO];    
}

- (void)showForRepository:(GEGitRepository*)aRepository{
    self.repository = aRepository;
    if(self.repository.latestExitCode){
        [errorTextView setString:self.repository.latestOutput];
        [errorTextView setEditable:NO];
        [NSApp runModalForWindow:self.window];
    }
}

- (void)windowWillClose:(NSNotification*)aNotif{
    [NSApp stopModal];
}

@end
