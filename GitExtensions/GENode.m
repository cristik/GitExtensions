//
//  GENode.m
//  GitExtensions
//
//  Created by Cristian Kocza on 14.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GEGraph.h"

@implementation GENode

@synthesize ancestors = _ancestors;
@synthesize descendants = _descendants;
@synthesize nodeId = _nodeId;
@synthesize data = _data;
@synthesize dataType = _dataType;
@synthesize inLane = _inLane;
@synthesize index = _index;

- (id)initWithId:(id)nodeId{
    if((self = [super init])){
        _nodeId = [nodeId retain];
        _ancestors = [[NSMutableArray alloc] init];
        _descendants = [[NSMutableArray alloc] init];
        _inLane = INT_MAX;
        _index = INT_MAX;
    }
    return self;
}

- (BOOL)isActive{
    return (_dataType & GEDataTypeActive) == GEDataTypeActive;
}

- (BOOL)isFiltered{
    return (_dataType & GEDataTypeFiltered) == GEDataTypeFiltered;
}

- (void)setIsFiltered:(BOOL)isFiltered{
    if(isFiltered)
        _dataType |= GEDataTypeFiltered;
    else
        _dataType &= ~GEDataTypeFiltered;
}

- (BOOL)isSpecial{
    return (_dataType & GEDataTypeSpecial) == GEDataTypeSpecial;
}

- (NSString*)description{
    if(_data == nil){
        NSString *name = [_nodeId description];
        if(name.length > 8)
            name = [NSString stringWithFormat:@"%@..%@",
                    [name substringWithRange:NSMakeRange(0, 4)],
                    [name substringWithRange:NSMakeRange(name.length-4, 4)]];
        return [NSString stringWithFormat:@"%@ (%@)", name, _index];
    }else{
        return [_data description];
    }
}

- (GEJunction*)ancestorAtIndex:(NSUInteger)index{
    return [_ancestors objectAtIndex:index];
}

- (GEJunction*)descendantAtIndex:(NSUInteger)index{
    return [_descendants objectAtIndex:index];
}

- (void)addAncestor:(GEJunction*)ancestor{
    [_ancestors addObject:ancestor];
}

- (void)addDescendant:(GEJunction*)descendant{
    [_descendants addObject:descendant];
}

- (void)removeAncestor:(GEJunction*)ancestor{
    [_ancestors removeObject:ancestor];
}

- (void)removeDescendant:(GEJunction*)descendant{
    [_descendants removeObject:descendant];
}
@end