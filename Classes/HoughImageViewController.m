//
//  HoughImageViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughImageViewController.h"
#import "UIColor+HoughExtensions.h"

@interface HoughImageViewController ()
-(void)showChooseImageView;
@end

@implementation HoughImageViewController
@synthesize toolBar;
@synthesize imgView;
@synthesize placeHolder;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)dealloc
{
    self.toolBar = nil;
    self.imgView = nil;
    self.placeHolder = nil;
    
    [super dealloc];
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
    CGRect imgRect    = CGRectZero;

    CGRectDivide(totalRect, &navRect, &imgRect, 50, CGRectMinYEdge);
    
    
    self.view    = [[[UIView alloc] initWithFrame:totalRect] autorelease];
    self.toolBar = [[[UIToolbar alloc] initWithFrame:navRect] autorelease];
    self.imgView = [[[UIImageView alloc] initWithFrame:imgRect] autorelease];
    
    self.view.backgroundColor = [UIColor houghGray];
    self.toolBar.tintColor = [UIColor toolbarTintColor];

    // --- START OF TEMPORARY STUFF ---

    CGRect textRect = CGRectZero;
    
    self.placeHolder = [[[UILabel alloc] initWithFrame:textRect] autorelease];
    self.placeHolder.numberOfLines = 2;
    self.placeHolder.lineBreakMode = UILineBreakModeWordWrap;
    self.placeHolder.font = [UIFont fontWithName:@"Courier" size:32];
    self.placeHolder.textColor = [UIColor houghGreen];
    self.placeHolder.backgroundColor = [UIColor clearColor];
    
    self.placeHolder.text = @"TODO: Fill this screen with awesome stuff!";
    
    CGSize rs = [self.placeHolder.text sizeWithFont:[UIFont fontWithName:@"Courier" size:32]
                          constrainedToSize:CGSizeMake(500, 400)
                              lineBreakMode:UILineBreakModeWordWrap];
    
    textRect.origin = CGPointMake((totalRect.size.width - rs.width)/2, (totalRect.size.height - rs.height)/2);
    textRect.size = rs;
    
//    textRect = CGRectInset(imgRect, 40, 40);
    
    self.placeHolder.frame = textRect;
    
    self.imgView.backgroundColor = [UIColor mainBackgroundColor];
    
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
    titleItem.enabled = NO;
    
    // -- 
    [self.toolBar setItems:[NSArray arrayWithObjects:fixSpaceItem, titleItem, flexSpaceItem, actionItem, nil] animated:YES];

    
    self.view.backgroundColor = [UIColor mainBackgroundColor];

    [self.view addSubview:self.toolBar];
    [self.view addSubview:self.imgView];
    
    [self.view addSubview:self.placeHolder];

}

-(void)showChooseImageView{
    // TODO: Load popover with settings view
    UIImagePickerController* imgPicker = [[UIImagePickerController alloc] init];
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
    
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPicker.delegate = self;
    
    [pop presentPopoverFromBarButtonItem:[self.toolBar.items objectAtIndex:self.toolBar.items.count-1] permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
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
#pragma Delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"info: %@", info);
    
    // Close picker
    // Show image
    // Start processing
    
    
    if ([info objectForKey:@"UIImagePickerControllerOriginalImage"]) {
        self.imgView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        [self.placeHolder removeFromSuperview];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
}



@end
