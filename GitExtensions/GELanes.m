//
//  GELanes.m
//  GitExtensions
//
//  Created by Cristian Kocza on 14.10.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GEGraph.h"

@class GEEdges;

@interface GELaneJunctionDetail : NSObject {
@private
    int _index;
    GEJunction *_junction;
    GENode *_node;
}
- (id)initWithNode:(GENode*)node;
- (id)initWithJunction:(GEJunction*)junction;
@property(nonatomic,assign,readonly) int count;
@property(nonatomic,retain,readonly) GEJunction *junction;
@property(nonatomic,retain,readonly) GENode *current;
@property(nonatomic,assign,readonly) BOOL isClear;
- (void)clear;
- (GENode*)next;
@end

@interface GEActiveLaneRow : NSObject<GELaneRow>{
@private
    GEEdges *_edges;
    GENode *_node;
    int _nodeLane;
}
@property(nonatomic,assign,readwrite) int nodeLane;
@property(nonatomic,retain,readwrite) GENode *node;
- (NSArray*)edgeList;
- (void)add:(int)lane data:(GELaneInfo*)data;
- (void)clear;
- (void)clear:(int)lane;
- (void)collapse:(int)col;
- (void)replace:(int)old new:(int)new;
- (void)swap:(int)old new:(int)new;
- (id<GELaneRow>)advance;
@end

@interface GESavedLaneRow : NSObject<GELaneRow>{
@private
    NSArray *_edges;
    GENode *_node;
    int _nodeLane;
}

- (id)initWithNode:(GENode*)node;
- (id)initWithActiveRow:(GEActiveLaneRow*)activeRow;
@end

@interface GELanes()
- (BOOL)moveNext;
@end

@implementation GELanes

- (id)initWithSourceGraph:(GEGraph*)graph{
    if((self = [super init])){
        _sourceGraph = graph;
        //rebuild all lanes
        _laneRows = [[NSMutableArray alloc] init];
    }
    return self;    
}

- (id<GELaneRow>)laneRowAtIndex:(NSUInteger)index{
    if((int)index < 0)
        return nil;
    if(index < _laneRows.count)
        return [_laneRows objectAtIndex:index];
    if(index < _sourceGraph.addedNodes.count)
        return [[[GESavedLaneRow alloc] initWithNode:[_sourceGraph.addedNodes objectAtIndex:index]] autorelease];
    return nil;
}

- (int)count{
    return _sourceGraph.count;
}

- (int)cachedCount{
    return (int)_laneRows.count;
}

- (void)clear{
    [_laneRows removeAllObjects];
    [_laneNodes removeAllObjects];
    [_currentRow clear];
    
    for(GENode *node in _sourceGraph.heads){
        if(node.descendants.count == 0){
            //this node is a head, create a new lane for it
            GENode *h = node;
            if(h.ancestors.count == 0){
                //this is a single entry with no parents or children.
                GELaneJunctionDetail *detail = [[[GELaneJunctionDetail alloc] initWithNode:h] autorelease];
                [_laneNodes addObject:detail];
            }else{
                for(GEJunction *j in h.ancestors){
                    GELaneJunctionDetail *detail = [[[GELaneJunctionDetail alloc] initWithJunction:j] autorelease];
                    [_laneNodes addObject:detail];                    
                }
            }
        }
    }
}

- (BOOL)cacheToRow:(int)row{
    BOOL isValid = YES;
    while(isValid && row >= self.cachedCount){
        isValid = [self moveNext];
    }
    return isValid;
}

- (void)updateWithNode:(GENode*)node{
    if(node.descendants.count == 0){
        //this node is a head, create a new lane for it
        if(h.ancestors.count == 0){
            //this is a single entry with no parents or children.
            GELaneJunctionDetail *detail = [[[GELaneJunctionDetail alloc] initWithNode:h] autorelease];
            [_laneNodes addObject:detail];
        }else{
            for(GEJunction *j in h.ancestors){
                GELaneJunctionDetail *detail = [[[GELaneJunctionDetail alloc] initWithJunction:j] autorelease];
                [_laneNodes addObject:detail];                    
            }
        }
    }
}

- (BOOL)moveNext{
    //if there are no lanes, there is nothing more to draw
    if(_laneNodes.count == 0 || _sourceGraph.count <= _laneRows.count)
        return false;
    
    //find the new current row's node (newest item in the row)
    _currentRow.node = nil;
    for(int curLane = 0; curLane < _laneNodes.count; curLane++){
        GELaneJunctionDetail *lane = [_laneNodes objectAtIndex:curLane];
        if(lane.count == 0)
            continue;
    }
}
@end

@implementation GELaneJunctionDetail

- (id)initWithNode:(GENode*)node{
    if((self == [super init])){
        _node = [node retain];
    }
    return self;
}

- (id)initWithJunction:(GEJunction*)junction{
    if((self == [super init])){
        _junction = [junction retain];
        _junction.currentState = GEJunctionStateProcessing;
    }
    return self;
}

- (int)count{
    if(_node != nil)
        return 1 - _index;
    else if (_junction == nil)
        return 0;
    else
        return _junction.bunch.count - _index;
}

@synthesize junction = _junction;

- (GENode*)current{
    if(_node != nil)
        return _node;
    else if(_index < _junction.bunch.count)
        return [_junction.bunch objectAtIndex:_index];
    else
        return nil;
}

- (BOOL)isClear{
    return _junction == nil && _node == nil;
}

- (void)clear{
    [_node release];
    _node = nil;
    [_junction release];
    _junction = nil;
    _index = 0;
}

- (GENode*)next{
    GENode *n;
    if(_node != nil)
        n = _node;
    else
        n = [_junction.bunch objectAtIndex:_index];
    _index++;
    if(_junction != nil && _index >= _junction.bunch.count)
        _junction.currentState = GEJunctionStateProcessed;
    return n;
}

@end

@interface GEEdge : NSObject {
@private
    int _start;
    GELaneInfo *_data;
}
@property(nonatomic,assign,readwrite) int start;
@property(nonatomic,retain,readwrite) GELaneInfo *data;
@property(nonatomic,assign,readonly) int end;
- (id)initWithData:(GELaneInfo*)data start:(int)start;
@end

@interface GEEdges : NSObject{
@private
    NSMutableArray *_countEnd;
    NSMutableArray *_countStart;
    NSMutableArray *_edges;
    GELaneInfo *emptyItem;
}
@property(nonatomic,retain,readonly) NSArray *edgeList;
- (void)current:(int)lane item:(int)item;
- (void)next:(int)lane item:(int)item;
@end

@implementation GEActiveLaneRow

- (NSArray*)edgeList{
    return _edges.edgeList;
}

@synthesize nodeLane = _nodeLane;
@synthesize node = _node;

- (int)count{
    return [_edges countCurrent];
}

- (int)laneInfoCount:(int)lane{
    return [_edges countCurrent:lane];
}
- (GELaneInfo*)laneInfoAtCol:(NSUInteger)col row:(NSUInteger)row{
    return [_edges current:col row:row];
}

- (void)add:(int)lane data:(GELaneInfo*)data{
    [_edges add:lane data:data];
}

- (void)clear{
    [_edges release];
    _edges = [[GEEdges alloc] init];
}

- (void)clear:(int)lane{
    [_edges clear:lane];
}

- (void)collapse:(int)col{
    int edgeCount = MAX([_edges countCurrent], [_edges countNext]);
    for(int i=col; i<edgeCount; i++){
        while([_edges countNext:i] > 0){
            int start, end;
            GELaneInfo *info = [_edges removeNextForLane:i item:0 start:&start end:&end];
            info.connectLane--;
            [_edges addFrom:start data:info];
        }
    }
}

- (void)expand:(int)col{
    int edgeCount = MAX([_edges countCurrent], [_edges countNext]);
    for(int i=edgeCount-1; i >= col; --i){
        while([_edges countNext:i] > 0){
            int start, end;
            GELaneInfo *info = [_edges removeNextForLane:i item:0 start:&start end:&end];
            info.connectLane++;
            [_edges add:start data:info];
        }
    }
}

- (void)replace:(int)old new:(int)new{
    for(int j=[_edges countNextForLane:old]; --j){
        int start, end;
        GELaneInfo *info = [_edge removeNextForLane:old item:j start:&start end:&end];
        info.connectLane = new;
        [_edges add:start data:info];
    }
}

- (void)swap:(int)old new:(int)new{
    int temp = [_edges countNext];
    [self replace:old new:temp];
    [self replace:new new:old];
    [self replace:temp new:new];
}

- (GELaneRow*)advance{
    GESavedLineRow *newLanreRow = [[[GESavedLineRow alloc] initWithLanes:self] autorelease];
    GEEdges *newEdges = [[[GEEdges alloc] init] autorelease];
    for(int i=0; i<[_edges countNext]; i++){
        int edgeCount = [_edges countNext:i];
    }
}
@end

@implementation GESavedLaneRow

- (id)initWithNode:(GENode*)node{
    if((self = [super init])){
        _node = [node retain];
        _nodeLane = -1;
        _edges = nil;
    }
}

- (id)initWithActiveRow:(GEActiveLaneRow*)activeRow{
    if((self = [super init])){
        _nodeLane = activeRow.nodeLane;
        _node = [_activeRow.node retain];
        _edges = [activeRow.edgeList retain];
    }
}

@synthesize nodeLane = _nodeLane;
@synthesize node = _node;

- (GELaneInfo*)laneInfoAtCol:(NSUInteger)col row:(NSUInteger)row{
    int count = 0;
    for(GEEdge *edge in _edges){
        if(edge.start == col){
            if(count == row)
                return edge.data;
            count++;
        }
    }
    //TODO: throw an exception like on windows
    return nil;
}

- (int)count{
    if(_edges == nil)
        return 0;
    int count = -1;
    for(GEEdge *edge in _edges){
        if(edge.start > count)
            count += edge.start;
    }
    return count+1;
}

- (int)laneInfoCount:(int)lane{
    int count = 0;
    for(GEEdge *edge in _edges){
        if(edge.start == lane)
            count++;
    }
    return count;
}

- (NSString*)description{
    NSMutableString *s = [NSMutableString stringWithFormat:@"%d/%d:",_nodeLane,self.count];
    for(int i=0; i<count; i++){
        if(i == _nodeLane)
            [s appendString:@"*"];
        [s appendString:@"{"];
        for(int j=0; j<self.laneInfoCount; j++)
            [s appendFormat:@" %@",[self laneInfoAtCol:i row:j]];
        [s appendString:@" }, "];
    }
    [s appendFormat:@"%@",_node];
    return [s description];
}

@end

@implementation GEEdges

@synthesize edgeList = _edges;

- (void)current:(int)lane item:(int)item{
    int found = 0;
    for(GEEdge *e in _edges){
        if(e.start == lane){
            if(item == found){
                return e.data;
            }
            found++;
        }
    }
    return emptyItem;
}

- (void)next:(int)lane item:(int)item{
    int found = 0;
    for(GEEdge *e in edges){
        if(e.end == found){
            return e.data;
        }
        found++;
    }
    return emptyItem;
}

@end

@implementation GEEdge

- (id)initWithData:(GELaneInfo*)data start:(int)start{
    if((self = [super init])){
        _data = [data retain];
        _start = start;
    }
}

- (int)end{
    return data.connectLane;
}

- (NSString*)description{
    return [NSString stringWithFormat:@"%@->%@: %@",_start,self.end,_data];
}
@end
