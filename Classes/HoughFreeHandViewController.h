//
//  HoughFreeHandViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/3/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoughBaseViewController.h"
#import "HoughInputView.h"
#import "HoughTouchView.h"
#import "HoughLineOverlayDelegate.h"
#import "CircleOverlayDelegate.h"
#import "ConfigurationBaseView.h"

@class HoughTouchView;
@class Bucket2D;
@class FreeHandConfigurationView;
@class PointLinkedList;

@interface HoughFreeHandViewController : HoughBaseViewController <HoughInputProtocol, HoughOverlayProtocol, HoughOperationDelegate, ConfigurationProtocol>{
    // View elements
	HoughInputView* houghInputView;
	HoughTouchView* houghTouchView;
    FreeHandConfigurationView* confView;
	UILabel* status;
	UISegmentedControl* modeControl;
    
    // Layers & delegates
    CALayer* lineLayer;                // Add as sublayer to houghInputView
    CALayer* circleLayer;              // Add as sublayer to houghInputTouch
    HoughLineOverlayDelegate* lineDelegate; // Layer delegate, add to lineLayer 
    CircleOverlayDelegate* circleDelegate; // Layer delegate, add to circleLayer 
    
	BOOL busy;
    BOOL persistentTouch;
    BOOL pointAdded;
    BOOL readyForAnalysis;
    BOOL shouldAnalyzeAutomatically;
    
    NSTimer* analysisTimer;
}

@property (nonatomic, retain) HoughInputView* houghInputView;
@property (nonatomic, retain) HoughTouchView* houghTouchView;
@property (nonatomic, retain) UILabel* status;
@property (assign) BOOL busy;
@property (assign) BOOL persistentTouch;
@property (assign) BOOL pointAdded;
@property (assign) BOOL readyForAnalysis;
@property (assign) BOOL shouldAnalyzeAutomatically;
@property (nonatomic, retain) CALayer* lineLayer;
@property (nonatomic, retain) CALayer* circleLayer;
@property (nonatomic, retain) HoughLineOverlayDelegate* lineDelegate;
@property (nonatomic, retain) CircleOverlayDelegate* circleDelegate;
@property (nonatomic, retain) FreeHandConfigurationView* confView;

-(void)clear;
-(void)updateInputWithPoints:(PointLinkedList*)pointArray;
-(void)overlayLines:(NSArray *)lines;  
-(void)overlayCircles:(NSArray *)circles;
@end

