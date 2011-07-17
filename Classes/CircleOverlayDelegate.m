//
//  TouchOverlayDelegaate.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/2/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "CircleOverlayDelegate.h"
#import "CGGeometry+HoughExtensions.h"

@interface CircleOverlayDelegate () 
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;
@end


@implementation CircleOverlayDelegate
@synthesize points;
@synthesize radius;
@synthesize markColor;

-(id)init{
    
    if ((self = [super init])) {
        self.radius = 30;
        self.markColor = [UIColor greenColor];
    }
    return self;
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    
    // TODO: Make sure the context size is same as image size
//    CGRect circle     = CGRectZero;
    
    if (!self.points) return;
    
    //    NSLog(@"layerDelegate is being used!");
    
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetShadow(ctx, CGSizeMake(3, 3), 1.0);
    
    CGPoint center = CGPointZero;
    for (NSValue* v in self.points) {
        
        center = [v CGPointValue];
        
        center.y -= 2.0;
        
//        circle = CGRectWithCenter(center, self.radius);

        CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor);
        CGContextSetLineWidth(ctx, 5.0); // TODO: Parametrize
        
        // Arrow
        CGContextMoveToPoint(ctx, center.x, center.y);
        CGContextAddLineToPoint(ctx, center.x - 20, center.y - 30); // FIXME: Dislike this hardcoded values

        CGContextMoveToPoint(ctx, center.x, center.y);
        CGContextAddLineToPoint(ctx, center.x + 20, center.y - 30); // FIXME: Dislike this hardcoded values

        CGContextDrawPath(ctx, kCGPathStroke);

        // -- 
        
        CGContextSetStrokeColorWithColor(ctx, markColor.CGColor);
        CGContextSetLineWidth(ctx, 2.0); // TODO: Parametrize
        
        // Arrow
        CGContextMoveToPoint(ctx, center.x, center.y);
        CGContextAddLineToPoint(ctx, center.x - 20, center.y - 30);// FIXME: Dislike this hardcoded value
        
        CGContextMoveToPoint(ctx, center.x, center.y);
        CGContextAddLineToPoint(ctx, center.x + 20, center.y - 30);// FIXME: Dislike this hardcoded value
        
        CGContextDrawPath(ctx, kCGPathStroke);
    }
	
    //	NSLog(@"Got Vector (%f, %f)", 360*theta, len);
    
}

@end
