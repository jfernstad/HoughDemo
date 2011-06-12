//
//  Bucket2D.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 6/11/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "Bucket2D.h"

@interface Bucket2D ()
@property (nonatomic, retain) NSMutableDictionary* buckets;

@end

@implementation Bucket2D
@synthesize bucketAccuracy, buckets;

-(id)init{
    if((self = [super init])){
        self.bucketAccuracy = CGPointMake(1.0, 10); // Theta accuracy, length accuracy
        self.buckets = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

-(NSSet*)allBuckets{
    return (NSSet*)[self.buckets allValues];
}

-(void)clearBuckets{
    [self.buckets removeAllObjects];
}

-(void)addIntersection:(HoughIntersection*)intersection{
    CGPoint roundedPosition = CGPointZero;
    roundedPosition.x = round(intersection.theta  / self.bucketAccuracy.x) * self.bucketAccuracy.x;
    roundedPosition.y = round(intersection.length / self.bucketAccuracy.y) * self.bucketAccuracy.y;

    // Lazy mans hashing, rounded position + half accuracy = middle point in 2D bucket. Not same as COG.
    NSString* bucketKey = [NSString stringWithFormat:@"%f,%f", roundedPosition.x + self.bucketAccuracy.x/2.0f, roundedPosition.y + self.bucketAccuracy.y/2.0f];
    NSMutableSet* bucket = [buckets objectForKey:bucketKey];
    
    if (!bucket) {
        bucket = [[[NSMutableSet alloc] initWithCapacity:1] autorelease];
        [self.buckets setValue:bucket forKey:bucketKey];
    }
    
    NSLog(@"Adding TO Bucket: %@ -> %@", bucketKey, intersection);
    [bucket addObject:intersection];
}

// Center of gravity for intersections in bucket
//-(CGPoint)cogForBucket:(NSSet*)bucket{
-(HoughIntersection*)cogIntersectionForBucket:(NSSet*)bucket{
  
    CGPoint cog = CGPointZero;
    NSUInteger totalIntensity = 0;
//    NSUInteger maxIntensity   = 0;
    
    // Use count for bucket instead of maxIntensity. 
    // Assuming all lines actually goes through COG. 
    
    for (HoughIntersection* i in bucket) {
        cog.x += i.theta  * i.intensity;
        cog.y += i.length * i.intensity;
    
        totalIntensity += i.intensity;
        
//        if (i.intensity > maxIntensity) {
//            maxIntensity = i.intensity;
//        }
    }
    
    if (totalIntensity) {
        cog.x /= totalIntensity;
        cog.y /= totalIntensity;
    }
    
    return [HoughIntersection houghIntersectionWithTheta:cog.x
                                                  length:cog.y
                                            andIntensity:bucket.count];
}

-(void)dealloc{

    self.buckets = nil;
    
    [super dealloc];
}
@end
