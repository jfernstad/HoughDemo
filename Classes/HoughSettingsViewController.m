//
//  HoughSettingsViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/9/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughSettingsViewController.h"
#import "Hough.h"

@interface HoughSettingsViewController ()
- (UIView*)analysisViewInRect:(CGRect)rect;
- (UIView*)interactionModeViewInRect:(CGRect)rect;
- (void)segTouch:(id)sender;
@end

enum{
    kModeSection,
    kFreeHandInteractionSection,
    kAnalysisSection,
    
    kNumberOfSections
} ESection;

enum{
    kModeRow,
    
    kModeNumberOfRows
} EModeRows;

@implementation HoughSettingsViewController
@synthesize modeControl;
@synthesize autoAnalysisSwitch;
@synthesize freeHandInteractionMode;
@synthesize houghRef;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Settings controller dealloc");
    self.modeControl = nil;
    self.autoAnalysisSwitch = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (UISegmentedControl*)modeControl{

    if (!modeControl) {
        modeControl = [[UISegmentedControl alloc] initWithItems:
                            [NSArray arrayWithObjects:@"Free hand", @"Image", @"Video", nil]];
        
        [modeControl setSelectedSegmentIndex:1]; // TODO: Parameter
        
    }
    return modeControl;
}

- (UISwitch*)autoAnalysisSwitch{
    if (!autoAnalysisSwitch) {
        autoAnalysisSwitch = [[[UISwitch alloc] init] autorelease];
        autoAnalysisSwitch.on = NO; // TODO: Parameter
    }
    return autoAnalysisSwitch;
}

- (UISegmentedControl*)freeHandInteractionMode{
    if (!freeHandInteractionMode) {
        freeHandInteractionMode = [[UISegmentedControl alloc] initWithItems:
                       [NSArray arrayWithObjects:@"Draw", @"Tap", nil]];
        
        [freeHandInteractionMode setSelectedSegmentIndex:(houghRef.interactionMode==kFreeHandDraw)?0:1]; // TODO: Parameter
        
        [freeHandInteractionMode addTarget:self
                                    action:@selector(segTouch:)
                          forControlEvents:UIControlEventValueChanged];
        
    }
    return freeHandInteractionMode;
}

- (UIView*)analysisViewInRect:(CGRect)rect{

    CGSize size = CGSizeZero;
    CGRect textRect = CGRectZero;
    CGRect switchRect = CGRectZero;

    UIView* tmpView = [[[UIView alloc] init] autorelease];
    UILabel* text   = [[[UILabel alloc] init] autorelease];

    text.text = @"Auto analysis";
    size = self.autoAnalysisSwitch.bounds.size;
    
    CGRectDivide(rect, &textRect, &switchRect, rect.size.width - size.width - 50, CGRectMinXEdge);
    
    tmpView.backgroundColor = [UIColor clearColor];
    text.backgroundColor = [UIColor clearColor];
    
    // Center rect in rect
    switchRect = CGRectMake(CGRectGetMinX(switchRect) + (CGRectGetMaxX(switchRect) - CGRectGetMinX(switchRect))/2 - size.width/2,
                            (CGRectGetMaxY(switchRect) - CGRectGetMinY(switchRect))/2 - size.height/2,
                            size.width, size.height);
    
    self.autoAnalysisSwitch.frame = switchRect;
    tmpView.frame = rect;
    text.frame = textRect;
    
    [tmpView addSubview:text];
    [tmpView addSubview:self.autoAnalysisSwitch];

    return tmpView;

}
- (UIView*)interactionModeViewInRect:(CGRect)rect{
    
    CGSize size     = CGSizeZero;
    CGRect textRect = CGRectZero;
    CGRect segRect  = CGRectZero;
    
    UIView* tmpView = [[[UIView alloc] init] autorelease];
    UILabel* text   = [[[UILabel alloc] init] autorelease];
    
    text.text = @"Interaction mode";
    size = self.freeHandInteractionMode.bounds.size;
    
    //size.height = rect.size.height - 5;
    
    CGRectDivide(rect, &textRect, &segRect, rect.size.width - size.width - 35, CGRectMinXEdge);
    
    tmpView.backgroundColor = [UIColor clearColor];
    text.backgroundColor = [UIColor clearColor];
    
    // Center rect in rect
    segRect = CGRectMake(CGRectGetMinX(segRect) + (CGRectGetMaxX(segRect) - CGRectGetMinX(segRect))/2 - size.width/2,
                            (CGRectGetMaxY(segRect) - CGRectGetMinY(segRect))/2 - size.height/2,
                            size.width, size.height);
    
    self.freeHandInteractionMode.frame = segRect;
    tmpView.frame = rect;
    text.frame = textRect;
    
    [tmpView addSubview:text];
    [tmpView addSubview:self.freeHandInteractionMode];
    
    return tmpView;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    NSString* title = nil;
    switch (section) {
        case kModeSection:
        {
            title = @"Modes";
        }
            break;
        case kAnalysisSection:
        {
            title = @"";
        }    
            break;
            
        default:
            break;
    }
    
    return title;    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSInteger nRows = 1;
    
    switch (section) {
        case kModeSection:
        {
            nRows = 1;
        }
            break;
        case kAnalysisSection:
        {
            nRows = 1;
        }    
            break;
        case kFreeHandInteractionSection:
        {
            nRows = 1;
        }    
            break;
            
        default:
            break;
    }

    return nRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UIView* cellView = nil;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cellView = [[[UIView alloc] initWithFrame:cell.bounds] autorelease];
    CGRect tmpRect = CGRectZero;
    CGSize tmpSize = CGSizeZero;
    
    switch (indexPath.section) {
        case kModeSection:
        {
            switch (indexPath.row) {
                case kModeRow:
                {
                    tmpSize = [self.modeControl sizeThatFits:CGRectInset(cell.contentView.bounds, 3, 0).size];
                    tmpRect.size = tmpSize;
                    self.modeControl.frame = tmpRect;
                    [cellView addSubview:self.modeControl];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case kAnalysisSection:
        {
            tmpRect = cell.contentView.bounds;
            tmpRect = CGRectInset(tmpRect, 5, 0);
            
            cellView = [self analysisViewInRect:tmpRect];
            
        }    
            break;
            
        case kFreeHandInteractionSection:
        {
            tmpRect = cell.contentView.bounds;
            tmpRect = CGRectInset(tmpRect, 5, 0);

            cellView = [self interactionModeViewInRect:tmpRect];
        }
            break;
            
        default:
            break;
    }
    // Configure the cell...
    
    [cell.contentView addSubview:cellView];
    
    return cell;
}
- (void)segTouch:(id)sender{

    if (sender == self.freeHandInteractionMode) {
        houghRef.interactionMode = (self.freeHandInteractionMode.selectedSegmentIndex == 0)?kFreeHandDraw:kFreeHandDots;
    }

}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
