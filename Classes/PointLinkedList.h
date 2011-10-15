//
//  PointLinkedList.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 10/9/11.
//  Copyright (c) 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct PointNode{
    CGPoint* point;
    struct PointNode* next;
    struct PointNode* previous;
}PointNode;

@interface PointLinkedList : NSObject
@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, readonly) PointNode* startPosition;
@property (nonatomic, readonly) PointNode* currentPosition;  // Read position
@property (nonatomic, readonly) PointNode* lastPosition;     // Write position

// Read node
-(PointNode*)next;

// Manipulate list
-(void)addPoint:(CGPoint)p;
-(void)clear;
-(void)resetPosition;
-(void)replaceLastPointWithPoint:(CGPoint)newLastPoint;
@end
