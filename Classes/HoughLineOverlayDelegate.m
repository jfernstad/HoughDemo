//
//  LineOverlayDelegate.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/2/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughLineOverlayDelegate.h"
#import "Hough.h"
#import "CGGeometry+HoughExtensions.h"

@interface HoughLineOverlayDelegate () 
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;
@end

@implementation HoughLineOverlayDelegate
@synthesize lines;
@synthesize lineColor;
@synthesize houghRef;

-(id)init{

    if ((self = [super init])) {
        self.lineColor = [UIColor redColor];
    }
    return self;
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{

    // TODO: Make sure the context size is same as image size
//    CGRect rect     = CGRectZero;
    CGRect drawRect = CGRectZero;
    CGFloat theta   = 0.0;
    CGFloat len     = 0.0;
//    CGPoint eq      = CGPointZero;
    CGPoint vec     = CGPointZero;
    CGPoint orto    = CGPointZero;
    CGPoint center  = CGPointZero;
    CGPoint peak    = CGPointZero;
    
    if (!self.lines) return;

//    NSLog(@"layerDelegate is being used!");
    CGColorRef color = lineColor.CGColor;
    const CGFloat *components = NULL;
    //    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
    CGContextSetLineWidth(ctx, 2.0); // TODO: Parametrize
    
    for (HoughIntersection* i in self.lines) {
        
//        eq      = [houghRef equationForPoint:rect];
        theta   = i.theta;
        len     = i.length;
        
        vec    = CGPointMake(cosf(theta), -sinf(theta));
        orto   = CGPointMake(-vec.y, vec.x); // 2D orthogonal vector
        center = CGPointMake(layer.bounds.size.width/2, layer.bounds.size.height/2);
        peak   = CGPointMake(center.x + len * vec.x, center.y + len * vec.y);

    	drawRect = CGRectMake(peak.x - 1000 * orto.x, 
                              peak.y - 1000 * orto.y, 
                              2000 * orto.x, 
                              2000 * orto.y);

        components = CGColorGetComponents(color);
        CGContextSetRGBStrokeColor(ctx, components[0], components[1], components[2], 0.7);
//        CGContextSetRGBStrokeColor(ctx, components[0], components[1], components[2], MAX(MIN(1.0, 1-1/(float)(i.intensity-10)), 0));
        CGContextMoveToPoint(ctx, drawRect.origin.x, drawRect.origin.y);
        CGContextAddLineToPoint(ctx, drawRect.origin.x + drawRect.size.width, 
                                     drawRect.origin.y + drawRect.size.height);
        //CGContextAddEllipseInRect(ctx, CGRectWithCenter(peak, 5));
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        // Debug lines
//        CGContextMoveToPoint(ctx, center.x, center.y);
//        CGContextAddLineToPoint(ctx, center.x + vec.x * len, 
//                                     center.y + vec.y * len);
//        CGContextSetStrokeColorWithColor(ctx, [UIColor yellowColor].CGColor);
//        CGContextDrawPath(ctx, kCGPathFillStroke);
        // Debug lines
        
    }
	
//	NSLog(@"Got Vector (%f, %f)", 360*theta, len);

}

@end
