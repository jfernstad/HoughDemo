//
//  HistogramControl.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 10/2/11.
//  Copyright (c) 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistogramView.h"
#import <CoreVideo/CoreVideo.h>

@interface HistogramControl : UIControl <HistogramViewDelegate,HistogramInputProtocol>

@property (nonatomic, assign) BOOL positionSliderToLeft;
@property (nonatomic, readonly) NSInteger value;
-(void)setHistogramImage:(CVPixelBufferRef)newImage;
@end
