//
//  GEJunction.m
//  GitExtensions
//
//  Created by Cristian Kocza on 14.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GEGraph.h"

@implementation GEJunction

static unsigned int junctionDebugIdNext;

@synthesize currentState = _currentState;
@synthesize bunch = _bunch;

- (id)initWithNode:(GENode*)node parent:(GENode*)parent{
    if((self == [super init])){
        junctionDebugIdNext++;
        
        _bunch = [[NSMutableArray arrayWithObject:node] retain];
        if(node != parent){
            [node.ancestors addObject:self];
            [parent.descendants addObject:self];
            [_bunch addObject:parent];
        }
    }
    return self;
}

- (id)initWithDescendant:(GEJunction*)descendant node:(GENode*)node{
    //private initializer used by split. This junction will be an
    //ancestor of an existing junction
    if((self == [super init])){
        junctionDebugIdNext++;
        [node.ancestors removeObject:descendant];
        [_bunch addObject:node];
    }
    return self;
}

- (GENode*)child{
    return [_bunch objectAtIndex:0];
}

- (GENode*)parent{
    return [_bunch objectAtIndex:_bunch.count-1];
}

- (void)add:(GENode *)parentNode{
    [parentNode.descendants addObject:self];
    [self.parent.ancestors addObject:self];
    [_bunch addObject:parentNode];
}

- (GEJunction*)split:(GENode*)splitNode{
    //The 'top' (child.node) of the junction is retained by this.
    //The 'bottom' (node.parent) of the junction is returned
    NSUInteger index = [_bunch indexOfObject:splitNode];
    if(index == NSNotFound)
        return nil;
    GEJunction *bottom = [[[GEJunction alloc] initWithDescendant:self node:splitNode] autorelease];
    //Add 1, since node was at the index
    index += 1;
    while(_bunch.count > index){
        GENode *node = [_bunch objectAtIndex:index];
        [_bunch removeObjectAtIndex:index];
        [node.ancestors removeObject:self];
        [node.descendants removeObject:self];
        [bottom add:node];
    }
    return bottom;
}

- (NSString*)description{
    return [NSString stringWithFormat:@"%@: %@--(%@)--%@",_debugId, self.child, _bunch.count, self.parent];
}
@end