//
//  ListLinkedList.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 10/9/11.
//  Copyright (c) 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointLinkedList.h"

typedef struct PointListNode{
    PointLinkedList* list;
    struct PointListNode* next;
}PointListNode;

@interface ListLinkedList : NSObject
@property (nonatomic, readonly) NSUInteger size;
-(void)addPointList:(PointLinkedList*)p;
-(PointListNode*)next;
-(void)clear;
@end
