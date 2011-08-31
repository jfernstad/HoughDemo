//
//  HoughFreeHandViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/3/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughFreeHandViewController.h"
#import "HoughLineOverlayDelegate.h"
#import "UIColor+HoughExtensions.h"
#import "NotificationView.h"

@interface HoughFreeHandViewController ()
-(void)layoutViews;
-(void)interactionMode:(id)sender;
-(void)startAnalysis:(NSTimer*)timer;
@end

@implementation HoughFreeHandViewController
@synthesize houghInputView;
@synthesize houghTouchView;
@synthesize busy;
@synthesize pointAdded;
@synthesize persistentTouch;
@synthesize readyForAnalysis;
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

-(void)startAnalysis:(NSTimer*)timer{
    if (!self.busy && self.pointAdded && self.readyForAnalysis) {
        //NSLog(@"Executing analysis.");

        self.readyForAnalysis = NO;
        self.pointAdded = NO;
        [self.hough performSelectorInBackground:@selector(analyzeHoughSpaceOp) withObject:nil];
    }
}

- (void)loadView {
    
    [super loadView];
    
    CGRect totalRect  = self.contentRect;
    CGRect touchRect  = CGRectZero;
    CGRect inputRect  = CGRectZero;
    CGRect statusRect = CGRectZero;
    CGRect tileRect   = CGRectZero;
    
    // TODO: Put constants in enum
    tileRect = totalRect;
    CGRectDivide(tileRect,  &touchRect,  &inputRect,  450, CGRectMinYEdge);
    CGRectDivide(inputRect,  &inputRect,  &statusRect, 450, CGRectMinYEdge);

    inputRect = CGRectOffset(inputRect, 0, 20);
    touchRect = CGRectOffset(touchRect, 0, 20);
    
    touchRect = CGRectInset(touchRect, 15, 15);
    inputRect = CGRectInset(inputRect, 15, 15);
    
    statusRect = CGRectZero; // Hide this one for now.
    
    self.houghTouchView = [[[HoughTouchView alloc] initWithFrame:touchRect] autorelease];
    self.houghInputView = [[[HoughInputView alloc] initWithFrame:inputRect] autorelease];
    
    CGRect tmpRect    = CGRectZero;
    CGRectDivide(tileRect, &tmpRect, &tileRect, 50, CGRectMaxYEdge);

    self.hough.operationDelegate = self;
    self.houghInputView.houghRef = self.hough;
    self.houghTouchView.houghRef = self.hough;
    
    self.persistentTouch = YES;
    self.houghInputView.persistentTouch = self.persistentTouch;

    // TODO: Clean this mess up..
    modeControl = [[[UISegmentedControl alloc] initWithItems:
                                        [NSArray arrayWithObjects:@"  Draw  ", @"  Tap  ", nil]] autorelease];
    
    modeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    modeControl.tintColor = [UIColor houghGreen];
    
    [modeControl setSelectedSegmentIndex:(self.persistentTouch)?0:1];
    [modeControl addTarget:self
                    action:@selector(interactionMode:)
          forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem* selectionItem = [[[UIBarButtonItem alloc] initWithCustomView:modeControl] autorelease];
    
//    UIBarButtonItem* settingsItem  = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"]
//                                                                       style:UIBarButtonItemStylePlain
//                                                                      target:self
//                                                                      action:@selector(showSettingsView)] autorelease];
    
    UIBarButtonItem* clearItem     = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                    target:self
                                                                                    action:@selector(clear)] autorelease];
    
    UIBarButtonItem* titleItem     = [[[UIBarButtonItem alloc] initWithTitle:@"Free hand" 
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:nil
                                                                      action:nil] autorelease];
    
    UIBarButtonItem* spaceItem     = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil] autorelease];
    
    UIBarButtonItem* fixSpaceItem  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil] autorelease];

    UIBarButtonItem* fixSpaceItem2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil] autorelease];
    
    selectionItem.possibleTitles = [NSSet setWithObjects:@"Draw", @"Tap", @"long titel", nil];
    fixSpaceItem.width  = 330;
    fixSpaceItem2.width = 30;
    
    // -- 
    [self.toolBar setItems:[NSArray arrayWithObjects:fixSpaceItem, titleItem, spaceItem, selectionItem, fixSpaceItem2, clearItem, nil] animated:YES];
    
    self.hough.size = self.houghTouchView.frame.size;
	self.houghInputView.delegate = self;
	self.houghTouchView.delegate = self;
    
    self.lineDelegate        = [[[HoughLineOverlayDelegate alloc] init] autorelease];
    self.lineDelegate.houghRef = self.hough;
    self.lineLayer           = [CALayer layer];
    self.lineLayer.frame     = self.houghInputView.bounds;
    self.lineLayer.delegate  = self.lineDelegate;
    
    self.circleDelegate       = [[[CircleOverlayDelegate alloc] init] autorelease];
    self.circleLayer          = [CALayer layer];
    self.circleLayer.frame    = self.houghTouchView.bounds;
    self.circleLayer.delegate = self.circleDelegate;
    
    [self.houghInputView.layer addSublayer:self.lineLayer];
    [self.houghTouchView.layer addSublayer:self.circleLayer];
    
    [self.view addSubview:self.houghTouchView];
    [self.view addSubview:self.houghInputView];
}

-(void)layoutViews{
    
    UIColor* borderColor = [UIColor borderColor];
    
    // Attributes
    self.houghTouchView.backgroundColor = [UIColor houghBackgroundColor];
    self.houghInputView.backgroundColor = [UIColor inputBackgroundColor];
    self.houghInputView.pointsColor     = [UIColor whiteColor];
    
    self.houghTouchView.layer.borderWidth   = 2;
    self.houghInputView.layer.borderWidth   = 2;
    self.houghTouchView.layer.cornerRadius  = 10;
    self.houghInputView.layer.cornerRadius  = 10;
    self.houghTouchView.layer.masksToBounds = YES;
    self.houghInputView.layer.masksToBounds = YES;
    self.houghTouchView.layer.borderColor   = borderColor.CGColor;
    self.houghInputView.layer.borderColor   = borderColor.CGColor;
    
    self.lineDelegate.lineColor   = [UIColor lineColor];
    self.circleDelegate.markColor = [UIColor markColor];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutViews];

    // TODO: Manage this from button instead
    
    analysisTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(startAnalysis:) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:analysisTimer forMode:NSDefaultRunLoopMode];
	self.busy = NO;
    self.readyForAnalysis = YES;
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

//- (void)viewDidUnload {
//	// Release any retained subviews of the main view.
//	// e.g. self.myOutlet = nil;
//}


- (void)dealloc {
	
	self.houghInputView	= nil;
	self.houghTouchView = nil;
    self.status         = nil;
    self.lineLayer      = nil;
    self.lineDelegate   = nil;
    
    modeControl = nil;
    
    [analysisTimer invalidate];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Delegates

-(void)updateInputWithPoints:(NSArray*)pointArray{
	// If we are not busy drawing the hough, update the input. 
	
    CGImageRef img = nil;
	
	NSDate* start;
	NSTimeInterval imgCreation;
	
    // TODO: Save points temporarily, draw them when hough isn't busy anymore.
    
	if (!self.busy) {
		
		self.busy = YES;
		
        start = [NSDate date];
		img   = [hough newHoughSpaceFromPoints:pointArray persistent:self.persistentTouch];
		imgCreation = [start timeIntervalSinceNow];

        // Show hough image
		self.houghTouchView.layer.contents = (id)img;
        self.lineDelegate.imgSize = self.houghTouchView.frame.size;

		CGImageRelease(img);

        self.pointAdded = YES;
		self.busy = NO;
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
    [self.bucket clearBuckets];
    
    self.lineDelegate.lines = nil;
    self.circleDelegate.points = nil;
	[self.lineLayer setNeedsDisplay];
    [self.circleLayer setNeedsDisplay];
    
    [NotificationView showText:@"Clear canvas" inView:self.view];
}

- (void)interactionMode:(id)sender{
    
    self.persistentTouch = (modeControl.selectedSegmentIndex == 0);
    self.houghInputView.persistentTouch = self.persistentTouch;
    
    NSString* notificationString = (modeControl.selectedSegmentIndex == 0)?@"Multi point mode":@"Single point mode";
    
    [NotificationView showText:notificationString inView:self.view];
}

-(void)houghWillBeginOperation:(NSString*)operation{
}
-(void)houghDidFinishOperationWithDictionary:(NSDictionary*)dict{ // Operation in kOperationNameKey

    NSArray* filteredArray = [self.hough allIntersections];
    [self.bucket clearBuckets];
    
    // Add points to buckets
    [self.bucket addIntersections:filteredArray];

     // calc COGs for all buckets
    NSArray* cogLines = [self.bucket cogIntersectionsForAllBuckets];
    
    [self overlayLines:cogLines];
    self.readyForAnalysis = YES;
}

@end
