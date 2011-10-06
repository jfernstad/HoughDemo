//
//  HistogramControl.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 10/2/11.
//  Copyright (c) 2011 Joakim Fernstad. All rights reserved.
//

#import "HistogramControl.h"
#import "UIColor+HoughExtensions.h"

@interface HistogramControl ()
@property (nonatomic, retain) HistogramView* histogram;
@property (nonatomic, retain) UISlider* slider;
@property (nonatomic, retain) UIImageView* histoCover;
@property (nonatomic, assign, readwrite) NSInteger value;

//@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef grayscaleImage;
//@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef houghImage;

// Methods
-(void)layoutViews;
-(void)sliderChanged:(id)sender;
-(void)sliderEnd:(id)sender;
@end

@implementation HistogramControl
@synthesize value;
@synthesize histogram;
@synthesize slider;
@synthesize histoCover;
@synthesize positionSliderToLeft;
// From protocol
@synthesize histogramColor;
@synthesize useComponents;
@synthesize histogramType;
@synthesize stretchHistogram;
@synthesize logHistogram;
@synthesize histogramInput;

-(id)initWithFrame:(CGRect)frame{
    
    if ((self = [super initWithFrame:frame])) {
        
        self.histogram  = [[[HistogramView alloc] initWithFrame:CGRectZero] autorelease];
        self.slider     = [[[UISlider alloc] initWithFrame:CGRectZero] autorelease];
        self.histoCover = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        
        [self.slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(sliderEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        self.histoCover = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"semitransparent.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:1]] autorelease];
        
        self.histogram.delegate = self;
        
        self.positionSliderToLeft = NO;
        self.value = 0;
        
        [self addSubview:self.histogram];
        [self addSubview:self.histoCover];
        [self addSubview:self.slider];
        
        [self layoutViews];
    }
    return self;
}

-(void)dealloc{
    
    self.histogram = nil;
    self.slider = nil;
    self.histoCover = nil;
    
    [super dealloc];
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self layoutViews];
}
#pragma mark - Setup
-(void)layoutViews{
    
    CGFloat padding   = 10.0;
    CGRect totalRect  = self.bounds;
    CGRect histoRect  = CGRectZero;
    CGRect sliderRect = CGRectZero;
    
    histoRect.size.width -= padding;
    
    if (self.positionSliderToLeft){
        CGRectDivide(totalRect, &sliderRect, &histoRect, padding, CGRectMinXEdge);
    }
    else{
        CGRectDivide(totalRect, &sliderRect, &histoRect, padding, CGRectMaxXEdge);
    }
    
    histoRect = CGRectInset(histoRect, 0, padding);
    
    self.histogram.frame  = histoRect;
    self.histoCover.frame = histoRect;
    
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 0.5);
    self.slider.transform = trans;
    self.slider.frame = sliderRect;
}

#pragma mark - Methods

-(void)setHistogramImage:(CVPixelBufferRef)newImage{
    [self.histogram executeWithImage:newImage];
}
-(void)sliderChanged:(id)sender{
    CGRect histoRect = self.histogram.frame;
    CGRect coverRect = self.histoCover.frame;
    
    CGFloat min = self.slider.minimumValue;
    CGFloat max = self.slider.maximumValue;
    CGFloat sliderValue = self.slider.value;
    
    CGFloat newHeight = histoRect.size.height * sliderValue/(max - min);
    
    CGRectDivide(histoRect, &histoRect, &coverRect, newHeight, CGRectMinYEdge);
    
    self.histoCover.frame = coverRect;
    
    self.value = (NSInteger)sliderValue;
    [self sendActionsForControlEvents:UIControlEventValueChanged];

    NSLog(@"New value: %d", self.value);
}
-(void)sliderEnd:(id)sender{
    self.value = (NSInteger)self.slider.value;
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

// Convert slider value if histogram is flipped
-(NSInteger)value{
    NSInteger outValue = value;
    NSInteger sliderMin = self.slider.minimumValue;
    NSInteger sliderMax = self.slider.maximumValue;
    
    if (self.histogramStyle == EHistogramStyleFlipHorizontal) {
        outValue = (sliderMax - outValue) + sliderMin;
    }
    
    return outValue;
}
#pragma mark - Delegates

-(void)didFinish:(CVImageBufferRef)image withHistogram:(NSDictionary *)dictionary{
    NSLog(@"didFinishWithHistogram");
    NSArray* componentKeys = [dictionary allKeys];
    
    NSDictionary* tmpDict = nil;
    NSDictionary* statsDict = nil;
    NSNumber* tmpVal = nil;
    NSInteger minVal = 0;
    NSInteger maxVal = 0;
    NSInteger minInt = 0;
    NSInteger maxInt = 0;
    
    if (componentKeys.count > 0) {
        
        tmpDict   = [dictionary objectForKey:[componentKeys objectAtIndex:0]]; // TODO: Don't always take first object, think about it.
        statsDict = [tmpDict objectForKey:kHistogramStatisticsKey];
        
        tmpVal = [statsDict objectForKey:kHistogramMinValueKey];
        minVal = tmpVal.integerValue;
        
        tmpVal = [statsDict objectForKey:kHistogramMaxValueKey];
        maxVal = tmpVal.integerValue;
        
        tmpVal = [statsDict objectForKey:kHistogramMinIntensityKey];
        minInt = tmpVal.integerValue;
        
        tmpVal = [statsDict objectForKey:kHistogramMaxIntensityKey];
        maxInt = tmpVal.integerValue;
        
        self.slider.minimumValue = minVal;
        self.slider.maximumValue = maxVal;
    }
}

#pragma mark - Protocol implementation
-(void)setHistogramColor:(UIColor *)newHistogramColor{
    self.histogram.histogramColor = newHistogramColor;
}
-(void)setUseComponents:(EPixelBufferComponent)newComponents{
    self.histogram.useComponents = newComponents;
}
-(void)setHistogramType:(EHistogramType)newHistogramType{
    self.histogram.histogramType = newHistogramType;
}
-(void)setHistogramStyle:(EHistogramStyle)newHistogramStyle{
    self.histogram.histogramStyle = newHistogramStyle;
}
-(void)setStretchHistogram:(BOOL)newStretchHistogram{
    self.histogram.stretchHistogram = newStretchHistogram;
}
-(void)setLogHistogram:(BOOL)newLogHistogram{
    self.histogram.logHistogram = newLogHistogram;
}
-(void)setHistogramInput:(CVPixelBufferRef)newHistogramInput{
    self.histogram.histogramInput = newHistogramInput;
}

-(UIColor*)histogramColor               {return self.histogram.histogramColor;}
-(EPixelBufferComponent)useComponents   {return self.histogram.useComponents;}
-(EHistogramType)histogramType          {return self.histogram.histogramType;}
-(EHistogramStyle)histogramStyle        {return self.histogram.histogramStyle;}
-(BOOL)stretchHistogram                 {return self.histogram.stretchHistogram;}
-(BOOL)logHistogram                     {return self.histogram.logHistogram;}
-(CVPixelBufferRef)histogramInput       {return self.histogram.histogramInput;}
@end
