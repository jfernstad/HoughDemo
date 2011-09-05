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

typedef void (^HistogramFinished)(NSDictionary*);

typedef enum EPixelBufferComponent{
    EPixelBufferAlpha   = 0x01,
    EPixelBufferRed     = 0x02,
    EPixelBufferGreen   = 0x04,
    EPixelBufferBlue    = 0x08,
    
    EPixelBufferAll     = 0x0F
    
}EPixelBufferComponent;

@interface ImageHist : NSObject
{
}

+(void)histoGramWithCVPixelBuffer:(CVPixelBufferRef)inBuffer onComponent:(EPixelBufferComponent)components finishBlock:(HistogramFinished)block;
@end

