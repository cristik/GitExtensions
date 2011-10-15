//
//  GEGraph.h
//  GitExtensions
//
//  Created by Cristian Kocza on 14.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GENode;
@class GELaneInfo;
@class GEJunction;
@class GEActiveLaneRow;
@class GEGraph;

@interface NSArray(DvcsGraph)
- (GEJunction*)junctionAtIndex:(NSUInteger)index;
- (GENode*)nodeAtIndex:(NSUInteger)index;
- (BOOL)any:(BOOL(^)(id obj))predicate;
- (int)aggregate:(int(^)(id obj))predicate;
@end

@protocol GELaneRow
@property(nonatomic,assign,readonly) int nodeLane;
@property(nonatomic,retain,readonly) GENode *node;
@property(nonatomic,assign,readonly) int count;
- (GELaneInfo*)laneInfoAtCol:(int)lane item:(int)item;
- (int)laneInfoCount:(int)lane;
@end

@interface GELaneInfo : NSObject {
@private
    int _connectLane;
    NSMutableArray *_junctions;
}

- (id)initWithConnectLane:(int)connectLane junction:(GEJunction*)junction;
@property(nonatomic,assign,readwrite) int connectLane;
@property(nonatomic,retain,readwrite) NSMutableArray *junctions;
- (id)clone;
- (id)unionWith:(GELaneInfo*)other;
@end

enum{
    GEDataTypeNormal = 0,
    GEDataTypeActive = 1,
    GEDataTypeSpecial = 2,
    GEDataTypeFiltered = 4
};
typedef NSUInteger GEDataType;

@interface GENode : NSObject {
@private
    NSMutableArray *_ancestors;
    NSMutableArray *_descendants;
    id _nodeId;
    id _data;
    GEDataType _dataType;
    int _inLane;
    int _index;
}

@property(nonatomic,retain,readwrite) NSMutableArray *ancestors;
@property(nonatomic,retain,readwrite) NSMutableArray *descendants;
@property(nonatomic,retain,readwrite) id nodeId;
@property(nonatomic,retain,readwrite) id data;
@property(nonatomic,assign,readwrite) GEDataType dataType;
@property(nonatomic,assign,readwrite) int inLane;
@property(nonatomic,assign,readwrite) int index;

@property(nonatomic,assign,readonly) BOOL isActive;
@property(nonatomic,assign,readwrite) BOOL isFiltered;
@property(nonatomic,assign,readonly) BOOL isSpecial;

@end

enum{
    GEJunctionStateUnprocessed = 0,
    GEJunctionStateProcessed = 1,
    GEJunctionStateProcessing = 2
};
typedef NSUInteger GEJunctionState;

@interface GEJunction : NSObject {
@private    
    NSMutableArray *_bunch;
    unsigned int _debugId;
    GEJunctionState _currentState;
    bool _isRelative;
}

@property(nonatomic,retain,readonly) NSMutableArray *bunch;
@property(nonatomic,assign,readwrite) GEJunctionState currentState;
@property(nonatomic,retain,readonly) GENode *child;
@property(nonatomic,retain,readonly) GENode *parent;

- (id)initWithNode:(GENode*)node parent:(GENode*)parent;
- (void)add:(GENode*)parent;
- (GEJunction*)split:(GENode*)node;
@end

@interface GELanes : NSObject{
@private
    GEActiveLaneRow *_currentRow;
    NSMutableArray *_laneNodes;
    NSMutableArray *_laneRows;
    GEGraph *_sourceGraph;
}

@property(nonatomic,assign,readwrite) int cachedCount;

- (id)initWithSourceGraph:(GEGraph*)graph;
- (void)removeAll;
- (BOOL)cacheToRow:(int)row;
@end

@interface GEGraph : NSObject{
@private
    NSMutableArray *_addedNodes;
    NSMutableArray *_junctions;
    NSDictionary *_nodes;
    GELanes *_lanes;
    int _filterNodeCount;
    
    BOOL _isFilter;
    int _nodeCount;
    int _processedNodes;
}

@property(nonatomic,retain,readwrite) NSArray *addedNodes;
@property(nonatomic,retain,readwrite) NSArray *junctions;
@property(nonatomic,retain,readwrite) NSDictionary *nodes;

@property(nonatomic,assign,readwrite) BOOL isFilter;
@property(nonatomic,assign,readonly) int count;

- (id<GELaneRow>)laneRowAtIndex:(NSUInteger)index;

@property(nonatomic,assign,readonly) int cachedCount;

- (void)filter:(id)anId;

- (void)add:(id)anId parentsIds:(NSArray*)parentIds type:(GEDataType)type data:(id)data;
@end
