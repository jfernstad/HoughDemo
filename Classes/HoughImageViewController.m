//
//  HoughImageViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughImageViewController.h"
#import "UIColor+HoughExtensions.h"
#import "HoughLineOverlayDelegate.h"

@interface HoughImageViewController ()
-(void)showChooseImageView;
-(void)centerImage;
@end

@implementation HoughImageViewController
@synthesize imgView;
@synthesize imgPicker;
@synthesize popover;
@synthesize lineLayer;
@synthesize lineDelegate;

- (void)dealloc
{
    self.imgView = nil;
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
    
    self.imgView = [[[UIImageView alloc] initWithFrame:totalRect] autorelease];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.view.backgroundColor = [UIColor clearColor];

    self.hough.size = totalRect.size; // Setup hough size, WRONG. Do this for the image instead. 
    self.hough.operationDelegate = self;
    self.hough.yScale = 1;

    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.loadingView.text = @"Loading image... ";

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

-(void)centerImage{
    CGSize imgSize    = self.imgView.image.size;
    CGRect newImgRect = self.contentRect;

    CGFloat scale = MAX(imgSize.width/newImgRect.size.width,imgSize.height/newImgRect.size.height);

    imgSize.width  /= scale;
    imgSize.height /= scale;

    newImgRect.origin.x = (newImgRect.size.width  - imgSize.width )/2;
    newImgRect.origin.y = newImgRect.origin.y + (newImgRect.size.height - imgSize.height)/2;

    newImgRect.size = imgSize;

    self.imgView.frame = CGRectIntegral(newImgRect);

    self.lineLayer.frame = self.imgView.bounds;
    self.lineDelegate.imgSize = self.imgView.bounds.size;
}

#pragma mark -
#pragma mark Delegates

-(void)houghWillBeginOperation:(NSString*)operation{
    self.loadingView.text = [NSString stringWithFormat:@"Starting %@...", operation];
//    NSLog(@"houghWillBeginOperation: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");
}
-(void)houghDidFinishOperationWithDictionary:(NSDictionary*)dict{ // Operation in kOperationNameKey
    self.loadingView.text = [NSString stringWithFormat:@"Finished operation %@...", [dict objectForKey:kOperationNameKey]];
    
//    NSLog(@"houghDidFinishOperationWithDictionary: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");
//    NSLog(@"Intersections (%d): %@", [self.hough allIntersections].count, [self.hough allIntersections]);

    if ([dict objectForKey:kOperationUIImageKey]) {
        UIImage* img = (UIImage*)[dict objectForKey:kOperationUIImageKey];
        self.imgView.image = img;
        
        [self centerImage];
    }

    if ([[dict objectForKey:kOperationNameKey] isEqualToString:kOperationAnalyzeHoughSpace]) {
        // We got what we needed
        
        NSArray* intersections = nil;
        if ([dict objectForKey:kHoughIntersectionArrayKey]) {
            intersections = [dict objectForKey:kHoughIntersectionArrayKey];
            // Do the bucket thing
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

    // TEST: Execute operations using the operation queue
    
    selectedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (selectedImage) {
        [self.hough executeOperationsWithImage:selectedImage];
        self.imgView.image = selectedImage;

        [self centerImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    NSLog(@"popoverControllerDidDismissPopover");
}

@end
