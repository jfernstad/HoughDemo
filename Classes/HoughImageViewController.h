//
//  HoughImageViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoughBaseViewController.h"
#import "HistogramView.h"

@class HoughLineOverlayDelegate;
@class ImageConfigurationView;

@interface HoughImageViewController : HoughBaseViewController <UIImagePickerControllerDelegate, UIPopoverControllerDelegate, HoughOperationDelegate>{
    UIImageView* imgView;
    HistogramView* histoView;
    
    UIImagePickerController* imgPicker;
    UIPopoverController* popover;

    HoughLineOverlayDelegate* lineDelegate;
    CALayer* lineLayer;
    
}

@property (nonatomic, retain) UIImageView* imgView;
@property (nonatomic, retain) ImageConfigurationView* confView;
@property (nonatomic, retain) UIImagePickerController* imgPicker;
@property (nonatomic, retain) UIPopoverController* popover;
@property (nonatomic, retain) CALayer* lineLayer;
@property (nonatomic, retain) HoughLineOverlayDelegate* lineDelegate;

-(void)cancelOperations;

@end
