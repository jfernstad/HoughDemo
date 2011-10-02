//
//  HoughImageViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughImageViewController.h"
#import "UIColor+HoughExtensions.h"
#import "CGGeometry+HoughExtensions.h"
#import "HoughLineOverlayDelegate.h"
#import "HoughConstants.h"

@interface HoughImageViewController ()
-(void)showChooseImageView;
-(CGSize)aspectFitSize:(CGSize)inputSize inSize:(CGSize)parentSize;
-(CGRect)centerRect:(CGRect)inputRect inRect:(CGRect)parentRect;
-(void)centerImage;
@end

@implementation HoughImageViewController
@synthesize imgView;
@synthesize histoView;
@synthesize imgPicker;
@synthesize popover;
@synthesize lineLayer;
@synthesize lineDelegate;

- (void)dealloc
{
    self.imgView = nil;
    self.histoView = nil;
    self.imgPicker = nil;
    self.popover = nil; // TODO: Keep an eye on this 
    self.lineLayer = nil;
    self.lineDelegate = nil;

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

#pragma mark Properties

-(UIImagePickerController*)imgPicker{
    if (!imgPicker) {
        imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.delegate = self;
    }
    return imgPicker;
}

-(UIPopoverController*)popover{
    if (!popover) {
        popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
        popover.delegate = self;
    }
    return popover;
}



#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    CGRect totalRect  = self.contentRect;
    CGRect histoRect   = CGRectMake(0, 100, 200, 500);
    
    self.imgView = [[[UIImageView alloc] initWithFrame:totalRect] autorelease];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.view.backgroundColor = [UIColor clearColor];

    self.histoView = [[[HistogramView alloc] initWithFrame:histoRect] autorelease];
    self.histoView.useComponents    = EPixelBufferGreen;
    self.histoView.logHistogram     = NO;
    self.histoView.stretchHistogram = YES;
    self.histoView.histogramColor   = [UIColor colorWithWhite:1 alpha:0.7];
    
    self.hough.size = totalRect.size; // Setup hough size, WRONG. Do this for the image instead. 
    self.hough.operationDelegate = self;
    self.hough.yScale = 1;
    self.hough.maxHoughInput = 1000;
    self.hough.houghThreshold = 20;
    self.hough.grayscaleThreshold = 250;
    
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.loadingView.text = @"Loading image... ";
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    
    self.imgView.backgroundColor = [UIColor clearColor]; // mainBackgroundColor
    
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
    
    [self.toolBar setItems:[NSArray arrayWithObjects:fixSpaceItem, titleItem, flexSpaceItem, actionItem, nil] animated:YES];

    
    self.lineDelegate        = [[[HoughLineOverlayDelegate alloc] init] autorelease];
    self.lineDelegate.houghRef = self.hough;
    self.lineDelegate.lineColor = [UIColor houghRed];
    self.lineDelegate.imgSize= self.imgView.image.size;
    self.lineLayer           = [CALayer layer];
    self.lineLayer.frame     = CGRectZero; // Set this when we get an image. 
    self.lineLayer.delegate  = self.lineDelegate;
    self.lineLayer.masksToBounds = YES;
    
    self.view.backgroundColor           = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tile_50px.png"]];

    [self.imgView.layer addSublayer:self.lineLayer];

    [self.view addSubview:self.imgView];
    [self.view addSubview:self.histoView];
}
-(void)showChooseImageView{
    // TODO: Load popover with settings view

    self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self.popover presentPopoverFromBarButtonItem:[self.toolBar.items objectAtIndex:self.toolBar.items.count-1] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) viewDidAppear:(BOOL)animated{
    if (!imgView.image) {
        [self performSelector:@selector(showChooseImageView) withObject:nil afterDelay:0.0];
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

//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark - Convenience methods
-(CGSize)aspectFitSize:(CGSize)inputSize inSize:(CGSize)parentSize{
    CGSize outSize = CGSizeZero;
    CGFloat scale = MAX(inputSize.width/parentSize.width,
                        inputSize.height/parentSize.height);
    
    outSize.width  = inputSize.width /scale;
    outSize.height = inputSize.height/scale;

    return outSize;
}
-(CGRect)centerRect:(CGRect)inputRect inRect:(CGRect)parentRect{
    CGRect outRect = inputRect;
    outRect.origin.x = parentRect.origin.x + (parentRect.size.width  - inputRect.size.width )/2;
    outRect.origin.y = parentRect.origin.y + (parentRect.size.height - inputRect.size.height)/2;
    return outRect;
}

-(void)centerImage{
    CGRect imgRect    = CGRectZero;
    CGRect newImgRect = self.contentRect;

    imgRect.size = self.imgView.image.size;

    imgRect.size = CGSizeAspectFitSize(imgRect.size, newImgRect.size);
    newImgRect   = CGRectCenteredInRect(newImgRect, imgRect.size);

    newImgRect.size = imgRect.size;

    self.imgView.frame = CGRectIntegral(newImgRect);

    self.lineLayer.frame = self.imgView.bounds;
    self.lineDelegate.imgSize = self.imgView.bounds.size;
}

#pragma mark -
#pragma mark Delegates

-(void)houghWillBeginOperation:(NSString*)operation{
    self.loadingView.text = [NSString stringWithFormat:@"Starting %@...", operation];
}
-(void)houghDidFinishOperationWithDictionary:(NSDictionary*)dict{ // Operation in kOperationNameKey
    self.loadingView.text = [NSString stringWithFormat:@"Finished operation %@...", [dict objectForKey:kOperationNameKey]];
    
    if ([dict objectForKey:kOperationUIImageKey]) {
        UIImage* img = (UIImage*)[dict objectForKey:kOperationUIImageKey];
        self.imgView.image = img;
        
        [self centerImage];
    }

    if ([[dict objectForKey:kOperationNameKey] isEqualToString:kOperationAnalyzeHoughSpace]) {
        // We got what we needed
        
        // TODO: Make this an operation instead. Might block interface.
        NSArray* intersections = nil;
        if ([dict objectForKey:kHoughIntersectionArrayKey]) {
            intersections = [dict objectForKey:kHoughIntersectionArrayKey];
            // Do the bucket thing
            [self.histoView executeWithImage:self.hough.HoughImage];
            [self.bucket clearBuckets];
            [self.bucket addIntersections:intersections];
            
            self.lineDelegate.lines = [self.bucket cogIntersectionsForAllBuckets];
            [self.lineLayer setNeedsDisplay];
        }
        
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

    NSString* fileURL = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
    selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (selectedImage) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedImageNotification object:fileURL];
        
        [self.hough executeOperationsWithImage:selectedImage];
        self.imgView.image = selectedImage;
        [self centerImage];

        // Clear old lines
        self.lineDelegate.lines = nil;
        [self.lineLayer setNeedsDisplay];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    NSLog(@"popoverControllerDidDismissPopover");
}

@end
