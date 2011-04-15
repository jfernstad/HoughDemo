//
//  HoughSettingsViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/9/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Hough;

@interface HoughSettingsViewController : UITableViewController {
    UISegmentedControl* modeControl;
    UISegmentedControl* freeHandInteractionMode;
    UISwitch* autoAnalysisSwitch;

    Hough* houghRef;
}

@property (nonatomic, retain) UISegmentedControl* modeControl;
@property (nonatomic, retain) UISegmentedControl* freeHandInteractionMode;
@property (nonatomic, retain) UISwitch* autoAnalysisSwitch;
@property (nonatomic, assign) Hough* houghRef;

@end
