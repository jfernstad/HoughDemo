//
//  HoughImageViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoughBaseViewController.h"

@class HoughLineOverlayDelegate;

@interface HoughImageViewController : HoughBaseViewController <UIImagePickerControllerDelegate, UIPopoverControllerDelegate, HoughOperationDelegate>{
    UIImageView* imgView;
    
    UIImagePickerController* imgPicker;
    UIPopoverController* popover;

    HoughLineOverlayDelegate* lineDelegate;
    CALayer* lineLayer;
    
}

@property (nonatomic, retain) UIImageView* imgView;
@property (nonatomic, retain) UIImagePickerController* imgPicker;
@property (nonatomic, retain) UIPopoverController* popover;
@property (nonatomic, retain) CALayer* lineLayer;
@property (nonatomic, retain) HoughLineOverlayDelegate* lineDelegate;

-(void)cancelOperations;

@end
