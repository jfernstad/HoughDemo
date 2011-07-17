//
//  BaseViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 7/16/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughBaseViewController.h"
#import "Hough.h"
#import "Bucket2D.h"
#import "HoughLineOverlayDelegate.h"
#import "LoadingView.h"
#import "UIColor+HoughExtensions.h"

@implementation HoughBaseViewController
@synthesize hough;
@synthesize bucket;
@synthesize toolBar;
@synthesize contentRect;
@synthesize loadingView;

#define TOOLBAR_HEIGHT 50

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    CGRect totalRect  = [UIScreen mainScreen].applicationFrame;
    CGRect navRect    = CGRectZero;
    
    CGRectDivide(totalRect, &navRect, &contentRect, TOOLBAR_HEIGHT, CGRectMinYEdge);
    
    self.view = [[[UIView alloc] initWithFrame:totalRect] autorelease];
    self.toolBar.frame = navRect;

    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.loadingView];
    
    // View config
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile_50px.png"]];
    self.toolBar.tintColor    = [UIColor toolbarTintColor];
    self.loadingView.frame    = contentRect;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Properties

-(UIToolbar*)toolBar{
    if (!toolBar) {
        toolBar = [[UIToolbar alloc] init];
    }
    return toolBar;
}

-(Hough*)hough{
    if (!hough) {
        hough = [[Hough alloc] init];
    }
    return hough;
}

-(Bucket2D*)bucket{
    if (!bucket) {
        bucket = [[Bucket2D alloc] init];
    }
    return bucket;
}
-(LoadingView*)loadingView{
    if (!loadingView) {
        loadingView = [[LoadingView alloc] init];
    }
    return loadingView;
}
#pragma mark Cleanup

-(void)dealloc{
    
    self.hough  = nil;
    self.bucket = nil;
    self.contentRect = CGRectZero;
    
    [self.toolBar removeFromSuperview];
    self.toolBar = nil;
    
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    self.view = nil;
    
    [super dealloc];
}
@end
