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
@property (nonatomic, retain) NSDictionary* histogram;
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
//@synthesize useComponents;
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
        //        self.useComponents    = EPixelBufferAllColors;
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
    //    self.histogramObject.histogramPixelBufferComponent = self.useComponents;
    self.histogramObject.histogramType  = self.histogramType;
    self.histogramObject.image          = inputForHistogram;
    self.histogramObject.finishBlock    = ^(NSObject<HistogramDataSource>* histSource){
        //        self.histogram = dic;
        
        if (self.delegate) {
            [self.delegate didFinish:inputForHistogram withHistogram:histSource];
        }
    };
    
    [self.loadingView startProgress];
    [self performSelectorInBackground:@selector(executeInBackground) withObject:nil];
}

-(void)executeInBackground{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 
    DLog(@"Background execution");
    
    [self.histogramObject createHistogram:nil];
    // Reorder histogram to internal representation
    
    // TODO: Can I do this another way?
    [self.loadingView performSelectorOnMainThread:@selector(stopProgress) withObject:nil waitUntilDone:NO];
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
    [pool drain];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context    = UIGraphicsGetCurrentContext();
    CGColorRef color        = self.histogramColor.CGColor;
    
    CGRect totalRect        = self.bounds;//CGRectInset(self.bounds, 10, 10);
    
    CGRect loadingRect = CGRectCenteredInRect(totalRect, CGSizeMake(30, 30));
    self.loadingView.frame = loadingRect;
    
    NSInteger minFreq       = 0;
    NSInteger maxFreq       = 0;
    NSInteger minIntensity = 0;
    NSInteger maxIntensity = 0;
    
    // Decide what calculation method to use. 
    GraphCalculator graphFunction = ^(CGFloat input){return input;};
    
    if (self.logHistogram) {
        graphFunction = ^(CGFloat input){return logf(input);};
    }
    
    minFreq       = 0;
    maxFreq       = 0;
    minIntensity = [self.histogramObject histogramMinIntensity]; // Might never use this
    maxIntensity = [self.histogramObject histogramMaxIntensity];
    
    NSInteger nValues       = [self.histogramObject histogramMaxIntensity] - [self.histogramObject histogramMinIntensity]; // Remove statistics dictionary
    CGRect nextRect         = totalRect;
    CGFloat height          = totalRect.size.height/([self.histogramObject histogramMaxIntensity]==0?1:[self.histogramObject histogramMaxIntensity]);
    
    if (self.stretchHistogram) {
        height = totalRect.size.height/nValues;
        
        minFreq = [self.histogramObject histogramMinFrequency];
        maxFreq = [self.histogramObject histogramMaxFrequency];
    }
    
    nextRect.size = CGSizeMake(0, height); 
    
    CGContextSetFillColorWithColor(context, color);
    
    for (NSUInteger ii = minFreq; ii < nValues; ii++) {
        nextRect.size.width = graphFunction((CGFloat)[self.histogramObject frequecyForIntensity:ii])/graphFunction((CGFloat)maxIntensity) * totalRect.size.width;
        nextRect.origin.y   = totalRect.origin.y + (ii - minFreq) * height;
        CGContextAddRect(context, CGRectIntegral(nextRect));
    }
    
    CGContextFillPath(context);

}

@end
