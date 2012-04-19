//
//  GECommit.h
//  GitExtensions
//
//  Created by Cristian Kocza on 18.04.2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GECommit : NSObject{
    @private
    NSString *sha1;    
    NSArray *parents;
    NSString *author;
    NSString *authorDate;
    NSString *commiter;
    NSString *commitDate;
    NSString *subject;    
    NSString *message;
}

@property(nonatomic,retain,readonly) NSString *sha1;    
@property(nonatomic,retain,readonly) NSArray *parents;
@property(nonatomic,retain,readonly) NSString *author;
@property(nonatomic,retain,readonly) NSString *authorDate;
@property(nonatomic,retain,readonly) NSString *commiter;
@property(nonatomic,retain,readonly) NSString *commitDate;
@property(nonatomic,retain,readonly) NSString *subject;
@property(nonatomic,retain,readonly) NSString *message;

+ (id)commitWithLines:(NSArray*)lines index:(int*)index;
- (id)initWithLines:(NSArray*)lines index:(int*)index;
@end
