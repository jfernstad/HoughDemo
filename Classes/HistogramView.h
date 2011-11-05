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

typedef enum EHistogramStyle {
    EHistogramStyleNormal          = 0x0,
    EHistogramStyleFlipHorizontal  = 0x1,
    EHistogramStyleFlipVertical    = 0x2,

    EHistoGramStyleFlipBoth        = EHistogramStyleFlipHorizontal | EHistogramStyleFlipVertical
}EHistogramStyle;

@protocol HistogramInputProtocol
@property (nonatomic, retain) UIColor* histogramColor;
@property (nonatomic, assign) EPixelBufferComponent useComponents;
@property (nonatomic, assign) EHistogramType histogramType;
@property (nonatomic, assign) EHistogramStyle histogramStyle;
@property (nonatomic, assign) BOOL stretchHistogram;
@property (nonatomic, assign) BOOL logHistogram;
@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef histogramInput;
@end

@protocol HistogramViewDelegate
-(void)didFinish:(CVPixelBufferRef)image withHistogram:(id<HistogramDataSource>)newHistogram;
@end

@interface HistogramView : UIView <HistogramInputProtocol>
{
    ImageHist* histogramObject;
    id<HistogramDataSource> histogram;
    LoadingView* loadingView;

}
@property (nonatomic, assign) NSObject<HistogramViewDelegate>* delegate;

-(void)executeWithImage:(CVPixelBufferRef)inputForHistogram;

@end
