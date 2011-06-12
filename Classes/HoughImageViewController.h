//
//  HoughImageViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Hough.h"

@class HoughLineOverlayDelegate;
@class LoadingView;

@interface HoughImageViewController : UIViewController <UIImagePickerControllerDelegate, UIPopoverControllerDelegate, HoughOperationDelegate>{
    UIToolbar* toolBar;
    UIImageView* imgView;
    
    UILabel* placeHolder;
    LoadingView* loadingView;
    
    UIImagePickerController* imgPicker;
    UIPopoverController* popover;

    HoughLineOverlayDelegate* lineDelegate;
    CALayer* lineLayer;
    
	Hough* hough;
}

@property (nonatomic, retain) UIToolbar* toolBar;
@property (nonatomic, retain) UIImageView* imgView;
@property (nonatomic, retain) UILabel* placeHolder;
@property (nonatomic, retain) UIImagePickerController* imgPicker;
@property (nonatomic, retain) UIPopoverController* popover;
@property (nonatomic, retain) Hough* hough;
@property (nonatomic, retain) LoadingView* loadingView;
//@property (nonatomic, retain) CALayer* lineLayer; // TODO
//@property (nonatomic, retain) HoughLineOverlayDelegate* lineDelegate; // TODO

@end
