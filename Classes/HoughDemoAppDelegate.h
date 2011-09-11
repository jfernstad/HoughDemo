//
//  HoughDemoAppDelegate.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HoughFreeHandViewController;
@class HoughImageViewController;
@class InfoViewController;

@interface HoughDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;

    UITabBarController* tabBar;
	HoughFreeHandViewController* freehandVC;
    HoughImageViewController* imageVC;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController* tabBar;
@property (nonatomic, retain) HoughFreeHandViewController* freehandVC;
@property (nonatomic, retain) HoughImageViewController* imageVC;
@property (nonatomic, retain) InfoViewController* infoVC;


@end

