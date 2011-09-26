//
//  FreehandConfigurationView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/11/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "FreeHandConfigurationView.h"
#import "CGGeometry+HoughExtensions.h"
#import "HoughConstants.h"

@interface FreeHandConfigurationView()
-(void)layoutViews;
@property (nonatomic, retain) UILabel* drawLabel;
@property (nonatomic, retain) UILabel* analysisLabel;
@property (nonatomic, retain) UILabel* thresholdLabel;
@property (nonatomic, retain) UISwitch* drawMode;
@property (nonatomic, retain) UISwitch* analysisMode;
@property (nonatomic, retain) UISlider* thresholdSlider;

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
@synthesize analysisLabel;
@synthesize thresholdLabel;

-(id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
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
        self.analysisLabel  = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.thresholdLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        
        self.drawLabel.text      = @"Draw mode";
        self.analysisLabel.text  = @"Auto analysis mode";
        self.thresholdLabel.text = @"Threshold for line";
        
        self.thresholdSlider.maximumValue = 100;
        self.thresholdSlider.minimumValue = 0;
        
        [self addSubview:self.drawLabel];
        [self addSubview:self.analysisLabel];
        [self addSubview:self.thresholdLabel];
        
        [self addSubview:self.drawMode];
        [self addSubview:self.analysisMode];
        [self addSubview:self.thresholdSlider];

        [self layoutViews];
    }
    return self;
}

-(void)dealloc{

    self.drawLabel       = nil;
    self.analysisLabel   = nil;
    self.thresholdLabel  = nil;
    self.drawMode        = nil;
    self.analysisMode    = nil;
    self.thresholdSlider = nil;
    
    [super dealloc];
}

-(void)layoutViews{
    CGRect newFrame        = self.frame;
    CGRect imgRect         = self.bounds;
    CGRect drawSection     = CGRectZero;
    CGRect analysisSection = CGRectZero;
    CGRect sliderSection   = CGRectZero;
    
    CGSize lobeSize = self.lobeView.image.size;
    
    contentRect = self.bounds;

    CGRectDivide(contentRect, &drawSection, &sliderSection, contentRect.size.height/2, CGRectMinYEdge);
    CGRectDivide(drawSection, &drawSection, &analysisSection, contentRect.size.width/2, CGRectMinXEdge);
    
    drawSection      = CGRectInset(drawSection, 10, 10);
    analysisSection  = CGRectInset(analysisSection, 10, 10);
    sliderSection    = CGRectInset(sliderSection, 10, 10);
    
    [self.drawLabel sizeToFit];
    [self.analysisLabel sizeToFit];
    [self.thresholdLabel sizeToFit];

    CGRect drawLabelRect     = self.drawLabel.bounds;
    CGRect analysisLabelRect = self.analysisLabel.bounds;
    CGRect thresholdLabelRect = self.thresholdLabel.bounds;
    
    drawLabelRect.origin      = drawSection.origin;
    analysisLabelRect.origin  = analysisSection.origin;
    thresholdLabelRect.origin = sliderSection.origin;

    self.drawLabel.frame = drawLabelRect;
    self.analysisLabel.frame = analysisLabelRect;
    self.thresholdLabel.frame = thresholdLabelRect;
    
    drawSection.size     = CGSizeMake(50, 20);
    analysisSection.size = CGSizeMake(50, 20);
    
    drawSection.origin.x     = CGRectGetMaxX(drawLabelRect);
    analysisSection.origin.x = CGRectGetMaxX(analysisLabelRect);
    
    self.drawMode.frame        = drawSection;
    self.analysisMode.frame    = analysisSection;

//    self.drawMode.frame     = CGRectCenteredInRect(drawSection,drawSection.size);
//    self.analysisMode.frame = CGRectCenteredInRect(analysisSection, analysisSection.size);

    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
    
    CGRect sliderRect = CGRectZero;
    CGRect sliderLabelRect = CGRectZero;
    
    CGRectDivide(sliderSection, &sliderLabelRect, &sliderRect, thresholdLabel.bounds.size.width + 5, CGRectMinXEdge);
    
    self.thresholdSlider.frame = sliderRect;
    
    // Stuff to do with Lobe
    newFrame.size.height = self.bounds.size.height + lobeSize.height;

    imgRect.origin = CGPointMake(CGRectGetMinX(contentRect), CGRectGetMaxY(contentRect));
    imgRect.size = CGSizeMake(contentRect.size.width, lobeSize.height);
    
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
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:thresHoldValue] forKey:kHoughThresholdChanged];
    
    [self.delegate updateConfigurationWithDictionary:dic];
}
@end
