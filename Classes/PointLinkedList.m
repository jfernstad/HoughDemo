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
-(void)addNode:(PointNode*)newNode;
-(void)removeNode:(PointNode*)removeNode;
-(void)freeNode:(PointNode*)deleteNode;
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
    
    if (!l) return NULL;
    
    // Initialize
    l->point    = (CGPoint*)malloc(sizeof(CGPoint));
    l->previous = NULL;
    l->next     = NULL;
    
    return l;
}
-(void)addNode:(PointNode*)newNode{
    // Fist addition
    if (!self.startPosition){ 
        self.startPosition   = newNode;
        self.lastPosition    = newNode;
        self.currentPosition = newNode;
        self.size            = 1;
        newNode->previous    = NULL;
    }else{
        newNode->previous       = self.lastPosition;
        self.lastPosition->next = newNode;
        self.lastPosition       = newNode;
        self.size++;
    }
}
-(void)resetPosition{
    self.currentPosition = self.startPosition;
}

-(void)addPoint:(CGPoint)p{
    PointNode* l = [self newNode];

    if (l) {
        // Initialize node
        l->point->x = p.x;
        l->point->y = p.y;

        [self addNode:l];
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
    
    while ((node = [self next])) {
        [self removeNode:node];
        [self freeNode:node];
    }
    
    self.startPosition = NULL;
    self.currentPosition = NULL;
    self.lastPosition    = NULL;

//    DLog(@"End size: %d", self.size);
}

-(void)replaceLastPointWithPoint:(CGPoint)newLastPoint{
    PointNode* newNode  = [self newNode];
    PointNode* lastNode = self.lastPosition;
    
    // Copy info from input node
    if (newNode) {
        newNode->point->x = newLastPoint.x;
        newNode->point->y = newLastPoint.y;
        newNode->previous = lastNode->previous; 
        newNode->previous->next = newNode;
        
        [self removeNode:lastNode];
        [self addNode:newNode];
        [self freeNode:lastNode];
    }
}

-(BOOL)containsPoint:(CGPoint)point{
    //Traverse list without affecting current read position
    BOOL pointFound = NO;
    PointNode* currentNode = self.startPosition;
    
    while (currentNode) {
        if (CGPointEqualToPoint(*(currentNode->point), point)) {
            pointFound = YES;
            break;
        }
        currentNode = currentNode->next;
    }
    return pointFound;
}

// Remove node without corrupting list
-(void)removeNode:(PointNode*)removeNode{

    if (removeNode->previous) {
        // Middle of list
        if (removeNode->next) {
            removeNode->previous->next = removeNode->next;
            removeNode->next->previous = removeNode->previous;

            if (self.currentPosition == removeNode) 
                self.currentPosition = removeNode->previous;
        }
        // End of list
        else{
            self.lastPosition = removeNode->previous;
            removeNode->previous->next = NULL; // Remove self from previous node

            if (self.currentPosition == removeNode) 
                self.currentPosition = self.lastPosition;
        }
    }
    else{
        // Top of list
        if (removeNode->next) {
            self.startPosition = removeNode->next;
            removeNode->next->previous = NULL;
            
            if (self.currentPosition == removeNode) 
                self.currentPosition = self.startPosition;
        }
        // Alone in list
        else{
            // Do nothing
            //DLog(@"List is now empty");

            self.startPosition   = NULL;
            self.lastPosition    = NULL;
            self.currentPosition = NULL;

        }
    }
    
    self.size--;
}
-(void)freeNode:(PointNode*)deleteNode{
    if (deleteNode != NULL) {
        free(deleteNode->point);
        free(deleteNode);
    }
}

-(NSString*)description{
    return [NSString stringWithFormat:@"TotalNodes: %d, Start: 0x%x, End: 0x%x, Current: 0x%x", self.size, self.startPosition, self.lastPosition, self.currentPosition];
}
@end
