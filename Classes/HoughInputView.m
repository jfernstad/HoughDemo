//
//  HoughInputView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <objc/runtime.h>
#import "HoughInputView.h"
#import "HoughLineOverlayDelegate.h"
#import "CGGeometry+HoughExtensions.h"
#import "Hough.h"
#import "PointLinkedList.h"

@interface HoughInputView ()
- (CGPoint)convertPoint:(CGPoint)point withAccuracy:(CGPoint)accuracy;
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer;
- (void)setup;
@end

@implementation HoughInputView
@synthesize points;
@synthesize currentPoint;
@synthesize delegate;
@synthesize pointsColor;
@synthesize houghRef;
@synthesize persistentTouch;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
	if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
	}
	return self;
}
- (CGPoint)convertPoint:(CGPoint)point withAccuracy:(CGPoint)accuracy{
    CGPoint o = CGPointZero;
    
    o.x = roundf(point.x / accuracy.x) * accuracy.x;
    o.y = roundf(point.y / accuracy.y) * accuracy.y;
    
    return o;
}

- (void)setup{
    self.points  = [[[PointLinkedList alloc] init] autorelease];
    self.persistentTouch = NO;
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    
    tap.numberOfTapsRequired	= 1;
    tap.numberOfTouchesRequired = 1;
    pan.maximumNumberOfTouches	= 1;
    
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:pan];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetStrokeColorWithColor(context, pointsColor.CGColor);
	CGContextSetLineWidth(context, 3.0);
    
//	CGPoint p;
    PointNode* node = NULL;
    [self.points resetPosition];
    
	while ((node = [self.points next])) {
		
		CGContextAddEllipseInRect(context, CGRectWithCenter(*(node->point), 1.0));
	}
	
	CGContextDrawPath(context, kCGPathFillStroke);
}

-(void) clear{
	[self.points clear];
}
- (void)dealloc {
	self.points = nil;
	self.currentPoint = nil;
    self.pointsColor = nil;
    self.delegate = nil;
    self.houghRef = nil;
    
	[tap release];
	[pan release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Gestures

// Gestures
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer{
	CGPoint p = [gestureRecognizer locationInView:self];
    NSInteger start = 0;
    NSRange r;
    PointLinkedList* tmpPoints = [[[PointLinkedList alloc] init] autorelease];
    PointNode* node = NULL;
    
    for (NSUInteger i = 0; i < gestureRecognizer.numberOfTouches; i++) {
        p = [gestureRecognizer locationOfTouch:i inView:self];
        p = [self convertPoint:p withAccuracy:CGPointMake(5.0, 5.0)]; // TODO: Parametrize

//        if (!self.persistentTouch){// || ![self.points containsObject:pointVal]) { // Don't add same point again.  
            [tmpPoints addPoint:p];
//        }
    }
//    DLog(@"GestureState: %d", gestureRecognizer.state);
	self.currentPoint = [NSValue valueWithCGPoint:p];

    if (self.persistentTouch) {
        while ((node = [tmpPoints next])) {
            [self.points addPoint:*(node->point)]; // Add first points
        }
    }else{
    
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:
                while ((node = [tmpPoints next])) {
                    [self.points addPoint:*(node->point)];
                }
                break;
            case UIGestureRecognizerStateEnded:
                if (gestureRecognizer == tap){
                    while ((node = [tmpPoints next])) {
                        [self.points addPoint:*(node->point)];
                    }
                }else{
                    [tmpPoints addPoint:*(self.points.lastPosition->point)]; // ONE POINT ONLY, Thats all we know. 
                }
                houghRef.storeAfterDraw = YES; // Store temporary image

                break;
            case UIGestureRecognizerStateChanged:
                if (self.points.size) {
                    start = self.points.size-tmpPoints.size;
                    start = MAX(start, 0);
                    
                    r.location = start;
                    r.length = tmpPoints.size;

                    // TODO: Add support for multiple additions from end?
                    [self.points replaceLastPointWithPoint:*(tmpPoints.lastPosition->point)];
                }
                break;
            case UIGestureRecognizerStateCancelled:
                DLog(@"Touch cancelled. Decide what to do here");
                break;
                
            default:
                break;
        }
    
    }

	[self setNeedsDisplay];
	
	if (delegate) {
		[delegate performSelector:@selector(updateInputWithPoints:) withObject:tmpPoints afterDelay:0.0];
	}
}


@end
