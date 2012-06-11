//
//  GECommitController.m
//  GitExtensions
//
//  Created by Cristian Kocza on 18.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GECommitController.h"
#import "GEObjects.h"

@implementation GECommitController

@synthesize repository, currentFileDiff;

+ (id)controller{
    return [[[self alloc] initWithWindowNibName:@"Commit"] autorelease];
}

- (void)updateFiles{
    [self willChangeValueForKey:@"unstagedFiles"];
    [self willChangeValueForKey:@"stagedFiles"];
    if(stagedFiles == nil)
        stagedFiles = [[NSMutableArray alloc] init];
    else
        [stagedFiles removeAllObjects];
    if(unstagedFiles == nil)
        unstagedFiles = [[NSMutableArray alloc] init];
    else
        [unstagedFiles removeAllObjects];
    NSArray *filesStatus = [self.repository retrieveStatus];
    for(GERepositoryFile *fileInfo in filesStatus){        
        if(fileInfo.workTreeStatus != GEFileStatusUnmodified)
            [unstagedFiles addObject:fileInfo];
        if(fileInfo.indexStatus != GEFileStatusUnmodified)
            [stagedFiles addObject:fileInfo];
    }
    [self didChangeValueForKey:@"unstagedFiles"];
    [self didChangeValueForKey:@"stagedFiles"];
}

- (void)windowDidLoad{
    [super windowDidLoad];
    
    [unstagedFilesTableView setDoubleAction:@selector(onUnstagedDblClick:)];
    [unstagedFilesTableView setTarget:self];
    [unstagedFilesController addObserver:self forKeyPath:@"selectedObjects" options:0 context:nil];
    
    [stagedFilesTableView setDoubleAction:@selector(onStagedDblClick:)];
    [stagedFilesTableView setTarget:self];
    [stagedFilesController addObserver:self forKeyPath:@"selectedObjects" options:0 context:nil];
    
    [self updateFiles];
}

- (NSAttributedString*)attributedStringForDiff:(NSString*)diff{
    NSMutableAttributedString *result = [[[NSMutableAttributedString alloc] init] autorelease];
    NSArray *lines = [diff componentsSeparatedByString:@"\n"];
    NSMutableDictionary *defaultAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"System", NSFontFamilyAttribute, nil];
    NSMutableDictionary *greenAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSColor colorWithCalibratedRed:0.78 green:1.0 blue:0.78 alpha:1.0], NSBackgroundColorAttributeName,
                                            @"System", NSFontFamilyAttribute,nil];
    NSMutableDictionary *redAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSColor colorWithCalibratedRed:1.0 green:0.78 blue:0.78 alpha:1.0], NSBackgroundColorAttributeName,
                                          @"System", NSFontFamilyAttribute,nil];    
    for(NSString *line in lines){
        line = [line stringByAppendingString:@"\n"];
        NSDictionary *attributes = nil;
        switch([line characterAtIndex:0]){
            case '+': attributes = greenAttributes; break;
            case '-': attributes = redAttributes; break;        
            default: attributes = defaultAttributes; break;
        }
        [result appendAttributedString:[[[NSAttributedString alloc] initWithString:line attributes:attributes] autorelease]];
    }
    return result;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqual:@"selectedObjects"]){
        GERepositoryFile *fileInfo = [object selectedObjects].lastObject;
        NSString *diff = nil;
        if(object == unstagedFilesController)
            diff = fileInfo.workTreeDiff;
        else if(object ==  stagedFilesController)
            diff = fileInfo.indexDiff;
        if(diff)
            self.currentFileDiff = [self attributedStringForDiff:diff];
    }
}

- (void)showForRepository:(GEGitRepository*)aRepository{
    self.repository = aRepository;
    [self updateFiles];
    [NSApp runModalForWindow:self.window];   
}

- (void)windowWillClose:(NSNotification*)aNotif{
    [NSApp stopModal];
}

- (IBAction)onUnstagedDblClick:(id)sender{
    GERepositoryFile *fileInfo = unstagedFilesController.selectedObjects.lastObject;
    if(fileInfo != nil){
        [self.repository stageFile:fileInfo];
        [self updateFiles];
    }
}

- (IBAction)onStagedDblClick:(id)sender{
    GERepositoryFile *fileInfo = stagedFilesController.selectedObjects.lastObject;
    if(fileInfo != nil){
        [self.repository unstageFile:fileInfo];
        [self updateFiles];
    }
}
@end
