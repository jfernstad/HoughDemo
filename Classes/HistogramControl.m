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
//@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef grayscaleImage;
//@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef houghImage;

// Methods
-(void)layoutViews;
-(void)sliderChanged:(id)sender;
-(void)sliderEnd:(id)sender;
@end

@implementation HistogramControl
@synthesize histogram;
@synthesize slider;
@synthesize histoCover;
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
    
    CGRect totalRect = self.bounds;
    CGRect histoRect = CGRectInset(totalRect, 10, 10);
    CGRect sliderRect = CGRectZero;
    
    self.histogram.frame  = histoRect;
    self.histoCover.frame = histoRect;
    
    // TODO: Placement should be a flag
    sliderRect = CGRectMake(CGRectGetMaxX(totalRect)- 10 , totalRect.origin.y, 10, totalRect.size.height);
    
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
    CGFloat value = self.slider.value;
    
    CGFloat newHeight = histoRect.size.height * value/(max - min);
    
    CGRectDivide(histoRect, &histoRect, &coverRect, newHeight, CGRectMinYEdge);
    
    self.histoCover.frame = coverRect;

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}
-(void)sliderEnd:(id)sender{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Delegates

-(void)didFinish:(CVImageBufferRef)image withHistogram:(NSDictionary *)dictionary{
    NSLog(@"didFinishWithHistogram");
    
    // TODO: Harvest info from histograms and add to the histograms
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
-(BOOL)stretchHistogram                 {return self.histogram.stretchHistogram;}
-(BOOL)logHistogram                     {return self.histogram.logHistogram;}
-(CVPixelBufferRef)histogramInput       {return self.histogram.histogramInput;}
@end
