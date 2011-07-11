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
    self.points  = [NSMutableArray arrayWithCapacity:0];
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
    
	CGPoint p;
	for (NSValue* val in self.points) {
		[val getValue:&p];
		
		CGContextAddEllipseInRect(context, CGRectWithCenter(p, 1.0));
	}
	
	CGContextDrawPath(context, kCGPathFillStroke);
}

-(void) clear{
	[self.points removeAllObjects];
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
	NSValue* pointVal = nil;
    NSMutableArray* tmpPoints = [NSMutableArray arrayWithCapacity:gestureRecognizer.numberOfTouches];
    
    for (NSUInteger i = 0; i < gestureRecognizer.numberOfTouches; i++) {
        p = [gestureRecognizer locationOfTouch:i inView:self];
        p = [self convertPoint:p withAccuracy:CGPointMake(5.0, 5.0)]; // TODO: Parametrize

        pointVal = [NSValue valueWithCGPoint:p];
        if (!self.persistentTouch || ![self.points containsObject:pointVal]) { // Don't add same point again.  
            [tmpPoints addObject:pointVal];
        }
    }
//    NSLog(@"GestureState: %d", gestureRecognizer.state);
	self.currentPoint = [NSValue valueWithCGPoint:p];

    if (self.persistentTouch) {
        [self.points addObjectsFromArray:tmpPoints]; // Add first points
    }else{
    
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:
                [self.points addObjectsFromArray:tmpPoints]; // Add first points
                break;
            case UIGestureRecognizerStateEnded:
                if (gestureRecognizer == tap){
                    [self.points addObjectsFromArray:tmpPoints];
                }else{
                    [tmpPoints addObject:[self.points lastObject]]; // ONE POINT ONLY, Thats all we know. 
                }
                houghRef.storeAfterDraw = YES; // Store temporary image

                break;
            case UIGestureRecognizerStateChanged:
                if (self.points.count) {
                    start = self.points.count-tmpPoints.count;
                    start = MAX(start, 0);
                    
                    r.location = start;
                    r.length = tmpPoints.count;
                    
                    [self.points replaceObjectsInRange:r withObjectsFromArray:tmpPoints];
                }
                break;
            case UIGestureRecognizerStateCancelled:
                NSLog(@"Touch cancelled. Decide what to do here");
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
