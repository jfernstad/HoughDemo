//
//  ImageHist.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHistogramOnRedComponentKey    @"HistogramOnRed"
#define kHistogramOnGreenComponentKey  @"HistogramOnGreen"
#define kHistogramOnBlueComponentKey   @"HistogramOnBlue"
#define kHistogramOnAlphaComponentKey  @"HistogramOnAlpha"

#define kHistogramStatisticsKey        @"HistogramStatistics"
#define kHistogramMaxValueKey          @"HistogramMaxValue"
#define kHistogramMinValueKey          @"HistogramMinValue"
#define kHistogramMaxIntensityKey      @"HistogramMaxIntensity"
#define kHistogramMinIntensityKey      @"HistogramMinIntensity"

typedef void (^HistogramFinished)(NSDictionary*);

typedef enum EPixelBufferComponent{
    EPixelBufferNone      = 0x00,
    EPixelBufferAlpha     = 0x01,
    EPixelBufferRed       = 0x02,
    EPixelBufferGreen     = 0x04,
    EPixelBufferBlue      = 0x08,
    
    EPixelBufferAllColors = 0x0E,
    EPixelBufferAll       = 0x0F
    
}EPixelBufferComponent;

typedef enum EHistogramType{
    EHistogramTypeNormal             = 0x00,
    EHistogramTypeCumulative         = 0x01,
    EHistogramTypeReverseCumulative  = 0x02,
    
}EHistogramType;

@interface ImageHist : NSObject
{
    CVPixelBufferRef      image;
    EPixelBufferComponent histogramPixelBufferComponent;
    EHistogramType        histogramType;
    HistogramFinished     finishBlock;
    
}
@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef image;
@property (nonatomic, assign) EPixelBufferComponent histogramPixelBufferComponent;
@property (nonatomic, assign) EHistogramType        histogramType;
@property (nonatomic, copy)   HistogramFinished     finishBlock;

-(void)createHistogram;
@end

