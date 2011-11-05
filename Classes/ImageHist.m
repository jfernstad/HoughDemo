//
//  ImageHist.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "ImageHist.h"

//@interface ImageHist()
//@property (nonatomic, assign) NSUInteger minFrequency;
//@property (nonatomic, assign) NSUInteger maxFrequency;
//@property (nonatomic, assign) NSUInteger minIntensity;
//@property (nonatomic, assign) NSUInteger maxIntensity;
//@end
//

typedef struct HistogramStruct {
    NSUInteger minFrequency;
    NSUInteger maxFrequency;
    NSUInteger minIntensity;
    NSUInteger maxIntensity;
    EPixelBufferComponent colorComponent;
}HistogramStruct;

@interface ImageHist(){
    HistogramStruct* histoStruct[4]; // This will be malloc'ed
}
@property (nonatomic, assign) NSUInteger  nColorComponents;
@property (nonatomic, assign) NSUInteger  maxPossibleIntensity;
@property (nonatomic, assign) NSUInteger* histogram;
@property (nonatomic, retain) NSArray* validColorComponents;
@end

@implementation ImageHist
@synthesize image;
@synthesize histogramPixelBufferComponent;
@synthesize histogramType;
@synthesize finishBlock;
@synthesize ignoreZeroIntensity;

// HistogramDataSource related
@synthesize histogram;
@synthesize nColorComponents;
@synthesize maxPossibleIntensity;
@synthesize validColorComponents;
//@synthesize minFrequency;
//@synthesize maxFrequency;
//@synthesize minIntensity;
//@synthesize maxIntensity;

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
    self.validColorComponents = nil;
    
    if (self.histogram != NULL) {
        free(self.histogram);
        self.histogram = NULL;
    }

    if (histoStruct != NULL) {
        if (histoStruct[0]) free(histoStruct[0]);
        if (histoStruct[1]) free(histoStruct[1]);
        if (histoStruct[2]) free(histoStruct[2]);
        if (histoStruct[3]) free(histoStruct[3]);
        
        histoStruct[0] = NULL;
        histoStruct[1] = NULL;
        histoStruct[2] = NULL;
        histoStruct[3] = NULL;
    }

    [super dealloc];
}
//-(void)setHistogram:(NSUInteger *)histogram{
//}
-(void)createHistogram{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (!self.image) return; // TODO: do this better, failBlock?
    
    CVPixelBufferLockBaseAddress(self.image, 0);
    
    UInt8*  pixels8  = CVPixelBufferGetBaseAddress(self.image);
    UInt16* pixels16 = CVPixelBufferGetBaseAddress(self.image);
    
    BOOL is16bit = (CVPixelBufferGetPixelFormatType(self.image) == (OSType)'b16g');
    self.maxPossibleIntensity = (is16bit)?65536:256;

    // C-stuff, for speed

    if (self.histogram != NULL) {
        free(self.histogram);
        self.histogram = NULL;
    }
    
    if (is16bit) {
        self.histogram = (NSUInteger*)malloc(65536 * sizeof(NSUInteger));
        memset(self.histogram, 0, 65536 * sizeof(int));
    }
    else{
        self.histogram = (NSUInteger*)malloc(4 * 256 * sizeof(NSUInteger));
        memset(self.histogram, 0, 4 * 256 * sizeof(int));
    }
    
    NSMutableArray* aryComponents = [NSMutableArray array];
    UInt8 nComponents = 0; 
    
    if (is16bit) {
        [aryComponents addObject:[NSNumber numberWithInt:0]]; 
        nComponents = 1;
    }
    else{
        // Pixel offset, assume Pixelbuffer is ARGB 32bit Big Endian format
        // TODO: Clean this mess up
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
        nComponents = 4;
    }
    
    self.nColorComponents = nComponents; // Right now used for memory management
    self.validColorComponents = aryComponents;
    
    if (histoStruct != NULL) {
        if (histoStruct[0]) free(histoStruct[0]);
        if (histoStruct[1]) free(histoStruct[1]);
        if (histoStruct[2]) free(histoStruct[2]);
        if (histoStruct[3]) free(histoStruct[3]);
        
        histoStruct[0] = NULL;
        histoStruct[1] = NULL;
        histoStruct[2] = NULL;
        histoStruct[3] = NULL;
    }
    
    histoStruct[0] = (HistogramStruct*)malloc(sizeof(HistogramStruct));
    histoStruct[1] = (HistogramStruct*)malloc(sizeof(HistogramStruct));
    histoStruct[2] = (HistogramStruct*)malloc(sizeof(HistogramStruct));
    histoStruct[3] = (HistogramStruct*)malloc(sizeof(HistogramStruct));

    memset(histoStruct[0], 0, sizeof(HistogramStruct));
    memset(histoStruct[1], 0, sizeof(HistogramStruct));
    memset(histoStruct[2], 0, sizeof(HistogramStruct));
    memset(histoStruct[3], 0, sizeof(HistogramStruct));
    
    NSInteger ii = 0;
    NSInteger offset = 0;
    NSUInteger frequency = 0;
    NSUInteger histValue = 0;
    NSUInteger prevValue = 0;
    NSUInteger bufferSize = CVPixelBufferGetDataSize(self.image);
    
    if (is16bit) bufferSize /=2;
    
    // Generate histogram
    
    for (NSNumber* n in aryComponents) {
        offset = [n integerValue];
        
        for (ii = 0; ii < bufferSize; ii+=nComponents) {
        
            if (is16bit) {
                frequency = pixels16[ii + offset];
            }else{
                frequency = pixels8[ii + offset];
            }

            if (frequency > 0)
                histogram[offset * 256 + frequency] += 1; // With offset 0 for 16 bit, this will work for bith 8bit RGBA and 16bit Grayscale case
        }
    }

    // In case we're doing accumulative stuff
    switch (self.histogramType) {
        case EHistogramTypeCumulative:
            for (NSNumber* n in aryComponents) {
                offset = [n integerValue];
                prevValue = 0;
                
                for (ii = 0; ii < self.maxPossibleIntensity; ii++) {
                    histValue = histogram[offset * 256 + ii];
                    histogram[offset * 256 + ii] = histValue + prevValue;
                    prevValue = histValue + prevValue;
                }
            }
            break;
        case EHistogramTypeReverseCumulative:
            for (NSNumber* n in aryComponents) {
                offset = [n integerValue];
                prevValue = 0;
                
                for (ii = self.maxPossibleIntensity - 1; ii >= 0; ii--) {
                    histValue = histogram[offset * 256 + ii];
                    histogram[offset * 256 + ii] = histValue + prevValue;
                    prevValue = histValue + prevValue;
                }
            }
            break;
        default:
            break;
    }

    
    NSInteger minFrequency = 9999;
    NSInteger maxFrequency = 0;
    NSInteger minIntensity = 9999;
    NSInteger maxIntensity = 0;
    BOOL foundMinFreq      = NO;
    EPixelBufferComponent currentPixelBufferComponent = EPixelBufferNone;
    
    // Store in obj-c array and dictionary
    // Ponder this: Should the histogram simply be an array with NSIndexPath objects? [Component].[Intensity].[Hits] .. Probably not 
    // Might wanna use c-structs for this instead. 
    for (NSNumber* n in aryComponents) {
        offset = [n integerValue];
        
        switch (offset) {
            case 0: 
                if (is16bit) {
                    currentPixelBufferComponent = EPixelBuffer16GrayScale;
                }
                else{
                    currentPixelBufferComponent = EPixelBufferAlpha;
                }
                break;
            case 1:currentPixelBufferComponent = EPixelBufferRed;
                break;
            case 2:currentPixelBufferComponent = EPixelBufferGreen;
                break;
            case 3:currentPixelBufferComponent = EPixelBufferBlue;
                break;
            default:
                currentPixelBufferComponent = EPixelBufferNone; // Should never be here
                break;
        }
        
        minFrequency = 9999;
        maxFrequency = 0;
        minIntensity = 0;
        maxIntensity = 0;
        foundMinFreq = NO;

        for (ii = 0; ii < self.maxPossibleIntensity; ii++) {
            
            frequency = histogram[offset * 256 + ii];
            
            if (minFrequency > frequency) minFrequency = frequency;
            if (maxFrequency < frequency) maxFrequency = frequency;
            
            if (frequency > 0) {
                foundMinFreq = YES; // First color with frequency > 0
                maxIntensity = ii;
                
            }else{
                if (!foundMinFreq) {
                    minIntensity = ii;
                }
            }
        }
        
        histoStruct[offset]->minFrequency   = minFrequency;
        histoStruct[offset]->maxFrequency   = maxFrequency;
        histoStruct[offset]->minIntensity   = minIntensity;
        histoStruct[offset]->maxIntensity   = maxIntensity;
        histoStruct[offset]->colorComponent = currentPixelBufferComponent;
    }
    
    CVPixelBufferUnlockBaseAddress(self.image, 0);

    if (self.finishBlock) {
        self.finishBlock(self);
    }
    [pool drain];
}

#pragma mark - HistogramDataSource
-(NSUInteger)upperIntensityLimit{
    return self.maxPossibleIntensity;
}
-(NSArray*)allColorComponents{
    return self.validColorComponents;
}
-(NSUInteger)numberOfColorComponents{
    return self.nColorComponents;
}
-(EPixelBufferComponent)colorComponents{
    return self.histogramPixelBufferComponent;
}
-(NSInteger)numberOfFrequencies:(NSUInteger)component{ // TODO: Max - Min or actual counted user frequencies?
    NSUInteger retVal = 0;
    
    if (component > self.nColorComponents) return retVal; // Abort, maybe with a message

    return (histoStruct[component]->maxFrequency - histoStruct[component]->minFrequency);
}
-(NSUInteger)frequencyForIntensity:(NSUInteger)intensity inComponent:(NSUInteger)component{
    NSUInteger retVal = 0;
    
    if (component >= self.nColorComponents) return retVal; // Abort, maybe with a message
    if (intensity >  self.maxPossibleIntensity) return retVal;
    
    return self.histogram[component * 256 + intensity]; // Again.. grayscale component has to be 0
}
-(NSUInteger)maxIntensity:(NSUInteger)component{
    if (component >= self.nColorComponents) return 0; // Abort, maybe with a message

    return histoStruct[component]->maxIntensity;
}
-(NSUInteger)minIntensity:(NSUInteger)component{
    if (component >= self.nColorComponents) return 0; // Abort, maybe with a message
    return histoStruct[component]->minIntensity;
}
-(NSUInteger)maxFrequency:(NSUInteger)component{
    if (component >= self.nColorComponents) return 0; // Abort, maybe with a message
    return histoStruct[component]->maxFrequency;
}
-(NSUInteger)minFrequency:(NSUInteger)component{
    if (component >= self.nColorComponents) return 0; // Abort, maybe with a message
    return histoStruct[component]->minFrequency;
}


@end
