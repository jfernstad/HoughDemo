//
//  HoughPresentationView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 3/12/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import "HoughTouchView.h"
#import "Hough.h"

@interface HoughTouchView()
// Gestures
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer;
- (void)setup;
@end

@implementation HoughTouchView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        [self setup];
	}
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
	if (self == [super initWithCoder:aDecoder]) {
        // Initialization code.
        [self setup];
		
	}
    return self;
}

- (void)setup{
    
    self.backgroundColor = [UIColor blackColor];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    
    tap.numberOfTapsRequired	= 1;
    tap.numberOfTouchesRequired = 1;
    pan.maximumNumberOfTouches	= 2;
    
    [self addGestureRecognizer:tap];
    [self addGestureRecognizer:pan];
    [tap release];
    [pan release];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	self.delegate = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Gestures

// Gestures
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer{
	///(@"Got a %@", [gestureRecognizer class]);
	CGPoint p = [gestureRecognizer locationInView:self];

    //p.y = self.frame.size.height - p.y;
    
	CGRect r = CGRectZero;
	
    if (gestureRecognizer.numberOfTouches == 0) {
        return;
    }
    
	NSMutableArray* points = [NSMutableArray arrayWithCapacity:gestureRecognizer.numberOfTouches];
	NSMutableArray* rects  = [NSMutableArray arrayWithCapacity:gestureRecognizer.numberOfTouches];
    
    for (NSUInteger i = 0; i < gestureRecognizer.numberOfTouches; i++) {
        p = [gestureRecognizer locationOfTouch:i inView:self];
        r.origin = p;
        r.size   = self.frame.size;

        [points addObject:[NSValue valueWithCGPoint:p]];
        [rects  addObject:[NSValue valueWithCGRect:r]];
    }
    
	if (delegate && [delegate respondsToSelector:@selector(overlayLines:)]) { // TODO: handle multitouch
		[delegate performSelector:@selector(overlayLines:) withObject:rects afterDelay:0.0];
    }

	if (delegate && [delegate respondsToSelector:@selector(overlayCircles:)]) {
		[delegate performSelector:@selector(overlayCircles:) withObject:points afterDelay:0.0];
    }
}

@end
