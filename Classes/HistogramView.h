//
//  HistogramView.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageHist.h"

@class LoadingView;

@interface HistogramView : UIView
{
    ImageHist* histogramObject;
    NSDictionary* histogram;
    
    UIColor* histogramColor;
    LoadingView* loadingView;

    EPixelBufferComponent useComponents;
    BOOL stretchHistogram;
    BOOL logHistogram;
}
@property (nonatomic, retain) UIColor* histogramColor;
@property (nonatomic, assign) EPixelBufferComponent useComponents;
@property (nonatomic, assign) BOOL stretchHistogram;
@property (nonatomic, assign) BOOL logHistogram;

-(void)executeWithImage:(CVPixelBufferRef)inputForHistogram;

@end
