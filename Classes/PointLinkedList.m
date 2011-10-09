//
//  PointLinkedList.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 10/9/11.
//  Copyright (c) 2011 Joakim Fernstad. All rights reserved.
//

#import "PointLinkedList.h"
#import "HoughConstants.h"

@interface PointLinkedList ()
@property (nonatomic, readwrite, assign) NSUInteger size;
@property (nonatomic, assign) PointNode* startPosition;
@property (nonatomic, assign) PointNode* currentPosition;  // Read position
@property (nonatomic, assign) PointNode* lastPosition;     // Write position
-(PointNode*)newNode;
-(void)resetPosition; // Cur -> Start
@end

//
// Note: This class is not thread safe
//
@implementation PointLinkedList
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
-(PointNode*)newNode{
    PointNode* l = (PointNode*)malloc(sizeof(PointNode));
    l->point     = (CGPoint*)malloc(sizeof(CGPoint));
    
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

-(void)addPoint:(CGPoint)p{
    PointNode* l = [self newNode];

    if (l) {
        // Initialize node
        l->next = NULL;
        l->point->x = p.x;
        l->point->y = p.y;
    }
}
-(PointNode*)next{
    PointNode* outNode = self.currentPosition;
    
    if (outNode) {
        self.currentPosition = outNode->next;
    }
    
    return outNode;
}
-(void)clear{
    PointNode* node = NULL;
    
//    DLog(@"Freeing %d nodes", self.size);
    
    [self resetPosition];
    self.startPosition = NULL;
    
    while ((node = [self next])) {
        self.size--;
        free(node->point);
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
