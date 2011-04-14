//
//  HoughInputView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import <objc/runtime.h>
#import "HoughInputView.h"
#import "HoughLineOverlayDelegate.h"
#import "CGGeometry+HoughExtensions.h"
#import "Hough.h"

@interface HoughInputView ()
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer;
- (void)setup;
@end

@implementation HoughInputView
@synthesize points;
@synthesize currentPoint;
@synthesize delegate;
@synthesize pointsColor;
@synthesize houghRef;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
	if (self == [super initWithCoder:aDecoder]) {
        [self setup];
	}
	return self;
}

- (void)setup{
    self.points  = [NSMutableArray arrayWithCapacity:0];
    
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
		
		CGContextAddEllipseInRect(context, CGRectWithCenter(p, 3.0));
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
	
	self.currentPoint = [NSValue valueWithCGPoint:p];
	
	if (gestureRecognizer == tap || houghRef.interactionMode == kFreeHandDraw) {
		[self.points addObject:self.currentPoint];
	}else if (gestureRecognizer == pan) {
		if (gestureRecognizer.state == UIGestureRecognizerStateBegan || self.points.count == 0) {
			[self.points addObject:self.currentPoint];
		}
		else {
			[self.points replaceObjectAtIndex:self.points.count-1 withObject:self.currentPoint];
		}
	}
	
	[self setNeedsDisplay];
	
	if (delegate) {
		//NSLog(@"handleGesture: Calling delegate");
        // Grr.. need to pass another argument, maybe attach with runtime methods?
        NSArray* pointArray = [NSArray arrayWithObject:self.currentPoint];
        
        objc_setAssociatedObject(pointArray, kHoughInputGestureState, [NSNumber numberWithInt:(int)gestureRecognizer.state], OBJC_ASSOCIATION_RETAIN);
		[delegate performSelector:@selector(updateInputWithPoints:) withObject:pointArray afterDelay:0.0];
	}
}


@end
