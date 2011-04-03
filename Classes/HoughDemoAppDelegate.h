//
//  HoughDemoAppDelegate.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HoughDemoViewController;

@interface HoughDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UIViewController* settingsController;
    HoughDemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet HoughDemoViewController *viewController;
@property (nonatomic, retain) IBOutlet UIViewController* settingsController;

@end

