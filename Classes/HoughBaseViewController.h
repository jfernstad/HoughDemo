//
//  BaseViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 7/16/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "Hough.h"
#import "Bucket2D.h"

@interface HoughBaseViewController : UIViewController{
    UIToolbar* toolBar;
    LoadingView* loadingView;

    Bucket2D* bucket;
    Hough* hough;
    
    CGRect contentRect;
}

@property (nonatomic, retain) UIToolbar* toolBar;
@property (nonatomic, retain) LoadingView* loadingView;
@property (nonatomic, retain) Hough* hough;
@property (nonatomic, retain) Bucket2D* bucket;
@property (nonatomic, assign) CGRect contentRect;

@end
