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
}PointNode;

@interface PointLinkedList : NSObject
@property (nonatomic, readonly) NSUInteger size;
-(void)addPoint:(CGPoint)p;
-(PointNode*)next;
-(void)clear;
@end
