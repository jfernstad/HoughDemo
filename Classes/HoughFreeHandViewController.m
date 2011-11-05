//
//  HoughFreeHandViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/3/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughFreeHandViewController.h"
#import "FreeHandConfigurationView.h"
#import "HoughLineOverlayDelegate.h"
#import "UIColor+HoughExtensions.h"
#import "NotificationView.h"
#import "HoughConstants.h"
#import "IntersectionLinkedList.h"
#import "PointLinkedList.h"

@interface HoughFreeHandViewController ()
-(void)layoutViews;
-(void)interactionMode:(id)sender;
-(void)startAnalysis:(NSTimer*)timer;
-(void)startAnalysisTimer;
-(void)stopAnalysisTimer;
@end

@implementation HoughFreeHandViewController
@synthesize houghInputView;
@synthesize houghTouchView;
@synthesize busy;
@synthesize pointAdded;
@synthesize persistentTouch;
@synthesize readyForAnalysis;
@synthesize shouldAnalyzeAutomatically;
@synthesize status;
@synthesize lineLayer;
@synthesize circleLayer;
@synthesize lineDelegate;
@synthesize circleDelegate;
@synthesize confView;

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

    // TODO: Load and set parameters for Hough here.
    self.hough.houghThreshold     = 10;
    self.hough.maxHoughInput      = 1000;
    self.hough.colorSpace         = [self.hough createColorSpaceSmall];
    self.hough.operationDelegate  = self;
    self.houghInputView.houghRef  = self.hough;
    self.houghTouchView.houghRef  = self.hough;
    
    self.persistentTouch = YES;
    self.houghInputView.persistentTouch = self.persistentTouch;

    // TODO: Read configuration parameters
    // setup shouldAnalyzeAutomatically here
    self.shouldAnalyzeAutomatically = YES;
    
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
    
    UILabel* lbl = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont boldSystemFontOfSize:20];
    lbl.textColor = [UIColor whiteColor];
    lbl.text = @"Doodle";
    [lbl sizeToFit];
    
    titleItem.customView = lbl;

    
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
    
    // TODO: Remove/rewrite this test
    CGRect confRect = contentRect;
    confRect.size.height = 100;
    self.confView = [[[FreeHandConfigurationView alloc] initWithFrame:confRect] autorelease];
    self.confView.delegate = self;
    [self.view addSubview:self.confView];

    [self.view bringSubviewToFront:self.toolBar];
}

-(void)layoutViews{
    
    UIColor* borderColor = [UIColor borderColor];
    
    // Attributes
    self.houghTouchView.backgroundColor = [UIColor houghBackgroundColor];
    self.houghInputView.backgroundColor = [UIColor inputBackgroundColor];
    self.houghInputView.pointsColor     = [UIColor whiteColor];
    
    self.houghTouchView.layer.borderWidth   = EDGE_WIDTH;
    self.houghInputView.layer.borderWidth   = EDGE_WIDTH;
    self.houghTouchView.layer.cornerRadius  = CORNER_RADIUS;
    self.houghInputView.layer.cornerRadius  = CORNER_RADIUS;
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
    
    [self startAnalysisTimer];
    
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
    self.confView       = nil;
    self.status         = nil;
    self.lineLayer      = nil;
    self.lineDelegate   = nil;
    
    modeControl = nil;
    
    [analysisTimer invalidate];
    
    [super dealloc];
}

#pragma mark - Timer related

-(void)startAnalysis:(NSTimer*)timer{
    if (self.shouldAnalyzeAutomatically && !self.busy && self.pointAdded && self.readyForAnalysis) {
        //DLog(@"Executing analysis.");
        
        self.readyForAnalysis = NO;
        self.pointAdded = NO;
        [self.hough performSelectorInBackground:@selector(analyzeHoughSpaceOp) withObject:nil];
    }
}

-(void)startAnalysisTimer{
    analysisTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(startAnalysis:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:analysisTimer forMode:NSDefaultRunLoopMode];
}
-(void)stopAnalysisTimer{
    [analysisTimer invalidate];
    analysisTimer = nil;
}

#pragma mark - Delegates

-(void)updateInputWithPoints:(PointLinkedList*)points{
	// If we are not busy drawing the hough, update the input. 
	
    [points retain];
    CGImageRef img = nil;
	
	NSDate* start;
	NSTimeInterval imgCreation;
	
    // TODO: Save points temporarily, draw them when hough isn't busy anymore.
    
	if (!self.busy && points.size > 0) {
		
		self.busy = YES;
		
        start = [NSDate date];
		img   = [hough newHoughSpaceFromPoints:points persistent:self.persistentTouch];
		imgCreation = [start timeIntervalSinceNow];

        // Show hough image
		self.houghTouchView.layer.contents = (id)img;
        self.lineDelegate.imgSize = self.houghTouchView.frame.size;

		CGImageRelease(img);

        self.pointAdded = YES;
		self.busy = NO;
	}
#ifdef DEBUG
	else {
        if (self.busy) {
            DLog(@" BUSY! Not finished with previous image");
        }
//        else{
//            DLog(@" No points to add");
//        }
	}
#endif
    
    [points release];
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

//    NSArray* filteredArray = [self.hough allIntersections];
    IntersectionLinkedList* filteredArray = [self.hough allIntersections];
    [self.bucket clearBuckets];
    
    // Add points to buckets
    [self.bucket addIntersections:filteredArray];

     // calc COGs for all buckets
    NSArray* cogLines = [self.bucket cogIntersectionsForAllBuckets];
    
    [self overlayLines:cogLines];
    self.readyForAnalysis = YES;
}

-(void)updateConfigurationWithDictionary:(NSDictionary*)changedValues{
    NSNumber* analysisModeChanged = [changedValues objectForKey:kHoughAnalysisModeChanged];
    NSNumber* drawModeChanged     = [changedValues objectForKey:kHoughDrawModeChanged];
    NSNumber* thresholdChanged    = [changedValues objectForKey:kHoughThresholdChanged];

    if (analysisModeChanged) {
        if ([analysisModeChanged boolValue]) {
            [self startAnalysisTimer];
            self.shouldAnalyzeAutomatically = YES;
        }
        else{
            [self stopAnalysisTimer];
            self.shouldAnalyzeAutomatically = NO;
        }
    }

    if (drawModeChanged) {
        self.persistentTouch = [drawModeChanged boolValue];
        self.houghInputView.persistentTouch = self.persistentTouch;

        NSString* notificationString = (self.persistentTouch)?@"Multi point mode":@"Single point mode";
        
        [NotificationView showText:notificationString inView:self.view];
    }
    
    if (thresholdChanged) {
        self.hough.houghThreshold = [thresholdChanged integerValue];
        self.pointAdded = YES;
        DLog(@"%@", thresholdChanged);
    }
    
}
@end
