//
//  HoughImageViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughImageViewController.h"
#import "LoadingView.h"
#import "UIColor+HoughExtensions.h"
#import "Hough.h"
#import "HoughLineOverlayDelegate.h"

@interface HoughImageViewController ()
-(void)showChooseImageView;
@end

@implementation HoughImageViewController
@synthesize toolBar;
@synthesize imgView;
@synthesize placeHolder;
@synthesize hough;
@synthesize imgPicker;
@synthesize popover;
@synthesize loadingView;
@synthesize lineLayer;
@synthesize lineDelegate;
@synthesize bucket;

- (void)dealloc
{
    self.hough = nil;
    self.toolBar = nil;
    self.imgView = nil;
    self.imgPicker = nil;
    self.placeHolder = nil;
    self.popover = nil; // TODO: Keep an eye on this 
    self.loadingView = nil;
    self.lineLayer = nil;
    self.lineDelegate = nil;
    
    [self.bucket clearBuckets];
    self.bucket = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Methods
-(void)cancelOperations{
    [self.hough cancelOperations];
    [self.loadingView stopProgress];
}


#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{

    CGRect totalRect  = [UIScreen mainScreen].applicationFrame;
    CGRect navRect    = CGRectZero;
    CGRect imgRect    = CGRectZero;
    CGRect tmpRect    = CGRectZero;

    CGRectDivide(totalRect, &navRect, &imgRect, 50, CGRectMinYEdge);
    CGRectDivide(imgRect, &tmpRect, &imgRect, 50, CGRectMaxYEdge);
    
    self.view    = [[[UIView alloc] initWithFrame:totalRect] autorelease];
    self.toolBar = [[[UIToolbar alloc] initWithFrame:navRect] autorelease];
    self.imgView = [[[UIImageView alloc] initWithFrame:imgRect] autorelease];
    self.loadingView = [[[LoadingView alloc] initWithFrame:imgRect] autorelease];
    
//    UIImageView* tilePattern = [[[UIImageView alloc] initWithFrame:imgRect] autorelease];
//    tilePattern.image = [UIImage imageNamed:@"tilepattern.png"];
//    UIImageView* tilePattern = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tilepattern.png"]] autorelease];
    
    
    self.view.backgroundColor = [UIColor clearColor];
    self.toolBar.tintColor = [UIColor toolbarTintColor];

    self.bucket = [[[Bucket2D alloc] init] autorelease];
    
    self.hough = [[[Hough alloc] init] autorelease];
//    self.hough.interactionMode   = kFreeHandDraw;// kManualInteraction;
    self.hough.size = imgRect.size; // Setup hough size, WRONG. Do this for the image instead. 
    self.hough.operationDelegate = self;

    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.loadingView.text = @"Loading image... ";
    // --- START OF TEMPORARY STUFF ---

    CGRect textRect = CGRectZero;
    
    self.placeHolder = [[[UILabel alloc] initWithFrame:textRect] autorelease];
    self.placeHolder.numberOfLines = 2;
    self.placeHolder.lineBreakMode = UILineBreakModeWordWrap;
    self.placeHolder.font = [UIFont fontWithName:@"Courier" size:32];
    self.placeHolder.textColor = [UIColor houghWhite];
    self.placeHolder.backgroundColor = [UIColor houghLightGreen];
    
    self.placeHolder.text = @"TODO: Fill this screen with awesome stuff!";
    
    CGSize rs = [self.placeHolder.text sizeWithFont:[UIFont fontWithName:@"Courier" size:32]
                          constrainedToSize:CGSizeMake(500, 400)
                              lineBreakMode:UILineBreakModeWordWrap];
    
    textRect.origin = CGPointMake((totalRect.size.width - rs.width)/2, (totalRect.size.height - rs.height)/2);
    textRect.size = rs;
    
    self.placeHolder.frame = textRect;
    
    self.imgView.backgroundColor = [UIColor clearColor]; // mainBackgroundColor
    
    // --- END OF TEMPORARY STUFF ---
    
    UIBarButtonItem* actionItem    = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                    target:self
                                                                                    action:@selector(showChooseImageView)] autorelease];

    UIBarButtonItem* titleItem     = [[[UIBarButtonItem alloc] initWithTitle:@"Image" 
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:nil
                                                                      action:nil] autorelease];

    UIBarButtonItem* flexSpaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil] autorelease];
    UIBarButtonItem* fixSpaceItem  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:nil
                                                                                    action:nil] autorelease];
    fixSpaceItem.width = 350;
//    titleItem.enabled = NO;
    
    // -- 
    [self.toolBar setItems:[NSArray arrayWithObjects:fixSpaceItem, titleItem, flexSpaceItem, actionItem, nil] animated:YES];

    
    self.lineDelegate        = [[[HoughLineOverlayDelegate alloc] init] autorelease];
    self.lineDelegate.houghRef = self.hough;
    self.lineDelegate.lineColor = [UIColor houghRed];
    self.lineLayer           = [CALayer layer];
    self.lineLayer.frame     = CGRectZero; // Set this when we get an image. 
    self.lineLayer.delegate  = self.lineDelegate;
    self.lineLayer.masksToBounds = YES;
    
//    self.view.backgroundColor = [UIColor mainBackgroundColor];
    self.view.backgroundColor           = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile_50px.png"]];

    [self.imgView.layer addSublayer:self.lineLayer];
    
    [self.view addSubview:self.toolBar];
//    [self.view addSubview:tilePattern];
    [self.view addSubview:self.imgView];
    
//    [self.view addSubview:self.placeHolder];
    [self.view addSubview:self.loadingView];

}
-(void)showChooseImageView{
    // TODO: Load popover with settings view

    if (!self.imgPicker) {
        self.imgPicker = [[[UIImagePickerController alloc] init] autorelease];
        self.imgPicker.delegate = self;
    }

    if (!self.popover) {
        self.popover = [[[UIPopoverController alloc] initWithContentViewController:imgPicker] autorelease];
        self.popover.delegate = self;
        NSLog(@"recreating popover");
    }
    
    self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self.popover presentPopoverFromBarButtonItem:[self.toolBar.items objectAtIndex:self.toolBar.items.count-1] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) viewDidAppear:(BOOL)animated{
    if (!imgView.image) {
        [self showChooseImageView];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [self cancelOperations];
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

#pragma mark -
#pragma mark Delegates

-(void)houghWillBeginOperation:(NSString*)operation{
    self.loadingView.text = [NSString stringWithFormat:@"Starting %@...", operation];
    NSLog(@"houghWillBeginOperation: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");
}
-(void)houghDidFinishOperationWithDictionary:(NSDictionary*)dict{ // Operation in kOperationNameKey
    self.loadingView.text = [NSString stringWithFormat:@"Finished operation %@...", [dict objectForKey:kOperationNameKey]];
    
    NSLog(@"houghDidFinishOperationWithDictionary: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");
//    NSLog(@"Intersections (%d): %@", [self.hough allIntersections].count, [self.hough allIntersections]);

    if ([[dict objectForKey:kOperationNameKey] isEqualToString:kOperationAnalyzeHoughSpace]) {
        // We got what we needed
        
        // To the bucket thing
        [self.bucket clearBuckets];
        [self.bucket addIntersections:[self.hough allIntersections]];
        
        self.lineDelegate.lines = [self.bucket cogIntersectionForAllBuckets];
        
        [self.lineLayer setNeedsDisplay];
        [self.loadingView stopProgress];
    }
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"info: %@", info);
    UIImage* selectedImage = nil;
    
    // Close picker
    // Show image
    // Start processing
    [self.popover dismissPopoverAnimated:YES];
    [self.loadingView startProgress];
//    [self.loadingView performSelector:@selector(stopProgress) withObject:nil afterDelay:5.0]; // TODO: Remove this after implementing the operations

    // TEST: Execute operations using the operation queue
    
    selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (selectedImage) {
        [self.hough executeOperationsWithImage:selectedImage];
        self.imgView.image = selectedImage;
        self.hough.size = self.imgView.bounds.size;
        self.lineLayer.frame = self.imgView.bounds;
        [self.placeHolder removeFromSuperview];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    NSLog(@"popoverControllerDidDismissPopover");
}

@end
