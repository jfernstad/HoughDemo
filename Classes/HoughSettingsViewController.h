//
//  HoughSettingsViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/9/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HoughSettingsViewController : UITableViewController {
    UISegmentedControl* modeControl;
    UISwitch* autoAnalysisSwitch;
}
@property (nonatomic, retain) UISegmentedControl* modeControl;
@property (nonatomic, retain) UISwitch* autoAnalysisSwitch;

@end
