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
    
    if ((self == [super init])) {
        self.radius = 30;
        self.markColor = [UIColor greenColor];
    }
    return self;
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    
    // TODO: Make sure the context size is same as image size
    CGRect circle     = CGRectZero;
    
    if (!self.points) return;
    
    //    NSLog(@"layerDelegate is being used!");
    
    CGContextSetStrokeColorWithColor(ctx, markColor.CGColor);
    CGContextSetLineWidth(ctx, 2.0); // TODO: Parametrize
    CGContextSetShadow(ctx, CGSizeMake(3, 3), 1.0);
    
    CGPoint center = CGPointZero;
    for (NSValue* v in self.points) {
        
        center = [v CGPointValue];
        
        circle = CGRectWithCenter(center, self.radius);
        // Circle
        CGContextAddEllipseInRect(ctx, circle);
        
        CGContextMoveToPoint(ctx, CGRectGetMinX(circle) - 5, center.y);
        CGContextAddLineToPoint(ctx, CGRectGetMinX(circle) + 5, center.y);

        CGContextMoveToPoint(ctx, CGRectGetMaxX(circle) - 5, center.y);
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(circle) + 5, center.y);

        CGContextMoveToPoint(ctx, center.x, CGRectGetMinY(circle) - 5);
        CGContextAddLineToPoint(ctx, center.x, CGRectGetMinY(circle) + 5);

        CGContextMoveToPoint(ctx, center.x, CGRectGetMaxY(circle) - 5);
        CGContextAddLineToPoint(ctx, center.x, CGRectGetMaxY(circle) + 5);

        CGContextDrawPath(ctx, kCGPathStroke);
    }
	
    //	NSLog(@"Got Vector (%f, %f)", 360*theta, len);
    
}

@end
