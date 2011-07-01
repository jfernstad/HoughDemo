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
    pan.maximumNumberOfTouches	= 2;
    
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
	///(@"Got a %@", [gestureRecognizer class]);
    // for (gestureRecognizer.numberOfTouches
    // [gestureRecognizer locationForTouch:inView:];
	CGPoint p = [gestureRecognizer locationInView:self];
	
    NSMutableArray* tmpPoints = [NSMutableArray arrayWithCapacity:gestureRecognizer.numberOfTouches];
    
    for (NSUInteger i = 0; i < gestureRecognizer.numberOfTouches; i++) {
        p = [gestureRecognizer locationOfTouch:i inView:self];
        p = [self convertPoint:p withAccuracy:CGPointMake(3.0, 3.0)]; 
        
        [tmpPoints addObject:[NSValue valueWithCGPoint:p]];
    }
    
	self.currentPoint = [NSValue valueWithCGPoint:p];
	
	if (gestureRecognizer == tap || self.persistentTouch) {
		[self.points addObjectsFromArray:tmpPoints];
	}else if (gestureRecognizer == pan) {
		if (self.persistentTouch) {
            [self.points addObjectsFromArray:tmpPoints];
		}
		else {
            NSInteger start = self.points.count-tmpPoints.count;
            start = MAX(start, 0);
            NSRange r = {(NSUInteger)start, tmpPoints.count};
            //			[self.points replaceObjectAtIndex:self.points.count-1 withObject:self.currentPoint];
            if (points.count) {
                [self.points replaceObjectsInRange:r withObjectsFromArray:tmpPoints];
            }
        }
	}
	
	[self setNeedsDisplay];
	
	if (delegate) {
		//NSLog(@"handleGesture: Calling delegate");
        // Grr.. need to pass another argument, maybe attach with runtime methods?
        //NSArray* pointArray = [NSArray arrayWithObject:self.currentPoint];
        
        //        objc_setAssociatedObject(tmpPoints, kHoughInputGestureState, [NSNumber numberWithInt:(int)gestureRecognizer.state], OBJC_ASSOCIATION_RETAIN);
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            houghRef.storeAfterDraw = YES; // Store temporary image
        }

		[delegate performSelector:@selector(updateInputWithPoints:) withObject:tmpPoints afterDelay:0.0];
	}
}


@end
