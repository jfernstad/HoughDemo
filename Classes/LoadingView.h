//
//  LoadingView.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/22/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView : UIView {

    UILabel* loadingLabel;
    UIActivityIndicatorView* progress;
}

@property (nonatomic, assign) NSString* text;
@property (nonatomic, readonly) BOOL inProgress;

//- (void)showView:(BOOL)show animated:(BOOL)animated;
- (void)startProgress;
- (void)stopProgress;

@end
