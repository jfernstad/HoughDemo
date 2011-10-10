//
//  IntersectionLinkedList.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 10/9/11.
//  Copyright (c) 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HoughIntersection;
typedef struct IntersectionNode{
    HoughIntersection* intersection;
    struct IntersectionNode* next;
}IntersectionNode;

@interface IntersectionLinkedList : NSObject
@property (nonatomic, readonly) NSUInteger size;
-(void)addIntersection:(HoughIntersection*)p;
-(IntersectionNode*)next;
-(void)clear;

@end
