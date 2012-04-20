//
//  GEOperationResultController.h
//  GitExtensions
//
//  Created by Cristian Kocza on 20.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GEGitRepository;
@interface GEOperationResultController : NSWindowController{
    GEGitRepository *repository;
    IBOutlet NSTextView *errorTextView;
}
@property(nonatomic,retain,readwrite) GEGitRepository *repository;

+ (id)controller;
- (void)showForRepository:(GEGitRepository*)aRepository;
@end
