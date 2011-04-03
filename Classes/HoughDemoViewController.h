//
//  HoughDemoViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoughInputView.h"
#import "HoughTouchView.h"
#import "HoughLineOverlayDelegate.h"
#import "CircleOverlayDelegate.h"

@class Hough;
@class HoughTouchView;

@interface HoughDemoViewController : UIViewController <HoughInputProtocol, HoughOverlayProtocol>{
	HoughInputView* houghInputView;
	HoughTouchView* houghTouchView;
	
    CALayer* lineLayer;                // Add as sublayer to houghInputView
    CALayer* circleLayer;              // Add as sublayer to houghInputTouch
    HoughLineOverlayDelegate* lineDelegate; // Layer delegate, add to lineLayer 
    CircleOverlayDelegate* circleDelegate; // Layer delegate, add to circleLayer 
    
//	CGImageRef* dotImg;
//	CGImageRef* houghImg;

	Hough* hough;
	BOOL busy;
	
	UILabel* status;
}

@property (nonatomic, retain) IBOutlet HoughInputView* houghInputView;
@property (nonatomic, retain) IBOutlet HoughTouchView* houghTouchView;
@property (nonatomic, retain) IBOutlet UILabel* status;
@property (nonatomic, retain) Hough* hough;
@property (nonatomic, assign) BOOL busy;
@property (nonatomic, retain) CALayer* lineLayer;
@property (nonatomic, retain) CALayer* circleLayer;
@property (nonatomic, retain) HoughLineOverlayDelegate* lineDelegate;
@property (nonatomic, retain) CircleOverlayDelegate* circleDelegate;

-(IBAction)clear;
-(void)updateInputWithPoints:(NSArray*)pointArray;
-(void)overlayLines:(NSArray *)lines;  
-(void)overlayCircles:(NSArray *)circles;
@end

