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
#import "HoughConstants.h"

@interface ImageConfigurationView()
@property (nonatomic, retain) HistogramControl* grayHistControl;
@property (nonatomic, retain) HistogramControl* houghHistControl;
#ifdef DEBUG
@property (nonatomic, retain) UISwitch* debugSwitch;
#endif

// Methods
-(void)layoutViews;
-(void)grayThresholdSet:(id)sender;
-(void)houghThresholdSet:(id)sender;
#ifdef DEBUG
-(void)enableDebug:(id)sender;
#endif
@end

@implementation ImageConfigurationView
@synthesize grayHistControl;
@synthesize houghHistControl;
#ifdef DEBUG
@synthesize debugSwitch;
#endif

-(id)initWithFrame:(CGRect)frame{

    if ((self = [super initWithFrame:frame])) {
        self.grayHistControl  = [[[HistogramControl alloc] initWithFrame:CGRectZero] autorelease];
        self.houghHistControl = [[[HistogramControl alloc] initWithFrame:CGRectZero] autorelease];
    
        [self.grayHistControl addTarget:self action:@selector(grayThresholdSet:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self.houghHistControl addTarget:self action:@selector(houghThresholdSet:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        self.grayHistControl.logHistogram = YES;
        self.grayHistControl.histogramColor = [UIColor houghYellow];
        self.grayHistControl.histogramType  = EHistogramTypeNormal; // High intensity = Low count
        self.grayHistControl.histogramStyle = EHistogramStyleFlipHorizontal; // Top = High intensity
        self.houghHistControl.positionSliderToLeft = NO;
        
        self.houghHistControl.logHistogram = YES;
        self.houghHistControl.histogramColor = [UIColor houghYellow];
        self.houghHistControl.histogramType  = EHistogramTypeReverseCumulative; // High intensity = Low count
        self.houghHistControl.histogramStyle = EHistoGramStyleFlipBoth; // Top = High intensity
        self.houghHistControl.positionSliderToLeft = YES;
        
#ifdef DEBUG
        self.debugSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
        self.debugSwitch.on = YES;
        [self.debugSwitch addTarget:self action:@selector(enableDebug:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self addSubview:self.debugSwitch];
#endif
        
        
        [self addSubview:self.grayHistControl];
        [self addSubview:self.houghHistControl];
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
#ifdef DEBUG
    self.debugSwitch = nil;
#endif

    [super dealloc];
}

#pragma mark - Setup
-(void)layoutViews{

    CGFloat histWidth = 200; 
    CGRect totalRect = self.bounds;
    CGRect tmpRect = CGRectZero;
    CGRect gRect = totalRect;
    CGRect hRect = totalRect;

    CGRectDivide(totalRect, &gRect, &tmpRect, histWidth, CGRectMinXEdge);
    CGRectDivide(totalRect, &hRect, &tmpRect, histWidth, CGRectMaxXEdge);

#ifdef DEBUG
    CGRect debugRect = CGRectMake(10, 10, 50, 30);
    gRect = CGRectInset(gRect, 0, 40);
    gRect.size.height += 40;
    self.debugSwitch.frame = debugRect;
#endif

    self.grayHistControl.frame = gRect;
    self.houghHistControl.frame = hRect;
    
}

#pragma mark - Slider delegates
#ifdef DEBUG
-(void)enableDebug:(id)sender{
    DLog(@"grayThresholdSet");
    
    BOOL debug = self.debugSwitch.on;
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:debug] forKey:kHoughDebugFlagChanged];
    
    [self.delegate updateConfigurationWithDictionary:dic];
}
#endif

-(void)grayThresholdSet:(id)sender{
    DLog(@"grayThresholdSet");
    
    NSInteger thres = self.grayHistControl.value;
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:thres] forKey:kHoughGrayscaleThresholdChanged];
    
    [self.delegate updateConfigurationWithDictionary:dic];
}
-(void)houghThresholdSet:(id)sender{
    DLog(@"houghThresholdSet");

    NSInteger thres = self.houghHistControl.value;
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:thres] forKey:kHoughThresholdChanged];
    
    [self.delegate updateConfigurationWithDictionary:dic];
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
