//
//  HoughFreeHandViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/3/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughFreeHandViewController.h"
#import "Hough.h"
#import "HoughLineOverlayDelegate.h"
#import "UIColor+HoughExtensions.h"
#import "HoughSettingsViewController.h"
#import <objc/runtime.h>

@interface HoughFreeHandViewController ()
-(void)layoutViews;
-(void)showSettingsView;
-(void)interactionMode:(id)sender;
@end

@implementation HoughFreeHandViewController
@synthesize houghInputView;
@synthesize houghTouchView;
@synthesize hough;
@synthesize busy;
@synthesize status;
@synthesize lineLayer;
@synthesize circleLayer;
@synthesize lineDelegate;
@synthesize circleDelegate;
@synthesize toolBar;
//@synthesize settingsViewController;

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
    CGRect navRect    = CGRectZero;
    CGRect touchRect  = CGRectZero;
    CGRect inputRect  = CGRectZero;
    CGRect statusRect = CGRectZero;
    
    // TODO: Put constants in enum
    
    CGRectDivide(totalRect,  &navRect, &touchRect,  50, CGRectMinYEdge);
    CGRectDivide(touchRect,  &touchRect,  &inputRect,  450, CGRectMinYEdge);
    CGRectDivide(inputRect,  &inputRect,  &statusRect, 450, CGRectMinYEdge);
    
    touchRect = CGRectInset(touchRect, 15, 15);
    inputRect = CGRectInset(inputRect, 15, 15);
    
    statusRect = CGRectZero; // Hide this one for now.
    
    self.view           = [[[UIView alloc] initWithFrame:totalRect] autorelease];
    self.toolBar        = [[[UIToolbar alloc] initWithFrame:navRect] autorelease];
    self.houghTouchView = [[[HoughTouchView alloc] initWithFrame:touchRect] autorelease];
    self.houghInputView = [[[HoughInputView alloc] initWithFrame:inputRect] autorelease];
//    self.status         = [[[UILabel alloc] initWithFrame:statusRect] autorelease];
    
    self.hough = [[[Hough alloc] init] autorelease];
    self.hough.interactionMode   = kFreeHandDraw; // TODO: Parameterize
    self.houghInputView.houghRef = self.hough;
    
    // TODO: Clean this mess up..
    UISegmentedControl* modeControl = [[[UISegmentedControl alloc] initWithItems:
                                        [NSArray arrayWithObjects:@"  Draw  ", @"  Tap  ", nil]] autorelease];
    
    modeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    modeControl.tintColor = [UIColor houghGreen];
    
    [modeControl setSelectedSegmentIndex:(hough.interactionMode==kFreeHandDraw)?0:1];
    [modeControl addTarget:self
                    action:@selector(interactionMode:)
          forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem* selectionItem = [[[UIBarButtonItem alloc] initWithCustomView:modeControl] autorelease];
    
    UIBarButtonItem* settingsItem  = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(showSettingsView)] autorelease];
    
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
    fixSpaceItem.width  = 250;
    fixSpaceItem2.width = 30;
    
    // -- 
    [self.toolBar setItems:[NSArray arrayWithObjects:settingsItem, fixSpaceItem, titleItem, spaceItem, selectionItem, fixSpaceItem2, clearItem, nil] animated:YES];
    
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
    
    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.houghTouchView];
    [self.view addSubview:self.houghInputView];
//    [self.view addSubview:self.status];
    
    
}

-(void)layoutViews{
    
    UIColor* borderColor = [UIColor borderColor];
    
    // Attributes
    self.view.backgroundColor           = [UIColor mainBackgroundColor];
    self.houghTouchView.backgroundColor = [UIColor houghBackgroundColor];
    self.houghInputView.backgroundColor = [UIColor inputBackgroundColor];
    self.houghInputView.pointsColor     = [UIColor whiteColor];
    self.toolBar.tintColor              = [UIColor toolbarTintColor];
    
    self.houghTouchView.layer.borderWidth   = 2;
    self.houghInputView.layer.borderWidth   = 2;
    self.houghTouchView.layer.cornerRadius  = 10;
    self.houghInputView.layer.cornerRadius  = 10;
    self.houghTouchView.layer.masksToBounds = YES;
    self.houghInputView.layer.masksToBounds = YES;
    self.houghTouchView.layer.borderColor   = borderColor.CGColor;
    self.houghInputView.layer.borderColor   = borderColor.CGColor;
    
    self.lineDelegate.lineColor   = [UIColor lineColor];
    self.circleDelegate.markColor = [UIColor lineColor];
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
    self.status         = nil;
	self.hough          = nil;
    self.lineLayer      = nil;
    self.lineDelegate   = nil;
    self.toolBar        = nil;
    
    [super dealloc];
}

#pragma mark -

-(void)showSettingsView{
    
    // TODO: Load popover with settings view
    HoughSettingsViewController* settings = [[[HoughSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    settings.houghRef = self.hough;
    
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:settings];
    
    [pop presentPopoverFromBarButtonItem:[toolBar.items objectAtIndex:0] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
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
		
        NSNumber* gestureState = objc_getAssociatedObject(pointArray, kHoughInputGestureState);
        objc_setAssociatedObject(pointArray, kHoughInputGestureState, nil, OBJC_ASSOCIATION_RETAIN); // Clear association
        
        if (hough.interactionMode == kFreeHandDots && [gestureState intValue] == (int)UIGestureRecognizerStateEnded) {
            [hough makePersistent]; // Store temporary image as 
        }
        
        start = [NSDate date];
		img   = [hough newHoughSpaceFromPoints:pointArray];
		imgCreation = [start timeIntervalSinceNow];
		
		self.busy = NO;
        
        // Show hough image
		self.houghTouchView.layer.contents = (id)img;
        
		CGImageRelease(img);
        
//		self.status.text = [NSString stringWithFormat:@"Time for Hough generation: %3.3f ms (%1.3f ms/curve)", -imgCreation*1000.0, -imgCreation*1000.0/((pointArray.count>0)?pointArray.count:1)];
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

- (void)interactionMode:(id)sender{
    
    hough.interactionMode = (((UISegmentedControl*)sender).selectedSegmentIndex == 0)?kFreeHandDraw:kFreeHandDots;
}

@end