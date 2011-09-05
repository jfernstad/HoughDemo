//
//  ImageHist.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "ImageHist.h"

@implementation ImageHist

+(void)histoGramWithCVPixelBuffer:(CVPixelBufferRef)inBuffer onComponent:(EPixelBufferComponent)components finishBlock:(HistogramFinished)block{
    NSMutableDictionary* dic = nil;
    NSMutableDictionary* curDic = nil;

    if (block) {
        [block copy];
    }

    CVPixelBufferRetain(inBuffer);
    
    CVPixelBufferLockBaseAddress(inBuffer, 0);
    
    UInt8* pixels = CVPixelBufferGetBaseAddress(inBuffer);

    CVPixelBufferUnlockBaseAddress(inBuffer, 0);
    
    // C-stuff, for speed
    int histogram[4][256];
    memset(&histogram, 0, 4 * 256 * sizeof(int));
    
    NSMutableArray* aryComponents = [NSMutableArray array];
    
    // Pixel offset, assume Pixelbuffer is ARGB 32bit Big Endian format
    if (components & EPixelBufferAlpha) {
        [aryComponents addObject:[NSNumber numberWithInt:0]]; 
    }
    if (components & EPixelBufferRed) {
        [aryComponents addObject:[NSNumber numberWithInt:1]]; 
    }
    if (components & EPixelBufferGreen) {
        [aryComponents addObject:[NSNumber numberWithInt:2]]; 
    }
    if (components & EPixelBufferBlue) {
        [aryComponents addObject:[NSNumber numberWithInt:3]]; 
    }

    UInt8 value = 0;
    NSInteger ii = 0;
    NSInteger offset = 0;

    // Generate histogram
    for (NSNumber* n in aryComponents) {
        offset = [n integerValue];
        
        for (ii = 0; ii < CVPixelBufferGetDataSize(inBuffer); ii+=4) {
            value = pixels[ii + offset];
            histogram[offset][value] += 1;
        }
    }
    
    int intValue = 0;
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    // Store in obj-c array and dictionary
    //  Ponder this: Should the histogram simply be an array with NSIndexPath objects? [Component].[Intensity].[Hits] .. Probably not 
    for (NSNumber* n in aryComponents) {
        offset = [n integerValue];
        for (ii = 0; ii < 255; ii++) {
            
            intValue = histogram[offset][ii];

            if (intValue > 0) {
                if (!dic) {
                    dic = [NSMutableDictionary dictionary];
                }
                if (!curDic) {
                    curDic = [NSMutableDictionary dictionary];
                    [dic setObject:curDic forKey:n];
                }
                [curDic setObject:[NSNumber numberWithInt:intValue] forKey:[NSNumber numberWithInt:ii]];
            }
        }
        curDic = nil;
    }
    
    CVPixelBufferRelease(inBuffer);

    if (block) {
        block(dic);
    }
    [pool drain];
}

@end
