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
@synthesize imgSize;

-(id)init{

    if ((self = [super init])) {
        self.lineColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.7];
    }
    return self;
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{

    // TODO: Make sure the context size is same as image size
    CGRect drawRect = CGRectZero;
    CGFloat theta   = 0.0;
    CGFloat len     = 0.0;
    CGPoint vec     = CGPointZero;
    CGPoint orto    = CGPointZero;
    CGPoint center  = CGPointZero;
    CGPoint peak    = CGPointZero;

    CGFloat xScale = 1.0;
    CGFloat yScale = 1.0;
    
    if (!self.lines) return;
    if (CGSizeEqualToSize(self.imgSize, CGSizeZero)) return;

    xScale = self.imgSize.width  / layer.bounds.size.width;
    yScale = self.imgSize.height / layer.bounds.size.height;
    
//    DLog(@"LineDelegate scale: (%f, %f)",xScale, yScale);
    
    CGColorRef color = lineColor.CGColor;
    CGContextSetLineWidth(ctx, 2.0); // TODO: Parametrize
    
    for (HoughIntersection* i in self.lines) {
        
        //DLog(@"%@", i);
        theta   = i.theta;
        len     = i.length;
        
        vec    = CGPointMake(cosf(theta), -sinf(theta));
        orto   = CGPointMake(-vec.y, vec.x); // 2D orthogonal vector
        center = CGPointMake(layer.bounds.size.width/2, layer.bounds.size.height/2);
        peak   = CGPointMake(center.x + (len * vec.x)/xScale, center.y + (len * vec.y)/yScale);

    	drawRect = CGRectMake(peak.x - 1000 * (orto.x)/xScale, 
                              peak.y - 1000 * (orto.y)/yScale, 
                              2000 * (orto.x)/xScale, 
                              2000 * (orto.y)/yScale);

//        components = CGColorGetComponents(color);
//        CGContextSetRGBStrokeColor(ctx, components[0], components[1], components[2], 0.7);
//        CGContextSetRGBStrokeColor(ctx, components[0], components[1], components[2], MAX(MIN(1.0, 1-1/(float)(i.intensity-10)), 0));
        CGContextSetStrokeColorWithColor(ctx, color);
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
	
//	DLog(@"Got Vector (%f, %f)", 360*theta, len);

}

@end
