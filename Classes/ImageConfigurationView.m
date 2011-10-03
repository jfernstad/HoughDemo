//
//  ImageConfigurationView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 10/2/11.
//  Copyright (c) 2011 Joakim Fernstad. All rights reserved.
//

#import "ImageConfigurationView.h"
#import "UIColor+HoughExtensions.h"
#import "HistogramControl.h"

@interface ImageConfigurationView()
@property (nonatomic, retain) HistogramControl* grayHistControl;
@property (nonatomic, retain) HistogramControl* houghHistControl;

// Methods
-(void)layoutViews;
-(void)grayThresholdSet:(id)sender;
-(void)houghThresholdSet:(id)sender;
@end

@implementation ImageConfigurationView
@synthesize grayHistControl;
@synthesize houghHistControl;

-(id)initWithFrame:(CGRect)frame{

    if ((self = [super initWithFrame:frame])) {
        self.grayHistControl  = [[[HistogramControl alloc] initWithFrame:CGRectZero] autorelease];
        self.houghHistControl = [[[HistogramControl alloc] initWithFrame:CGRectZero] autorelease];
    
        [self.grayHistControl addTarget:self action:@selector(grayThresholdSet:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self.houghHistControl addTarget:self action:@selector(houghThresholdSet:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        self.grayHistControl.logHistogram = NO;
        self.grayHistControl.histogramColor = [UIColor houghRed];
        self.grayHistControl.histogramType  = EHistogramTypeReverseCumulative;
        
        [self addSubview:self.grayHistControl];
        [self layoutViews];
    
        // Debug colors
//        self.grayscaleSlider.backgroundColor = [UIColor redColor];
//        self.grayscaleHisto.backgroundColor  = [UIColor greenColor];
//        self.backgroundColor = [UIColor blueColor];
    
        originalRect = frame;
    }
    return self;
}

-(void)dealloc{
    
    self.grayHistControl = nil;
    self.houghHistControl = nil;

    [super dealloc];
}

#pragma mark - Setup
-(void)layoutViews{
    
    CGRect totalRect = self.bounds;
    CGRect gRect = totalRect;

    self.grayHistControl.frame = gRect;
    self.houghHistControl.frame = CGRectZero;
    
}

#pragma mark - Slider delegates

-(void)grayThresholdSet:(id)sender{
    NSLog(@"grayThresholdSet");
}
-(void)houghThresholdSet:(id)sender{
    NSLog(@"houghThresholdSet");
}

#pragma mark - Overrides
-(void)showViewAnimated:(BOOL)useAnimation{
}
-(void)dismissViewAnimated:(BOOL)useAnimation{
}
-(void)updatePosition:(CGPoint)startPos withPosition:(CGPoint)newPoint{
}
#pragma mark - Input methods

-(void)setGrayscaleInput:(CVPixelBufferRef)newGrayImage{
    [self.grayHistControl setHistogramImage:newGrayImage];
}
-(void)setHoughInput:(CVPixelBufferRef)newHoughImage{
    [self.houghHistControl setHistogramImage:newHoughImage];
}

@end
