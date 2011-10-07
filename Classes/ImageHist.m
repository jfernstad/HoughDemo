//
//  ImageHist.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "ImageHist.h"

@implementation ImageHist
@synthesize image;
@synthesize histogramPixelBufferComponent;
@synthesize histogramType;
@synthesize finishBlock;
@synthesize ignoreZeroIntensity;

-(id)init{
    
    if ((self = [super init])) {
        self.histogramPixelBufferComponent = EPixelBufferAllColors;
        self.histogramType                 = EHistogramTypeNormal;
        
        self.finishBlock = nil;
        self.image = nil;
        self.ignoreZeroIntensity = YES;
    }
    return self;
}

-(void)dealloc{
    self.image = nil;
    self.finishBlock = nil;
    
    [super dealloc];
}

-(void)createHistogram{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableDictionary* dic = nil;
    NSMutableDictionary* curDic = nil;
    NSMutableDictionary* statsDic = nil;
    
    if (!self.image) return; // TODO: do this better, failBlock?
    
    CVPixelBufferLockBaseAddress(self.image, 0);
    
    UInt8* pixels = CVPixelBufferGetBaseAddress(self.image);
    
    CVPixelBufferUnlockBaseAddress(self.image, 0);
    
    // C-stuff, for speed
    int histogram[4][256];
    memset(&histogram, 0, 4 * 256 * sizeof(int));
    
    NSMutableArray* aryComponents = [NSMutableArray array];
    
    // Pixel offset, assume Pixelbuffer is ARGB 32bit Big Endian format
    if (self.histogramPixelBufferComponent & EPixelBufferAlpha) {
        [aryComponents addObject:[NSNumber numberWithInt:0]]; 
    }
    if (self.histogramPixelBufferComponent & EPixelBufferRed) {
        [aryComponents addObject:[NSNumber numberWithInt:1]]; 
    }
    if (self.histogramPixelBufferComponent & EPixelBufferGreen) {
        [aryComponents addObject:[NSNumber numberWithInt:2]]; 
    }
    if (self.histogramPixelBufferComponent & EPixelBufferBlue) {
        [aryComponents addObject:[NSNumber numberWithInt:3]]; 
    }
    
    UInt8 value = 0;
    NSInteger ii = 0;
    NSInteger offset = 0;
    NSUInteger histValue = 0;
    NSUInteger prevValue = 0;
    NSUInteger bufferSize = CVPixelBufferGetDataSize(self.image);
    
    // Generate histogram
    
    for (NSNumber* n in aryComponents) {
        offset = [n integerValue];
        
        for (ii = 0; ii < bufferSize; ii+=4) {
            value = pixels[ii + offset];

            if (value > 0)
                histogram[offset][value] += 1;
        }
    }

    // In case we're doing accumulative stuff
    switch (self.histogramType) {
        case EHistogramTypeCumulative:
            for (NSNumber* n in aryComponents) {
                offset = [n integerValue];
                prevValue = 0;
                
                for (ii = 0; ii < 256; ii++) {
                    histValue = histogram[offset][ii];
                    histogram[offset][ii] = histValue + prevValue;
                    prevValue = histValue + prevValue;
                }
            }
            break;
        case EHistogramTypeReverseCumulative:
            for (NSNumber* n in aryComponents) {
                offset = [n integerValue];
                prevValue = 0;
                
                for (ii = 255; ii >= 0; ii--) {
                    histValue = histogram[offset][ii];
                    histogram[offset][ii] = histValue + prevValue;
                    prevValue = histValue + prevValue;
                }
            }
            break;
        default:
            break;
    }

    
    int intValue = 0;
    
    NSInteger minVal       = 9999;
    NSInteger maxVal       = 0;
    NSInteger minIntensity = 9999;
    NSInteger maxIntensity = 0;
    BOOL foundMinVal    = NO;
    
    // Store in obj-c array and dictionary
    // Ponder this: Should the histogram simply be an array with NSIndexPath objects? [Component].[Intensity].[Hits] .. Probably not 
    // Might wanna use c-structs for this instead. 
    for (NSNumber* n in aryComponents) {
        offset = [n integerValue];
        
        minVal       = 0;
        maxVal       = 0;
        minIntensity = 9999;
        maxIntensity = 0;
        foundMinVal  = NO;
        //        foundMaxVal  = NO;
        curDic       = nil;
        statsDic     = nil;
        
        for (ii = 0; ii < 255; ii++) {
            
            intValue = histogram[offset][ii];
            
            if (minIntensity > intValue) minIntensity = intValue;
            if (maxIntensity < intValue) maxIntensity = intValue;
            
            if (intValue > 0) {
                
                foundMinVal = YES; // First color with intensity > 0
                
                if (!dic) {
                    dic = [NSMutableDictionary dictionaryWithCapacity:aryComponents.count];
                }
                if (!curDic) {
                    curDic = [NSMutableDictionary dictionaryWithCapacity:256];
                    [dic setObject:curDic forKey:n];
                }
                
                maxVal = ii;
                
                [curDic setObject:[NSNumber numberWithInt:intValue] forKey:[NSNumber numberWithInt:ii]];
            }else{
                if (!foundMinVal) {
                    minVal = ii;
                }
            }
        }
        
        if (curDic) {
            statsDic = [NSMutableDictionary dictionary];
            
            [statsDic setObject:[NSNumber numberWithInt:minIntensity] forKey:kHistogramMinIntensityKey];
            [statsDic setObject:[NSNumber numberWithInt:maxIntensity] forKey:kHistogramMaxIntensityKey];
            [statsDic setObject:[NSNumber numberWithInt:maxVal] forKey:kHistogramMaxValueKey];
            [statsDic setObject:[NSNumber numberWithInt:minVal] forKey:kHistogramMinValueKey];
            
            [curDic setObject:statsDic forKey:kHistogramStatisticsKey];
        }
    }
    
    if (self.finishBlock) {
        self.finishBlock(dic);
    }
    [pool drain];
}

@end
