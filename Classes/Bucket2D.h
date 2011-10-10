//
//  Bucket2D.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 6/11/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Hough.h"
#import "IntersectionLinkedList.h"

@interface Bucket2D : NSObject {
    CGPoint bucketAccuracy;
    NSMutableDictionary* buckets;
}

@property (nonatomic, assign) CGPoint bucketAccuracy;

-(NSSet*)allBuckets;
-(void)clearBuckets;
-(void)addIntersection:(HoughIntersection*)intersection;
-(void)addIntersections:(IntersectionLinkedList*)intersections;
-(HoughIntersection*)cogIntersectionForBucket:(NSSet*)bucket; // Center of gravity for intersections in bucket
-(NSArray*)cogIntersectionsForAllBuckets; // Array of cogs all buckets

@end
