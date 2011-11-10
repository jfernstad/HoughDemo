//
//  ImageHist.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoughConstants.h"

typedef struct HistoStruct{
    NSUInteger maxIntensity;
    NSUInteger minIntensity;
    NSUInteger maxFrequency;
    NSUInteger minFrequency;
    NSUInteger* histogram;
}HistoStruct;

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

@protocol HistogramDataSource
-(NSUInteger)histogramMaxIntensity;
-(NSUInteger)histogramMinIntensity;
-(NSUInteger)histogramMaxFrequency;
-(NSUInteger)histogramMinFrequency;
-(NSUInteger)frequecyForIntensity:(NSUInteger)intensity;
@end

typedef void (^HistogramFinished)(NSObject<HistogramDataSource>*);

@interface ImageHist : NSObject <HistogramDataSource>
@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef image;
@property (nonatomic, assign) EHistogramType  histogramType;
@property (nonatomic, copy)   HistogramFinished finishBlock;
@property (nonatomic, assign) BOOL ignoreZeroIntensity;
@property (nonatomic, assign) NSUInteger componentOffset;

-(void)createHistogram:(NSString*)identifier;
@end

