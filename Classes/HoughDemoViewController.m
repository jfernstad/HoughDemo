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

@interface HoughDemoViewController ()
-(void)layoutViews;
@end

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
@synthesize clearButton;

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
- (void)loadView {

    CGRect totalRect  = [UIScreen mainScreen].applicationFrame;
    CGRect touchRect  = CGRectZero;
    CGRect inputRect  = CGRectZero;
    CGRect buttonRect = CGRectZero;
    CGRect statusRect = CGRectZero;
    
    CGRectDivide(totalRect, &buttonRect, &touchRect,  40, CGRectMinYEdge);
    CGRectDivide(touchRect, &touchRect,  &inputRect,  450, CGRectMinYEdge);
    CGRectDivide(inputRect, &inputRect,  &statusRect, 450, CGRectMinYEdge);
    
    self.view           = [[[UIView alloc] initWithFrame:totalRect] autorelease];
    self.houghTouchView = [[[HoughTouchView alloc] initWithFrame:touchRect] autorelease];
    self.houghInputView = [[[HoughInputView alloc] initWithFrame:inputRect] autorelease];
    self.clearButton    = [UIButton buttonWithType:UIButtonTypeCustom];
    self.status         = [[[UILabel alloc] initWithFrame:statusRect] autorelease];

    self.hough = [[[Hough alloc] init] autorelease];

    buttonRect = CGRectInset(buttonRect, 300, 0);

    [self.clearButton addTarget:self action:@selector(clear) forControlEvents: UIControlEventTouchUpInside];
    [self.clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    
	
    self.hough.frame = self.houghTouchView.frame;
	self.houghInputView.delegate = self;
	self.houghTouchView.delegate = self;
    
    self.lineDelegate = [[[HoughLineOverlayDelegate alloc] init] autorelease];
    self.lineLayer = [CALayer layer];
    self.lineLayer.frame = self.houghInputView.bounds;
    self.lineLayer.delegate = self.lineDelegate;
    
    self.circleDelegate = [[[CircleOverlayDelegate alloc] init] autorelease];
    self.circleLayer = [CALayer layer];
    self.circleLayer.frame = self.houghTouchView.bounds;
    self.circleLayer.delegate = self.circleDelegate;
    
    [self.houghInputView.layer addSublayer:self.lineLayer];
    [self.houghTouchView.layer addSublayer:self.circleLayer];

    
    // Size/position
    self.clearButton.frame = buttonRect;
//    self.status.frame = statusRect;
//    self.houghInputView.frame = inputRect;
//    self.houghTouchView.frame = touchRect;

    [self.view addSubview:self.houghTouchView];
    [self.view addSubview:self.houghInputView];
    [self.view addSubview:self.clearButton];
    [self.view addSubview:self.status];

}

-(void)layoutViews{

    UIColor* borderColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.2 alpha:1.0];
    UIColor* bgColor     = [UIColor colorWithRed:0.05 green:0.1 blue:0.1 alpha:1.0];
    
    // Attributes
    self.view.backgroundColor = [UIColor blackColor];
    self.houghTouchView.backgroundColor = [UIColor blackColor];
    self.houghInputView.backgroundColor = bgColor;
    self.houghInputView.pointsColor     = [UIColor whiteColor];

    [self.clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.clearButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.85 alpha:1.0]];
                                
    self.houghInputView.layer.cornerRadius = 5;
    self.houghTouchView.layer.cornerRadius = 5;
    self.clearButton.layer.cornerRadius    = 3;
    
    self.houghTouchView.layer.borderWidth = 2;
    self.houghTouchView.layer.borderColor = borderColor.CGColor;
    
    self.houghInputView.layer.borderWidth = 2;
    self.houghInputView.layer.borderColor = borderColor.CGColor;
    
    self.lineDelegate.lineColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.3 alpha:1.0];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    [self layoutViews];
        
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
	
	self.houghInputView	= nil;
	self.houghTouchView = nil;
    self.clearButton    = nil;
    self.status         = nil;
	self.hough          = nil;
    self.lineLayer      = nil;
    self.lineDelegate   = nil;

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
