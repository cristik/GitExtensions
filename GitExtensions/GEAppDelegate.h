//
//  GEAppDelegate.h
//  GitExtensions
//
//  Created by Cristian Kocza on 18.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GEGitRepository;

@interface GEAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet GEGitRepository *repository;

- (IBAction)onOpenRepository:(id)sender;
- (IBAction)onCommit:(id)sender;

@end
