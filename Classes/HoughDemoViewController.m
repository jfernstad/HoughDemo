//
//  HoughDemoViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughDemoViewController.h"
#import "Hough.h"
#import "HoughLineOverlayDelegate.h"
#import "UIColor+HoughExtensions.h"
#import "HoughSettingsViewController.h"
#import <objc/runtime.h>

@interface HoughDemoViewController ()
-(void)layoutViews;
@end

@implementation HoughDemoViewController
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
//    
//    // TODO: Put constants in enum
//    
    
    
    self.view           = [[[UIView alloc] initWithFrame:totalRect] autorelease];
    
    tabBar              = [[UITabBarController alloc] init];
    
    [self.view addSubview:tabBar.view];
    
    NSArray* vcs = [NSArray arrayWithObject:[[[HoughFreeHandViewController alloc] init] autorelease]];
    
    [tabBar setViewControllers:vcs animated:NO];
    
//    self.toolBar        = [[[UIToolbar alloc] initWithFrame:navRect] autorelease];
//    self.houghTouchView = [[[HoughTouchView alloc] initWithFrame:touchRect] autorelease];
//    self.houghInputView = [[[HoughInputView alloc] initWithFrame:inputRect] autorelease];
//    self.status         = [[[UILabel alloc] initWithFrame:statusRect] autorelease];
//    
//    self.hough = [[[Hough alloc] init] autorelease];
//    self.hough.interactionMode = kFreeHandDraw; // TODO: Parameterize
//    self.houghInputView.houghRef = self.hough;
//    
//    // TODO: Subclass UINavigationItem 
//    //UINavigationItem* item = [[[UINavigationItem alloc] initWithTitle:@"Free hand"] autorelease];
//    
//    // TODO: Clean this mess up..
//    UIBarButtonItem* settingsItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"]
//                                                                      style:UIBarButtonItemStylePlain
//                                                                     target:self
//                                                                     action:@selector(showSettingsView)] autorelease];
//    
//    UIBarButtonItem* clearItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
//                                                                                target:self
//                                                                                action:@selector(clear)] autorelease];
//
//    UIBarButtonItem* spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace
//                                   target:nil
//                                   action:nil] autorelease];
//    
////    spaceItem.width = 200;
//    
//    [self.toolBar setItems:[NSArray arrayWithObjects:settingsItem, spaceItem, clearItem, nil] animated:YES];
//    
//    self.hough.size = self.houghTouchView.frame.size;
//	self.houghInputView.delegate = self;
//	self.houghTouchView.delegate = self;
//    
//    self.lineDelegate = [[[HoughLineOverlayDelegate alloc] init] autorelease];
//    self.lineLayer = [CALayer layer];
//    self.lineLayer.frame = self.houghInputView.bounds;
//    self.lineLayer.delegate = self.lineDelegate;
//    
//    self.circleDelegate = [[[CircleOverlayDelegate alloc] init] autorelease];
//    self.circleLayer = [CALayer layer];
//    self.circleLayer.frame = self.houghTouchView.bounds;
//    self.circleLayer.delegate = self.circleDelegate;
//    
//    [self.houghInputView.layer addSublayer:self.lineLayer];
//    [self.houghTouchView.layer addSublayer:self.circleLayer];
//    
//    
//    // Size/position
//    //    self.status.frame = statusRect;
//    //    self.houghInputView.frame = inputRect;
//    //    self.houghTouchView.frame = touchRect;
//    
//    [self.view addSubview:self.toolBar];
//    [self.view addSubview:self.houghTouchView];
//    [self.view addSubview:self.houghInputView];
//    [self.view addSubview:self.status];
    
}

-(void)layoutViews{
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutViews];
    
//	self.busy = NO;
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
    
    [super dealloc];
}



@end
