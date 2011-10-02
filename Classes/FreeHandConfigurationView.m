//
//  FreehandConfigurationView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/11/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "FreeHandConfigurationView.h"
#import "CGGeometry+HoughExtensions.h"
#import "UIColor+HoughExtensions.h"
#import "HoughConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface FreeHandConfigurationView()
-(void)layoutViews;
@property (nonatomic, retain) UILabel* drawLabel;
@property (nonatomic, retain) UILabel* nLinesLabel;
@property (nonatomic, retain) UILabel* analysisLabel;
@property (nonatomic, retain) UILabel* thresholdLabel;
@property (nonatomic, retain) UISwitch* drawMode;
@property (nonatomic, retain) UISwitch* analysisMode;
@property (nonatomic, retain) UISlider* thresholdSlider;
@property (nonatomic, retain) UIView* container;

// Actions
-(void)analysisModeChanged:(id)sender;
-(void)drawModeChanged:(id)sender;
-(void)thresholdChanged:(id)sender;

@end

@implementation FreeHandConfigurationView
@synthesize drawMode;
@synthesize analysisMode;
@synthesize thresholdSlider;
@synthesize drawLabel;
@synthesize nLinesLabel;
@synthesize analysisLabel;
@synthesize thresholdLabel;
@synthesize container;

-(id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        
        CGSize lobeSize = self.lobeView.image.size;

        CGRect containerRect = CGRectZero;
        containerRect = CGRectOffset(containerRect, 0, -lobeSize.height);
        containerRect.size.width  = frame.size.width;
        containerRect.size.height = frame.size.height + lobeSize.height;
        contentRect = CGRectInset(containerRect,15,10);
        
        self.container = [[[UIView alloc] initWithFrame:containerRect] autorelease];
        
        self.container.layer.cornerRadius = CORNER_RADIUS;
        self.container.layer.borderWidth  = EDGE_WIDTH;
        self.container.layer.borderColor  = [UIColor borderColor].CGColor;
        self.container.backgroundColor    = [UIColor blackWithAlpha:0.5];
        self.container.autoresizingMask   = UIViewAutoresizingNone;
        
        self.drawMode        = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
        self.analysisMode    = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
        self.thresholdSlider = [[[UISlider alloc] initWithFrame:CGRectZero] autorelease];
        [self.drawMode        addTarget:self action:@selector(drawModeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self.analysisMode    addTarget:self action:@selector(analysisModeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self.thresholdSlider addTarget:self action:@selector(thresholdChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.drawMode.exclusiveTouch = YES;
        self.analysisMode.exclusiveTouch = YES;
        self.thresholdSlider.exclusiveTouch = YES;
        
        self.drawLabel      = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.nLinesLabel    = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.analysisLabel  = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.thresholdLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        
        self.drawLabel.text      = @"Draw mode";
        self.analysisLabel.text  = @"Auto analysis";
        self.thresholdLabel.text = @"Hough threshold ";

        self.drawLabel.font         = [UIFont boldSystemFontOfSize:17];
        self.nLinesLabel.font       = [UIFont boldSystemFontOfSize:17];
        self.analysisLabel.font     = [UIFont boldSystemFontOfSize:17];
        self.thresholdLabel.font    = [UIFont boldSystemFontOfSize:17];
        
        self.drawLabel.textColor      = [UIColor houghWhite];
        self.nLinesLabel.textColor    = [UIColor houghWhite];
        self.analysisLabel.textColor  = [UIColor houghWhite];
        self.thresholdLabel.textColor = [UIColor houghWhite];
            
        self.drawLabel.backgroundColor      = [UIColor clearColor];
        self.nLinesLabel.backgroundColor    = [UIColor clearColor];
        self.analysisLabel.backgroundColor  = [UIColor clearColor];
        self.thresholdLabel.backgroundColor = [UIColor clearColor];

        [self.drawLabel      sizeToFit];
        [self.analysisLabel  sizeToFit];
        [self.thresholdLabel sizeToFit];

        self.thresholdSlider.maximumValue = 100;
        self.thresholdSlider.minimumValue = 1;
        
        [self.container addSubview:self.drawLabel];
        [self.container addSubview:self.nLinesLabel];
        [self.container addSubview:self.analysisLabel];
        [self.container addSubview:self.thresholdLabel];
        
        [self.container addSubview:self.drawMode];
        [self.container addSubview:self.analysisMode];
        [self.container addSubview:self.thresholdSlider];

        [self addSubview:self.container];
        
        [self layoutViews];
    }
    return self;
}

-(void)dealloc{

    self.drawLabel       = nil;
    self.nLinesLabel     = nil;
    self.analysisLabel   = nil;
    self.thresholdLabel  = nil;
    self.drawMode        = nil;
    self.analysisMode    = nil;
    self.thresholdSlider = nil;
    self.container       = nil;
    
    [super dealloc];
}

-(void)layoutViews{
    CGRect newFrame           = self.frame;
    CGRect imgRect            = self.bounds;
    CGRect drawLabelRect      = CGRectZero;
    CGRect drawSwitchRect     = CGRectZero;
    CGRect analysisLabelRect  = CGRectZero;
    CGRect analysisSwitchRect = CGRectZero;
    CGRect sliderLabelRect    = CGRectZero;
    CGRect sliderRect         = CGRectZero;

    CGSize lobeSize = self.lobeView.image.size;
    CGRect wholeRect = CGRectOffset(contentRect, 0, 1.5*lobeSize.height);
    
    CGRectDivide(wholeRect, &drawLabelRect, &sliderLabelRect, contentRect.size.width/3, CGRectMinXEdge);
    CGRectDivide(drawLabelRect, &drawSwitchRect, &drawLabelRect, 100, CGRectMaxXEdge);

    sliderLabelRect = CGRectInset(sliderLabelRect, 20, 0);
    sliderLabelRect = CGRectOffset(sliderLabelRect, 10, 0);
    
    CGRectDivide(drawLabelRect, &drawLabelRect, &analysisLabelRect, contentRect.size.height/2, CGRectMinYEdge);
    CGRectDivide(drawSwitchRect, &drawSwitchRect, &analysisSwitchRect, contentRect.size.height/2, CGRectMinYEdge);
    CGRectDivide(sliderLabelRect, &sliderLabelRect, &sliderRect, contentRect.size.height/2, CGRectMinYEdge);
    
    // Tweaking
    drawSwitchRect     = CGRectCenteredInRect(drawSwitchRect, drawMode.bounds.size);
    analysisSwitchRect = CGRectCenteredInRect(analysisSwitchRect, analysisMode.bounds.size);
    
    self.drawLabel.frame        = CGRectIntegral(drawLabelRect);
    self.drawMode.frame         = CGRectIntegral(drawSwitchRect);
    self.analysisLabel.frame    = CGRectIntegral(analysisLabelRect);
    self.analysisMode.frame     = CGRectIntegral(analysisSwitchRect);
    self.thresholdLabel.frame   = CGRectIntegral(sliderLabelRect);
    self.thresholdSlider.frame  = CGRectIntegral(sliderRect);    
    
    [self.thresholdLabel sizeToFit];
    sliderLabelRect.size.width = self.thresholdLabel.bounds.size.width;
    self.thresholdLabel.frame = sliderLabelRect;
    CGRect nLinesRect = self.thresholdLabel.frame; 
    self.nLinesLabel.frame = CGRectOffset(nLinesRect, nLinesRect.size.width + 5, 0);
    
    // Stuff to do with Lobe
    newFrame.size.height = self.bounds.size.height + lobeSize.height;

    imgRect.origin = CGPointMake(CGRectGetMinX(self.container.frame), CGRectGetMaxY(self.container.frame));
    imgRect.size = CGSizeMake(self.container.frame.size.width, lobeSize.height);
    
    self.lobeView.frame = CGRectCenteredInRect(imgRect, lobeSize);
    
    // Hide everything except the lobe. 
    newFrame.origin.y = newFrame.origin.y - newFrame.size.height + lobeSize.height;
    
    self.frame = newFrame;
    self.backgroundView.frame = contentRect;
    originalRect = self.frame;
}

#pragma mark - Actions
-(void)drawModeChanged:(id)sender{
    // kHoughDrawModeChanged
    BOOL isDrawMode = self.drawMode.on;
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:isDrawMode] forKey:kHoughDrawModeChanged];

    [self.delegate updateConfigurationWithDictionary:dic];
}

-(void)analysisModeChanged:(id)sender{
    // kHoughAnalysisModeChanged
    BOOL isAnalysisMode = self.analysisMode.on;
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:isAnalysisMode] forKey:kHoughAnalysisModeChanged];
    
    [self.delegate updateConfigurationWithDictionary:dic];
}

-(void)thresholdChanged:(id)sender{
    // kHoughThresholdChanged
    NSUInteger thresHoldValue = (NSUInteger)self.thresholdSlider.value;
    self.nLinesLabel.text = [NSString stringWithFormat:@"%d", thresHoldValue];
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:thresHoldValue] forKey:kHoughThresholdChanged];
    
    [self.delegate updateConfigurationWithDictionary:dic];
}
@end
