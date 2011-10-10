//
//  ListLinkedList.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 10/9/11.
//  Copyright (c) 2011 Joakim Fernstad. All rights reserved.
//

#import "ListLinkedList.h"

@interface ListLinkedList ()
@property (nonatomic, readwrite, assign) NSUInteger size;
@property (nonatomic, assign) PointListNode* startPosition;
@property (nonatomic, assign) PointListNode* currentPosition;  // Read position
@property (nonatomic, assign) PointListNode* lastPosition;     // Write position
-(PointListNode*)newNode;
-(void)resetPosition; // Cur -> Start
@end

//
// Note: This class is not thread safe
//
@implementation ListLinkedList
@synthesize size;
@synthesize startPosition;
@synthesize lastPosition;
@synthesize currentPosition;

-(id)init{
    if ((self = [super init])) {
        self.startPosition   = NULL;
        self.lastPosition    = NULL;
        self.currentPosition = NULL;
        self.size     = 0;
    }
    return self;
}
-(void)dealloc{
    [self clear];
    [super dealloc];
}

#pragma mark - Methods
-(PointListNode*)newNode{
    PointListNode* l = (PointListNode*)malloc(sizeof(PointListNode));
    
    if (!l) return NULL;
    
    // Fist addition
    if (!self.startPosition){ 
        self.startPosition   = l;
        self.lastPosition    = l;
        self.currentPosition = l;
        self.size     = 1;
    }else{
        self.lastPosition->next = l;
        self.lastPosition       = l;
        self.size++;
    }
    
    return l;
}

-(void)resetPosition{
    self.currentPosition = self.startPosition;
}

-(void)addPointList:(PointLinkedList*)nextList{
    PointListNode* l = [self newNode];
    
    if (l) {
        // Initialize node
        l->next = NULL;
        l->list = [nextList retain];
    }
}
-(PointListNode*)next{
    PointListNode* outNode = self.currentPosition;
    
    if (outNode) {
        self.currentPosition = outNode->next;
    }
    
    return outNode;
}
-(void)clear{
    PointListNode* node = NULL;
    
    //    DLog(@"Freeing %d nodes", self.size);
    
    [self resetPosition];
    self.startPosition = NULL;
    
    while ((node = [self next])) {
        self.size--;
        [node->list release];
        free(node);
    }
    
    self.currentPosition = NULL;
    self.lastPosition    = NULL;
    
    //    DLog(@"End size: %d", self.size);
}
-(NSString*)description{
    return [NSString stringWithFormat:@"TotalNodes: %d, Start: 0x%x, End: 0x%x, Current: 0x%x", self.size, self.startPosition, self.lastPosition, self.currentPosition];
}
@end