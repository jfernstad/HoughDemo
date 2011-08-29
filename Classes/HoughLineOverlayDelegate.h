//
//  LineOverlayDelegate.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/2/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class Hough;

@interface HoughLineOverlayDelegate : NSObject {
    NSArray* lines;
    UIColor* lineColor;
    
    Hough* houghRef;

    CGSize imgSize;
}

// NSValue containing a CGRect with origin as theta, distance and size as source image size
@property (nonatomic, retain) NSArray* lines;
@property (nonatomic, retain) UIColor* lineColor;
@property (nonatomic, assign) Hough* houghRef;
@property (nonatomic, assign) CGSize imgSize;
@end
