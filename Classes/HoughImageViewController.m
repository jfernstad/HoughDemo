//
//  HoughImageViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughImageViewController.h"
#import "UIColor+HoughExtensions.h"


@implementation HoughImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
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
    CGRect textRect = CGRectMake(0,0,200,500);
    
    self.view = [[UIView alloc] initWithFrame:totalRect];
    self.view.backgroundColor = [UIColor houghGray];
    
    UILabel* todoText = [[UILabel alloc] initWithFrame:textRect];
    todoText.numberOfLines = 2;
    todoText.lineBreakMode = UILineBreakModeWordWrap;
    todoText.font = [UIFont fontWithName:@"Courier" size:32];
    todoText.textColor = [UIColor houghGreen];
    todoText.backgroundColor = [UIColor houghGray];
    
    todoText.text = @"TODO: Fill this screen with awesome stuff!";
    
    CGSize rs = [todoText.text sizeWithFont:[UIFont fontWithName:@"Courier" size:32]
                          constrainedToSize:CGSizeMake(500, 400)
                              lineBreakMode:UILineBreakModeWordWrap];
    
    textRect.origin = CGPointMake((totalRect.size.width - rs.width)/2, (totalRect.size.height - rs.height)/2);
    textRect.size = rs;
    
    todoText.frame = textRect;
    
    [self.view addSubview:todoText];
    
    [todoText release];
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

@end
