//
//  ImageConfigurationView.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 10/2/11.
//  Copyright (c) 2011 Joakim Fernstad. All rights reserved.
//

#import "ConfigurationBaseView.h"
#import "HistogramView.h"
#import <CoreVideo/CoreVideo.h>

@interface ImageConfigurationView : ConfigurationBaseView{
    
}
-(void)setGrayscaleInput:(CVPixelBufferRef)newGrayImage;
-(void)setHoughInput:(CVPixelBufferRef)newHoughImage;
@end
