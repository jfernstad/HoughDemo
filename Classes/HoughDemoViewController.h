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
    UIButton* clearButton;
	UILabel* status;
	
    CALayer* lineLayer;                // Add as sublayer to houghInputView
    CALayer* circleLayer;              // Add as sublayer to houghInputTouch
    HoughLineOverlayDelegate* lineDelegate; // Layer delegate, add to lineLayer 
    CircleOverlayDelegate* circleDelegate; // Layer delegate, add to circleLayer 
    
//	CGImageRef* dotImg;
//	CGImageRef* houghImg;

	Hough* hough;
	BOOL busy;
	
}

@property (nonatomic, retain) HoughInputView* houghInputView;
@property (nonatomic, retain) HoughTouchView* houghTouchView;
@property (nonatomic, retain) UIButton* clearButton;
@property (nonatomic, retain) UILabel* status;
@property (nonatomic, retain) Hough* hough;
@property (nonatomic, assign) BOOL busy;
@property (nonatomic, retain) CALayer* lineLayer;
@property (nonatomic, retain) CALayer* circleLayer;
@property (nonatomic, retain) HoughLineOverlayDelegate* lineDelegate;
@property (nonatomic, retain) CircleOverlayDelegate* circleDelegate;

-(void)clear;
-(void)updateInputWithPoints:(NSArray*)pointArray;
-(void)overlayLines:(NSArray *)lines;  
-(void)overlayCircles:(NSArray *)circles;
@end

