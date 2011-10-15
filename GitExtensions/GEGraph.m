//
//  GEGraph.m
//  GitExtensions
//
//  Created by Cristian Kocza on 14.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GEGraph.h"

@implementation NSArray(DvcsGraph)
- (GEJunction*)junctionAtIndex:(NSUInteger)index{
    return (GEJunction*)[self objectAtIndex:index];
}

- (GENode*)nodeAtIndex:(NSUInteger)index{
    return (GENode*)[self objectAtIndex:index];
}

- (BOOL)any:(BOOL(^)(id obj))predicate{
    return [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
        *stop = predicate(obj);
        return *stop;
    }] != NSNotFound;
}

- (int)aggregate:(int(^)(id obj))predicate{
    int result = 0;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        result += predicate(obj);
        *stop = false;
    }];
    return result;
}
@end

@implementation GEGraph

@synthesize addedNodes = _addedNodes;
@synthesize junctions = _junctions;
@synthesize nodes = _nodes;

- (id)init{
    if((self = [super init])){
        _lanes = [[GELanes alloc] initWithSourceGraph:self];
    }
    return self;
}

- (void)dealloc{
    [_lanes release];
    [super dealloc];
}

#pragma mark Properties

- (BOOL)isFilter{
    return _isFilter;
}

- (void)setIsFilter:(BOOL)isFilter{
    _isFilter = isFilter;
    [_lanes removeAllObjects];
    for(GENode *n in [_nodes allValues]){
        n.inLane = INT_MAX;
    }
    for(GEJunction *j in _junctions){
        j.currentState = GEJunctionStateUnprocessed;
    }
    [self notifyUpdated];
}

- (int)count{
    if(self.isFilter)
        return _filterNodeCount;
    return _nodeCount;
}

- (id<GELaneRow>)laneRowAtIndex:(NSUInteger)index{
    return [_lanes objectAtIndex:index];
}

- (int)cachedCount{
    return _lanes.cachedCount;
}

#pragma mark Utils

- (void)filter:(id)anId{
    GENode *node = [_nodes objectForKey:anId];
    if(!node.isFiltered){
        _filterNodeCount++;
        node.isFiltered = YES;
    }
    //comments not copied from Windows source
}

- (void)add:(id)anId parentsIds:(NSArray*)parentIds type:(GEDataType)type data:(id)data{
    //if we haven't seen this node yet, create a new junction
    GENode *node = nil;
    if(![self getNode:anId node:&node] && parentIds.count == 0){
        GEJunction *newJunction = [[[GEJunction alloc] initWithNode:node parent:node] autorelease];
        [_junctions addObject:newJunction];
    }
    _nodeCount++;
    node.data = data;
    node.dataType = type;
    node.index = _addedNodes.count;
    [_addedNodes addObject:node];
    
    for(id parentId in parentIds){
        GENode *parent;
        [self getNode:parentId node:&parent];
        if(parent.index < node.index){
            //Windows comments says that we might be able to recover from this
            //TODO: investigate it
            continue;
        }
        
        if(node.descendants.count == 1 && node.ancestors.count <= 1 &&
           ((GEJunction*)[node.descendants objectAtIndex:0]).parent == node && parent.ancestors.count == 0 &&
           //If this is true, the current revision is in the middle of a branch
           //and is about to start a new branch. This will also mean that the last
           //revisions are non-relative. Make sure a new junction is added and this
           //is the start of a new branch (and color!)
           (type & GEDataTypeActive) != GEDataTypeActive){
            //the node isn't a junction point. Just the parent to the node's
            // (only) ancestor junction.
            [((GEJunction*)[node.descendants objectAtIndex:0]) add:parent];
        }else if(node.ancestors.count == 1 && ((GEJunction*)[node.ancestors objectAtIndex:0]).child != node){
            //the node is in the middle of a junction. we need to split it.
            GEJunction *splitNode = [((GEJunction*)[node.ancestors objectAtIndex:0]) split:node];
            [_junctions addObject:splitNode];
            
            //the node is a junction point. We are a new junction.
            GEJunction *junction = [[[GEJunction alloc] initWithNode:node parent:parent] autorelease];
            [_junctions addObject:junction];
        }else if(parent.descendants.count == 1 && ((GEJunction*)[parent.descendants objectAtIndex:0]).parent != parent){
            //the parent is in the middle of a junction. we need to split it
            GEJunction *splitNode = [((GEJunction*)[parent.descendants objectAtIndex:0]) split:parent];
            [_junctions addObject:splitNode];
            
            //the node is a junction point. we are a new junction
            GEJunction *junction = [[[GEJunction alloc] initWithNode:node parent:parent] autorelease];
            [_junctions addObject:junction];
        }else{
            //the node is a junction point. we are a new junction
            GEJunction *junction = [[[GEJunction alloc] initWithNode:node parent:parent] autorelease];
            [_junctions addObject:junction];
        }
    }
    
    BOOL isRelative = (type & GEDataTypeActive) == GEDataTypeActive;
    if(!isRelative && [node.descendants indexOfObjectPassingTest:^(GEJunction *junction, NSUInteger idx, BOOL *stop) {*stop = junction.isRelative;}] != NSNotFound){
        isRelative = YES;
    }
    
    BOOL isRebuild = NO;
    for(GEJunction *d in node.ancestors){
        d.isRelative = isRelative || d.isRelative;
        
        //Uh, oh, we;ve already processed this lane. We'll have to update some rows
        int idx = [d.bunch indexOfObject:node];
        if(idx < d.bunch.count && ((GENode*)[d.bunch objectAtIndex:idx+1]).inLane != INT_MAX){
            int resetTo = d.parent.descendants
        }
    }
}
@end

@implementation GELaneInfo

- (id)initWithConnectLane:(int)connectLane junction:(GEJunction*)junction{
    if((self = [super init])){
        _connectLane = connectLane;
        _junctions = [[NSMutableArray alloc] initWithObjects:junction,nil];
    }
    return self;
}

@synthesize connectLane = _connectLane;
@synthesize junctions = _junctions;
- (id)clone{
    GELaneInfo *result = [[[GELaneInfo alloc] init] autorelease];
    result->_connectLane = _connectLane;
    result->_junctions = [[NSMutableArray alloc] initWithArray:_junctions];
    return result;
}

- (id)unionWith:(GELaneInfo*)other{
    for(GEJunction *junction in other->_junctions){
        if(![_junctions containsObject:junction])
            [_junctions addObject:junction];
    }
}

- (int)intValue{
    return _connectLane;
}

- (NSString*)description{
    return [NSString stringWithFormat:@"%d",_connectLane];
}
@end
