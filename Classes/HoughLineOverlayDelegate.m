//
//  LineOverlayDelegate.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/2/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
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

-(id)init{

    if ((self == [super init])) {
        self.lineColor = [UIColor redColor];
    }
    return self;
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{

    // TODO: Make sure the context size is same as image size
    CGRect rect     = CGRectZero;
    CGRect drawRect = CGRectZero;
    CGFloat theta   = 0.0;
    CGFloat len     = 0.0;
    CGPoint vec     = CGPointZero;
    CGPoint orto    = CGPointZero;
    CGPoint center  = CGPointZero;
    CGPoint peak    = CGPointZero;
    
    if (!self.lines) return;

//    NSLog(@"layerDelegate is being used!");
    
    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
    CGContextSetLineWidth(ctx, 1.0); // TODO: Parametrize
    
    for (NSValue* v in self.lines) {
        
        rect    = [v CGRectValue];
        theta   = M_PI - rect.origin.x * M_PI/rect.size.width;
        len     = (rect.size.height - rect.origin.y*[Hough yScale]); // * Y_SCALE = 2
        
        vec    = CGPointMake(cosf(theta), -sinf(theta));
        orto   = CGPointMake(-vec.y, vec.x); // 2D orthogonal vector
        center = CGPointMake(rect.size.width/2, rect.size.height/2);
        peak   = CGPointMake(center.x + len * vec.x, center.y + len * vec.y);

    	drawRect = CGRectMake(peak.x - 1000 * orto.x, 
                              peak.y - 1000 * orto.y, 
                              2000 * orto.x, 
                              2000 * orto.y);

        
        CGContextMoveToPoint(ctx, drawRect.origin.x, drawRect.origin.y);
        CGContextAddLineToPoint(ctx, drawRect.origin.x + drawRect.size.width, 
                                     drawRect.origin.y + drawRect.size.height);
        CGContextDrawPath(ctx, kCGPathFillStroke);
    }
	
//	NSLog(@"Got Vector (%f, %f)", 360*theta, len);

}

@end
