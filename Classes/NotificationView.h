//
//  NotificationView.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 8/30/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationView : UIView{
    UILabel* label;
}

@property (nonatomic, retain) NSString* text;
@property (nonatomic, retain) UILabel* label;

+(void)showText:(NSString*)string inView:(UIView*)parentView;

@end
