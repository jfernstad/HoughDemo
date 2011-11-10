//
//  ImageHist.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "ImageHist.h"

@interface ImageHist()
-(void)allocStruct;
-(void)deleteStruct;
@property (nonatomic, assign) HistoStruct* histoStruct;
@end

@implementation ImageHist
@synthesize image;
@synthesize histogramType;
@synthesize finishBlock;
@synthesize ignoreZeroIntensity;
@synthesize histoStruct;
@synthesize componentOffset;

-(id)init{
    
    if ((self = [super init])) {
        self.histogramType = EHistogramTypeNormal;
        self.histoStruct = NULL;
        self.finishBlock = nil;
        self.image = nil;
        self.ignoreZeroIntensity = YES;
        self.componentOffset = 1;
    }
    return self;
}

-(void)dealloc{
    self.image = nil;
    self.finishBlock = nil;
    [self deleteStruct];
    
    [super dealloc];
}

#pragma mark - Private

-(void)allocStruct{
    self.histoStruct = (HistoStruct*)malloc(sizeof(HistoStruct));
    
    if (self.histoStruct) {
        self.histoStruct->histogram = (NSUInteger*)malloc(256 * sizeof(NSUInteger));
        
        if (!self.histoStruct->histogram) {
            DLog(@"Failed to allocate memory");
            [self deleteStruct];
            return;
        }
    }
    
    memset(self.histoStruct->histogram, 0, 256 * sizeof(NSUInteger));
    self.histoStruct->maxFrequency = 0;
    self.histoStruct->minFrequency = 0;
    self.histoStruct->maxIntensity = 0;
    self.histoStruct->minIntensity = 0;
}
-(void)deleteStruct{
    
    if (self.histoStruct && self.histoStruct->histogram) free(self.histoStruct->histogram);
    if (self.histoStruct) free(self.histoStruct);
    
    self.histoStruct = NULL;
}

#pragma mark -

-(void)createHistogram:(NSString*)identifier{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (!self.image) return; // TODO: do this better, failBlock?
    
    [self deleteStruct];
    [self allocStruct];
    
    CVPixelBufferLockBaseAddress(self.image, 0);
    
    UInt8* pixels = CVPixelBufferGetBaseAddress(self.image);
    
    CVPixelBufferUnlockBaseAddress(self.image, 0);
    
    // C-stuff, for speed
    UInt8 value = 0;
    NSInteger ii = 0;
    NSInteger offset = self.componentOffset;
    NSUInteger histValue = 0;
    NSUInteger prevValue = 0;
    NSUInteger bufferSize = CVPixelBufferGetDataSize(self.image);
    
    // Generate histogram
    
    for (ii = 0; ii < bufferSize; ii+=4) {
        value = pixels[ii + offset];
        
        if (value > 0)
            self.histoStruct->histogram[value] += 1;
    }
    
    // In case we're doing accumulative stuff
    switch (self.histogramType) {
        case EHistogramTypeCumulative:
            prevValue = 0;
            
            for (ii = 0; ii < 256; ii++) {
                histValue = self.histoStruct->histogram[ii];
                self.histoStruct->histogram[ii] = histValue + prevValue;
                prevValue = histValue + prevValue;
            }
            break;
        case EHistogramTypeReverseCumulative:
            prevValue = 0;
            
            for (ii = 255; ii >= 0; ii--) {
                histValue = self.histoStruct->histogram[ii];
                self.histoStruct->histogram[ii] = histValue + prevValue;
                prevValue = histValue + prevValue;
            }
            
            break;
        default:
            break;
    }
    
    
    UInt8 frequency = 0;
    
    NSInteger minFreq       = 9999;
    NSInteger maxFreq       = 0;
    NSInteger minIntensity = 9999;
    NSInteger maxIntensity = 0;
    BOOL foundMinVal    = NO;
    
    // Store in obj-c array and dictionary
    // Ponder this: Should the histogram simply be an array with NSIndexPath objects? [Component].[Intensity].[Hits] .. Probably not 
    // Might wanna use c-structs for this instead. 
    minFreq       = 9999;
    maxFreq       = 0;
    minIntensity = 0;
    maxIntensity = 0;
    foundMinVal  = NO;
    //        foundMaxVal  = NO;
    
    for (ii = 0; ii < 255; ii++) {
        frequency = self.histoStruct->histogram[ii];
        
        if (minFreq > frequency) minFreq = frequency;
        if (maxFreq < frequency) maxFreq = frequency;
        
        if (frequency > 0) {
            foundMinVal = YES; // First color with intensity > 0
            maxIntensity = ii;
        }else{
            if (!foundMinVal) {
                minIntensity = ii;
            }
        }
    }
    
    self.histoStruct->maxFrequency = maxFreq;
    self.histoStruct->minFrequency = minFreq;
    self.histoStruct->maxIntensity = maxIntensity;
    self.histoStruct->minIntensity = minIntensity;

    if (self.finishBlock) {
        self.finishBlock(self);
    }
    [pool drain];
}

#pragma mark - DataSource

-(NSUInteger)histogramMaxIntensity{
    NSUInteger max = 0;
    if (self.histoStruct) {
        max = self.histoStruct->maxIntensity;
    }
    return max;
}
-(NSUInteger)histogramMinIntensity{
    NSUInteger min = 0;
    if (self.histoStruct) {
        min = self.histoStruct->minIntensity;
    }
    return min;
}
-(NSUInteger)histogramMaxFrequency{
    NSUInteger max = 0;
    if (self.histoStruct) {
        max = self.histoStruct->maxFrequency;
    }
    return max;
}
-(NSUInteger)histogramMinFrequency{
    NSUInteger min = 0;
    if (self.histoStruct) {
        min = self.histoStruct->minFrequency;
    }
    return min;
}
-(NSUInteger)frequecyForIntensity:(NSUInteger)intensity{
    NSUInteger freq = 0;

    if (intensity <= self.histoStruct->maxIntensity &&
        intensity >= self.histoStruct->minIntensity) {
        freq = self.histoStruct->histogram[intensity];
    }
    return freq;
}

@end
