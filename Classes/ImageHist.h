//
//  ImageHist.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoughConstants.h"

#define kHistogramOnRedComponentKey    @"HistogramOnRed"
#define kHistogramOnGreenComponentKey  @"HistogramOnGreen"
#define kHistogramOnBlueComponentKey   @"HistogramOnBlue"
#define kHistogramOnAlphaComponentKey  @"HistogramOnAlpha"

#define kHistogramStatisticsKey        @"HistogramStatistics"
#define kHistogramMaxValueKey          @"HistogramMaxValue"
#define kHistogramMinValueKey          @"HistogramMinValue"
#define kHistogramMaxIntensityKey      @"HistogramMaxIntensity"
#define kHistogramMinIntensityKey      @"HistogramMinIntensity"

typedef enum EPixelBufferComponent{
    EPixelBufferNone        = 0x00,       // Use this for gray color?
    EPixelBufferAlpha       = 0x01,
    EPixelBufferRed         = 0x02,
    EPixelBufferGreen       = 0x04,
    EPixelBufferBlue        = 0x08,
    
    EPixelBuffer16GrayScale = 0x01, 
    
    EPixelBufferAllColors   = 0x0E,
    EPixelBufferAll         = 0x0F
    
}EPixelBufferComponent;

typedef enum EHistogramType{
    EHistogramTypeNormal             = 0x00,
    EHistogramTypeCumulative         = 0x01,
    EHistogramTypeReverseCumulative  = 0x02,
    
}EHistogramType;

@protocol HistogramDataSource
-(NSUInteger)upperIntensityLimit;
-(NSUInteger)numberOfColorComponents;
-(NSArray*)allColorComponents;
-(NSInteger)numberOfFrequencies:(NSUInteger)component;
-(EPixelBufferComponent)colorComponents;
-(NSUInteger)frequencyForIntensity:(NSUInteger)intensity inComponent:(NSUInteger)component;
-(NSUInteger)maxIntensity:(NSUInteger)component;
-(NSUInteger)minIntensity:(NSUInteger)component;
-(NSUInteger)maxFrequency:(NSUInteger)component;
-(NSUInteger)minFrequency:(NSUInteger)component;
@end

typedef void (^HistogramFinished)(id<HistogramDataSource>);

@interface ImageHist : NSObject <HistogramDataSource>
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
@property (nonatomic, assign) BOOL ignoreZeroIntensity;

-(void)createHistogram;
@end

