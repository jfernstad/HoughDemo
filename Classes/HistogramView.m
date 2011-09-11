//
//  HistogramView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HistogramView.h"
#import "LoadingView.h"
#import "UIColor+HoughExtensions.h"
#import "CGGeometry+HoughExtensions.h"

typedef CGFloat(^GraphCalculator)(CGFloat);

@interface HistogramView()
-(void)execute;
@property (nonatomic, retain) NSDictionary* histogram;
@property (nonatomic, retain) LoadingView* loadingView;
@end

@implementation HistogramView
@synthesize image;
@synthesize histogram;
@synthesize histogramColor;
@synthesize loadingView;
@synthesize useComponents;
@synthesize stretchHistogram;
@synthesize logHistogram;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        loadingView = [[LoadingView alloc] initWithFrame:CGRectZero];
        loadingView.backgroundColor = [UIColor clearColor];
        self.backgroundColor  = [UIColor colorWithWhite:0.3 alpha:0.5];
        self.useComponents    = EPixelBufferAllColors;
        self.stretchHistogram = NO;
        self.logHistogram     = NO;
        
        [self addSubview:loadingView];
    }
    return self;
}

-(void)dealloc{

    self.image = nil;
    self.loadingView = nil;
    self.histogram = nil;
    self.histogramColor = nil;

    [super dealloc];
}

-(void)setImage:(CVPixelBufferRef)newImage{
    // Start loading view?
    // Start histogram operation?
    [self.loadingView startProgress];
    
    if (image != newImage) {
        CVPixelBufferRetain(newImage);
        CVPixelBufferRelease(image);
        image = newImage;
    }
    
    [self performSelectorInBackground:@selector(execute) withObject:nil];
}

-(void)execute{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
    
    [ImageHist histoGramWithCVPixelBuffer:self.image
                              onComponent:self.useComponents
                              finishBlock:^(NSDictionary* dic){
                                  self.histogram = dic;
                              }];
    
    [self.loadingView stopProgress];

    // Reorder histogram to internal representation
    
    [self setNeedsDisplay];
    // Remove loading view
    [pool drain];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSDictionary* curDic    = nil;
    NSDictionary* statsDic  = nil;
	CGContextRef context    = UIGraphicsGetCurrentContext();
    CGColorRef color        = self.histogramColor.CGColor;
    NSArray* keys           = [self.histogram allKeys];
    CGFloat alpha           = MIN(MAX(1,keys.count),3);

    CGRect totalRect        = CGRectInset(self.bounds, 10, 10);

    CGRect loadingRect = CGRectCenteredInRect(totalRect, CGSizeMake(30, 30));
    self.loadingView.frame = loadingRect;
    
    EPixelBufferComponent component = EPixelBufferNone;
    NSInteger minVal       = 0;
    NSInteger maxVal       = 0;
    NSInteger minIntensity = 0;
    NSInteger maxIntensity = 0;
    
    // Decide what calculation method to use. 
    
    GraphCalculator graphFunction = ^(CGFloat input){return input;};
    
    if (self.logHistogram) {
        graphFunction = ^(CGFloat input){return logf(input);};
    }

    NSUInteger nValidComponents = 0;
    
    // Count number of valid components in histogram
    for (NSNumber* n in keys){
        component = (EPixelBufferComponent)[n intValue];
        
        if ((1 << component) & self.useComponents) {
            nValidComponents++;
        }
    }
    
    for (NSNumber* n in keys) {
        
        component = (EPixelBufferComponent)[n intValue];
        
        // Hide this component;
        if (!((1 << component) & self.useComponents)) {
            continue;
        }
        
        curDic   = [self.histogram objectForKey:n];
        statsDic = [curDic objectForKey:kHistogramStatisticsKey];
        
        minVal       = 0;
        maxVal       = 255;
        minIntensity = [[statsDic objectForKey:kHistogramMinIntensityKey] integerValue]; // Might never use this
        maxIntensity = [[statsDic objectForKey:kHistogramMaxIntensityKey] integerValue];

        if (!self.histogramColor) {
            if ((1 << component) == EPixelBufferAlpha) {
                color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1/alpha].CGColor;
            }
            if ((1 << component) == EPixelBufferRed) {
                color = [UIColor colorWithRed:1 green:0 blue:0 alpha:1/alpha].CGColor;
                NSLog(@"RED");
            }
            if ((1 << component) == EPixelBufferGreen) {
                color = [UIColor colorWithRed:0 green:1 blue:0 alpha:1/alpha].CGColor;
                NSLog(@"GREEN");
            }
            if ((1 << component) == EPixelBufferBlue) {
                color = [UIColor colorWithRed:0 green:0 blue:1 alpha:1/alpha].CGColor;
                NSLog(@"BLUE");
            }
        }
        
        NSArray* componentKeys  = [curDic allKeys];
        NSInteger nValues       = componentKeys.count - 1; // Remove statistics dictionary
        CGRect nextRect         = totalRect;
        CGFloat height          = totalRect.size.height/255.0;
        
        // TODO: Don't do this if we have several components in histogram.
        if (self.stretchHistogram && nValidComponents == 1) {
            height = totalRect.size.height/nValues;

            minVal = [[statsDic objectForKey:kHistogramMinValueKey] integerValue];
            maxVal = [[statsDic objectForKey:kHistogramMaxValueKey] integerValue];
        
            // Guard edges
            minVal = MIN(MAX(minVal, 0),255);
            maxVal = MIN(MAX(maxVal, 0),255);
        }
        
        nextRect.size = CGSizeMake(0, height); 
        
        CGContextSetFillColorWithColor(context, color);
        
        for (NSNumber* compNum in componentKeys) {

            // Don't do this for other data types in the array
            if ([compNum isKindOfClass:[NSNumber class]]) {
                nextRect.size.width = graphFunction((CGFloat)[(NSNumber*)[curDic objectForKey:compNum] intValue])/graphFunction((CGFloat)maxIntensity) * totalRect.size.width;
                nextRect.origin.y   = totalRect.origin.y + ([compNum intValue] - minVal) * height;
                CGContextAddRect(context, CGRectIntegral(nextRect));
            }
        }
    
        CGContextFillPath(context);
    }
}

@end
