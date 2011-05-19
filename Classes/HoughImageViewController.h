//
//  HoughImageViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HoughImageViewController : UIViewController {
    UIToolbar* toolBar;
    UIImageView* imgView;
}

@property (nonatomic, retain) UIToolbar* toolBar;
@property (nonatomic, retain) UIImageView* imgView;

@end
