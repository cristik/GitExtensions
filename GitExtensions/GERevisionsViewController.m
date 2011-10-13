//
//  GERevisionsViewController.m
//  GitExtensions
//
//  Created by Cristian Kocza on 13.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GERevisionsViewController.h"

@interface GERevisionsViewController()
- (id)init;
@end

@implementation GERevisionsViewController

+ (id)controller{
    return [[[self alloc] init] autorelease];
}

- (id)init{
    return [self initWithNibName:@"RevisionsView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc{
    [super dealloc];
}

@end
