//
//  HoughDemoViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughDemoViewController.h"
#import "Hough.h"
#import "HoughFreeHandViewController.h"
#import "HoughLineOverlayDelegate.h"
#import "UIColor+HoughExtensions.h"
#import "HoughSettingsViewController.h"
#import "HoughImageViewController.h"
#import <objc/runtime.h>

@interface HoughDemoViewController ()
-(void)layoutViews;
@end

@implementation HoughDemoViewController
@synthesize tabBar;
@synthesize freehandVC;
@synthesize imageVC;

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
//    tabBar.
    
    [self.view addSubview:tabBar.view];
    
    freehandVC = [[HoughFreeHandViewController alloc] init];
    freehandVC.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Freehand" image:[UIImage imageNamed:@"gear.png"] tag:0] autorelease];
    freehandVC.tabBarItem.badgeValue = @"F";
    
    imageVC = [[HoughImageViewController alloc] init];
    imageVC.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Image" image:[UIImage imageNamed:@"gear.png"] tag:1] autorelease];
    imageVC.tabBarItem.badgeValue = @"I";
    
    NSArray* vcs = [NSArray arrayWithObjects:freehandVC, imageVC, nil];
    
    [tabBar setViewControllers:vcs animated:NO];
   
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) ;
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
    
    self.tabBar     = nil;
    self.freehandVC = nil;
    self.imageVC    = nil;
    
    [super dealloc];
}



@end
