//
//  UnitTests.m
//  UnitTests
//
//  Created by Joakim Fernstad on 8/28/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import "UnitTests.h"
#import "Hough.h"
#import "Bucket2D.h"

@implementation UnitTests

- (void)setUp
{
    [super setUp];
    
    instance = [[Hough alloc] init];
    bucket   = [[Bucket2D alloc] init];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.

    [instance release];
    [bucket release];
    
    [super tearDown];
}

- (void)test101x101
{
    CGSize imgSize = CGSizeMake(1001, 1001);
    
    instance.size = imgSize;
    instance.yScale = 2.0;
    
    NSMutableArray* points = [NSMutableArray array];
    
    CGFloat x = 0, y = 0;
    NSUInteger ii = 0;
    
    // Line 1
    for (ii = 0; ii < 40; ii++) {
        x = 500 + ii*imgSize.width/100;
        y = 500;
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
//        NSLog(@"P: %@", NSStringFromCGPoint(CGPointMake(x, y)));
    }

    CGImageRelease([instance newHoughSpaceFromPoints:points persistant:YES]);
    
    [instance analyzeHoughSpaceOp];
    
//    NSLog(@"%@", [instance allIntersections]);
    
    [bucket addIntersections:[instance allIntersections]];
    
    STAssertEquals((int)[bucket allBuckets].count, (int)1, @"More than 1 bucket in this bucket! Not %d !", [bucket allBuckets].count);
    
    NSArray* cogs = [bucket cogIntersectionsForAllBuckets];
 
    STAssertEquals((int)cogs.count, (int)1, @"Should only be 1 line in here. Not %d !", cogs.count);
    
    NSLog(@"%@", cogs);
    
    HoughIntersection* theLine = nil;
    
    if (cogs.count) {
        theLine = [cogs objectAtIndex:0];
    
        STAssertEqualsWithAccuracy((float)(M_PI/2), (float)(theLine.theta), 0.01, @"Angle is wrong!");
        STAssertEqualsWithAccuracy((float)0, (float)(theLine.length), 2, @"Length is too far off!");
    }
}

@end
