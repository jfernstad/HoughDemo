//
//  HoughDemoViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoughInputView.h"
#import "HoughTouchView.h"
#import "HoughFreeHandViewController.h"
#import "HoughLineOverlayDelegate.h"
#import "CircleOverlayDelegate.h"

@class Hough;
@class HoughTouchView;
//@class HoughSettingsViewController;

@interface HoughDemoViewController : UIViewController {
    
    UIToolbar* toolBar;
    UITabBarController* tabBar;
	HoughFreeHandViewController* freehandVC;
}

@end

