//
//  ConfigurationsBaseView.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/11/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigurationBaseView : UIView {

    UIImageView* lobeView;
    UIView* backgroundView;
    
    CGRect contentRect;
    CGRect originalRect;
    CGPoint startPoint;
    CGRect  startRect;
}
@property (nonatomic, retain) UIImageView* lobeView;
@property (nonatomic, retain) UIView* backgroundView;

-(void)showViewAnimated:(BOOL)useAnimation;
-(void)dismissViewAnimated:(BOOL)useAnimation;

@end
