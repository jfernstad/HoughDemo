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
    
    //    CGSize origSize = self.size;// self.inputUIImage.size;
    CGSize origSize = imgSize;
    
    CGFloat x = 0, y = 0;
    NSUInteger ii = 0;
    
    // Line 1
    for (ii = 0; ii < 40; ii++) {
        x = origSize.width/2 + ii * origSize.width/100;//imgSize.width/2 - (CGFloat)(ii*10);
        y = origSize.height/2;// - size.height/5;
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        DLog(@"P: %@", NSStringFromCGPoint(CGPointMake(x, y)));
    }
    
    // Line 2
    for (ii = 0; ii < 40; ii++) {
        y = origSize.height/2 + ii * origSize.height/100;//imgSize.width/2 - (CGFloat)(ii*10);
        x = origSize.width/2;// - size.height/5;
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        DLog(@"P: %@", NSStringFromCGPoint(CGPointMake(x, y)));
    }
    
    // Line 3
    for (ii = 0; ii < 40; ii++) {
        y = origSize.height/2 + ii * origSize.height/50;//imgSize.width/2 - (CGFloat)(ii*10);
        x = origSize.width/2  + ii * origSize.width/50;// - size.height/5;
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        DLog(@"P: %@", NSStringFromCGPoint(CGPointMake(x, y)));
    }

    CGImageRelease([instance newHoughSpaceFromPoints:points persistent:YES]);
    
    [instance analyzeHoughSpaceOp];
    
//    DLog(@"%@", [instance allIntersections]);
    
    [bucket addIntersections:[instance allIntersections]];
    
    STAssertEquals((int)[bucket allBuckets].count, (int)3, @"Not 3 buckets in this bucket! Not %d !", [bucket allBuckets].count);
    
    NSArray* cogs = [bucket cogIntersectionsForAllBuckets];
 
    STAssertEquals((int)cogs.count, (int)3, @"Should only be 3 lines in here. Not %d !", cogs.count);
    
    DLog(@"%@", cogs);
    
    HoughIntersection* l1 = nil;
    HoughIntersection* l2 = nil;
    HoughIntersection* l3 = nil;
    
    if (cogs.count) {
        l1 = [cogs objectAtIndex:0];
        l2 = [cogs objectAtIndex:1];
        l3 = [cogs objectAtIndex:2];
    
        STAssertEqualsWithAccuracy((float)(M_PI/2), (float)(l1.theta), 0.01, @"Angle is wrong!");
        STAssertEqualsWithAccuracy((float)0, (float)(l1.length), 2, @"Length is too far off!");

        STAssertEqualsWithAccuracy((float)(M_PI), (float)(l2.theta), 0.01, @"Angle is wrong!");
        STAssertEqualsWithAccuracy((float)0, (float)(l2.length), 3, @"Length is too far off!");
        
        STAssertEqualsWithAccuracy((float)(M_PI/4), (float)(l3.theta), 0.01, @"Angle is wrong!");
        STAssertEqualsWithAccuracy((float)0, (float)(l3.length), 2, @"Length is too far off!");

    }
}

@end
