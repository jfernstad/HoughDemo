//
//  UnitTests.h
//  UnitTests
//
//  Created by Joakim Fernstad on 8/28/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class Hough;
@class Bucket2D;

@interface UnitTests : SenTestCase{
    Hough* instance;

    Bucket2D* bucket;

}

@end
