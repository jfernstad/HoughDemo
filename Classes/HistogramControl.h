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

-(void)setHistogramImage:(CVPixelBufferRef)newImage;
@end
