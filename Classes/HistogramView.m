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
@property (nonatomic, retain) ImageHist* histogramObject;
@property (nonatomic, assign) id<HistogramDataSource> histogram;
@property (nonatomic, retain) LoadingView* loadingView;
-(void)executeInBackground;
@end

@implementation HistogramView
@synthesize histogram;
@synthesize histogramType;
@synthesize histogramStyle;
@synthesize histogramColor;
@synthesize histogramObject;
@synthesize loadingView;
@synthesize useComponents;
@synthesize stretchHistogram;
@synthesize logHistogram;
@synthesize delegate;
@synthesize histogramInput;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        loadingView = [[LoadingView alloc] initWithFrame:CGRectZero];
        loadingView.backgroundColor = [UIColor clearColor];
        self.backgroundColor  = [UIColor colorWithWhite:0.3 alpha:0.5];
        self.useComponents    = EPixelBufferNone;
        self.stretchHistogram = NO;
        self.logHistogram     = NO;
        self.histogramType    = EHistogramTypeNormal;
        self.histogramObject = [[[ImageHist alloc] init] autorelease]; // Use default settings
        self.delegate = nil;
        
        [self addSubview:loadingView];
    }
    return self;
}

-(void)dealloc{

    self.loadingView = nil;
    
    self.histogram = nil;
    self.histogramColor = nil;
    self.histogramObject = nil;
    self.histogramInput = nil;
    
    [super dealloc];
}

-(void)setHistogramStyle:(EHistogramStyle)newHistogramStyle{
    CGAffineTransform newTransform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);

    histogramStyle = newHistogramStyle;
    
    if (self.histogramStyle & EHistogramStyleFlipVertical) {
        newTransform.a = -1;
    }
    if (self.histogramStyle & EHistogramStyleFlipHorizontal) {
        newTransform.d = -1;
    }

    self.transform = newTransform;
}

-(void)executeWithImage:(CVPixelBufferRef)inputForHistogram{
    DLog(@"Execute histogramView");
    self.histogramObject.histogramPixelBufferComponent = self.useComponents;
    self.histogramObject.histogramType  = self.histogramType;
    self.histogramObject.image          = inputForHistogram;
    self.histogramObject.finishBlock    = ^(id<HistogramDataSource> newHistogram){
        self.histogram = newHistogram;
    
        if (self.delegate) {
            [self.delegate didFinish:inputForHistogram withHistogram:newHistogram];
        }
    };

    [self.loadingView startProgress];
    [self performSelectorInBackground:@selector(executeInBackground) withObject:nil];
}

-(void)executeInBackground{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
    DLog(@"Background execution");

    [self.histogramObject createHistogram];
    // Reorder histogram to internal representation

    // TODO: Can I do this another way?
    [self.loadingView performSelectorOnMainThread:@selector(stopProgress) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    [pool drain];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
//    NSDictionary* curDic    = nil;
//    NSDictionary* statsDic  = nil;
	CGContextRef context    = UIGraphicsGetCurrentContext();
    CGColorRef color        = self.histogramColor.CGColor;
//    NSArray* keys           = [self.histogram allKeys];
    NSUInteger nComponents = [self.histogram numberOfColorComponents];
    CGFloat alpha           = MIN(MAX(1,nComponents),3);

    CGRect totalRect        = self.bounds;//CGRectInset(self.bounds, 10, 10);

    CGRect loadingRect = CGRectCenteredInRect(totalRect, CGSizeMake(30, 30));
    self.loadingView.frame = loadingRect;
    
    NSInteger minFrequency = 0;
    NSInteger maxFrequency = 0;
    NSInteger minIntensity = 0;
    NSInteger maxIntensity = 0;
    
    // Decide what calculation method to use. 
    
    GraphCalculator graphFunction = ^(CGFloat input){return input;};
    
    if (self.logHistogram) {
        graphFunction = ^(CGFloat input){return logf(input);};
    }

    NSUInteger nValidComponents = 0;
    
    // Count number of valid components in histogram
    int component = 0;
    EPixelBufferComponent colorComponent = EPixelBufferNone;

    for (NSNumber* n in [self.histogram allColorComponents]){
        component = (EPixelBufferComponent)[n intValue];
        
        if ((1 << component) & self.useComponents) {
            nValidComponents++;
        }
    }
    
    for (NSNumber* n in [self.histogram allColorComponents]) {
        
        colorComponent = (EPixelBufferComponent)[n intValue];
        component = [n intValue];
        
        // Hide this component;
        if (!((1 << component) & self.useComponents)) {
            continue;
        }
        
        minFrequency = [self.histogram minFrequency:component];  // Might never use this
        maxFrequency = [self.histogram maxFrequency:component];
        minIntensity = 0;
        maxIntensity = [self.histogram upperIntensityLimit];

        if (!self.histogramColor) {
            if ((1 << component) == EPixelBufferAlpha) {
                color = [UIColor colorWithRed:1 green:1 blue:1 alpha:1/alpha].CGColor;
            }
            if ((1 << component) == EPixelBufferRed) {
                color = [UIColor colorWithRed:1 green:0 blue:0 alpha:1/alpha].CGColor;
                DLog(@"RED");
            }
            if ((1 << component) == EPixelBufferGreen) {
                color = [UIColor colorWithRed:0 green:1 blue:0 alpha:1/alpha].CGColor;
                DLog(@"GREEN");
            }
            if ((1 << component) == EPixelBufferBlue) {
                color = [UIColor colorWithRed:0 green:0 blue:1 alpha:1/alpha].CGColor;
                DLog(@"BLUE");
            }
        }
        
        CGRect nextRect         = totalRect;
        CGFloat height          = totalRect.size.height/[self.histogram upperIntensityLimit];
        
        if (self.stretchHistogram && nValidComponents == 1) {
            height = totalRect.size.height/[self.histogram numberOfFrequencies:component];

            minFrequency = [self.histogram minFrequency:component];
            maxFrequency = [self.histogram maxFrequency:component];
        
        }
        
        nextRect.size = CGSizeMake(0, height); 
        
        CGContextSetFillColorWithColor(context, color);
        
        NSUInteger frequency = 0;
        for (NSUInteger intensity = minIntensity; intensity < maxIntensity; intensity++) {
            frequency = [self.histogram frequencyForIntensity:intensity inComponent:component];
            nextRect.size.width = graphFunction((CGFloat)frequency)/graphFunction((CGFloat)maxFrequency) * totalRect.size.width;
            nextRect.origin.y   = totalRect.origin.y + (intensity - minIntensity) * height;
            CGContextAddRect(context, CGRectIntegral(nextRect));
        }
    
        CGContextFillPath(context);
    }
}

@end
