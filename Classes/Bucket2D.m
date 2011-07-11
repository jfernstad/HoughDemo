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
        self.bucketAccuracy = CGPointMake(M_PI_2, 30); // Theta accuracy, length accuracy
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
    roundedPosition.x = round(intersection.theta  / self.bucketAccuracy.x + self.bucketAccuracy.x/2.0f) * self.bucketAccuracy.x;
    roundedPosition.y = round(intersection.length / self.bucketAccuracy.y + self.bucketAccuracy.x/2.0f) * self.bucketAccuracy.y;

    // Lazy mans hashing, rounded position = middle point in 2D bucket. Not same as COG.
    NSString* bucketKey = [NSString stringWithFormat:@"%f,%f", roundedPosition.x, roundedPosition.y];
    NSMutableSet* bucket = [buckets objectForKey:bucketKey];
    
    if (!bucket) {
        bucket = [[[NSMutableSet alloc] initWithCapacity:1] autorelease];
        [self.buckets setValue:bucket forKey:bucketKey];
    }
    
//    NSLog(@"Adding TO Bucket: %@ -> %@", bucketKey, intersection);
    [bucket addObject:intersection];
}

-(void)addIntersections:(NSArray*)intersections{
    for (HoughIntersection* h in intersections) {
        [self addIntersection:h];
    }
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
        
//        NSLog(@"%f * %d = %f", i.length, i.intensity, i.length * i.intensity);
//        if (i.intensity > maxIntensity) {
//            maxIntensity = i.intensity;
//        }
    }

//    NSLog(@"------");
//    NSLog(@"cog.y / totalIntensity =  %f / %d = %f", cog.y, totalIntensity, cog.y / (float)totalIntensity);
    
    if (totalIntensity) {
        cog.x /= (float)totalIntensity;
        cog.y /= (float)totalIntensity;
    }
    
    return [HoughIntersection houghIntersectionWithTheta:cog.x
                                                  length:cog.y
                                            andIntensity:bucket.count];
}

-(NSArray*)cogIntersectionForAllBuckets{

    NSSet* bucks = [self allBuckets];
    NSMutableArray* lines = [NSMutableArray arrayWithCapacity:buckets.count];
    HoughIntersection* cog = nil;
    
    for (NSSet* set in bucks) {
        cog = [self cogIntersectionForBucket:set];
        [lines addObject:cog];
    }

    return lines;
}

-(void)dealloc{

    self.buckets = nil;
    
    [super dealloc];
}
@end
