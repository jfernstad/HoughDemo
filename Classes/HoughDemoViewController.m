//
//  HoughDemoViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import "HoughDemoViewController.h"
#import "Hough.h"
#import "HoughLineOverlayDelegate.h"

@implementation HoughDemoViewController
@synthesize houghInputView;
@synthesize houghTouchView;
@synthesize hough;
@synthesize busy;
@synthesize status;
@synthesize lineLayer;
@synthesize circleLayer;
@synthesize lineDelegate;
@synthesize circleDelegate;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView {
//
//    
//
//}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	hough = [[Hough alloc] init];
	
    hough.frame = self.houghTouchView.frame;
	houghInputView.delegate = self;
	houghTouchView.delegate = self; // TODO: implement for real

    self.lineDelegate = [[[HoughLineOverlayDelegate alloc] init] autorelease];
    self.lineLayer = [CALayer layer];
    self.lineLayer.frame = self.houghInputView.frame;
    self.lineLayer.delegate = self.lineDelegate;

    self.circleDelegate = [[[CircleOverlayDelegate alloc] init] autorelease];
    self.circleLayer = [CALayer layer];
    self.circleLayer.frame = self.houghTouchView.frame;
    self.circleLayer.delegate = self.circleDelegate;

    // What position is this????
    self.lineLayer.position = CGPointMake(394, 225);
    //self.circleLayer.position = CGPointMake(394, -225);
    
    [self.houghInputView.layer addSublayer:self.lineLayer];
    [self.houghTouchView.layer addSublayer:self.circleLayer];
    
	self.busy = NO;
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait) ;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	self.hough		= nil;
	self.houghInputView	= nil;
	self.houghTouchView  = nil;
    self.lineLayer  = nil;
    self.lineDelegate = nil;

    [super dealloc];
}

#pragma mark -
#pragma mark Delegates

-(void)updateInputWithPoints:(NSArray*)pointArray{
	// If we are not busy drawing the hough, update the input. 
	CGImageRef img = nil;
	
	NSDate* start;
	NSTimeInterval imgCreation;
	
	if (!self.busy) {
		
		self.busy = YES;
		
		start = [NSDate date];
		img   = [hough newHoughSpaceFromPoints:pointArray];
		imgCreation = [start timeIntervalSinceNow];
		
		self.busy = NO;
	
        // Show hough image
		self.houghTouchView.layer.contents = (id)img;

		CGImageRelease(img);
	
		self.status.text = [NSString stringWithFormat:@"Time for Hough generation: %3.3f ms (%1.3f ms/curve)", -imgCreation*1000.0, -imgCreation*1000.0/pointArray.count];
	}
	else {
		NSLog(@" BUSY! Not finished with previous image");
	}
}
-(void)overlayLines:(NSArray *)lines{
    self.lineDelegate.lines = lines;
    [self.lineLayer setNeedsDisplay];
}
-(void)overlayCircles:(NSArray *)circles{
    self.circleDelegate.points = circles;
    [self.circleLayer setNeedsDisplay];
}

-(IBAction)clear{
	[self.hough clear];
    [self.houghInputView clear];
    self.houghTouchView.layer.contents = nil;
	[self.houghInputView setNeedsDisplay];
    
    self.lineDelegate.lines = nil;
    self.circleDelegate.points = nil;
	[self.lineLayer setNeedsDisplay];
    [self.circleLayer setNeedsDisplay];
}

@end
