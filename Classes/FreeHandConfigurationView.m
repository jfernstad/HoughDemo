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
@property (nonatomic, retain) UISwitch* drawMode;
@property (nonatomic, retain) UISwitch* analysisMode;

// Actions
-(void)analysisModeChanged:(id)sender;
-(void)drawModeChanged:(id)sender;


@end

@implementation FreeHandConfigurationView
@synthesize drawMode;
@synthesize analysisMode;
@synthesize drawLabel;
@synthesize analysisLabel;

-(id)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    if (self) {
        self.drawMode     = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
        self.analysisMode = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
        [self.drawMode     addTarget:self action:@selector(drawModeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self.analysisMode addTarget:self action:@selector(analysisModeChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        self.drawMode.exclusiveTouch = YES;
        self.analysisMode.exclusiveTouch = YES;
        
        self.drawLabel     = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.analysisLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        
        self.drawLabel.text = @"Draw mode";
        self.analysisLabel.text = @"Auto analysis mode";
        
        [self addSubview:self.drawLabel];
        [self addSubview:self.analysisLabel];
        
        [self addSubview:self.drawMode];
        [self addSubview:self.analysisMode];

        [self layoutViews];
    }
    return self;
}

-(void)dealloc{

    self.drawLabel     = nil;
    self.analysisLabel = nil;
    self.drawMode      = nil;
    self.analysisMode  = nil;
    
    [super dealloc];
}

-(void)layoutViews{
    CGRect newFrame        = self.frame;
    CGRect imgRect         = self.bounds;
    CGRect drawSection     = CGRectZero;
    CGRect analysisSection = CGRectZero;
    
    CGSize lobeSize = self.lobeView.image.size;
    
    contentRect = self.bounds;

    CGRectDivide(contentRect, &drawSection, &analysisSection, contentRect.size.width/2, CGRectMinXEdge);
    
    drawSection      = CGRectInset(drawSection, 10, 10);
    analysisSection  = CGRectInset(analysisSection, 10, 10);

    [self.drawLabel sizeToFit];
    [self.analysisLabel sizeToFit];

    CGRect drawLabelRect     = self.drawLabel.bounds;
    CGRect analysisLabelRect = self.analysisLabel.bounds;
    
    drawLabelRect.origin     = drawSection.origin;
    analysisLabelRect.origin = analysisSection.origin;
    
    self.drawLabel.frame = drawLabelRect;
    self.analysisLabel.frame = analysisLabelRect;
    
    drawSection.size     = CGSizeMake(50, 20);
    analysisSection.size = CGSizeMake(50, 20);
    
    drawSection.origin.x     = CGRectGetMaxX(drawLabelRect);
    analysisSection.origin.x = CGRectGetMaxX(analysisLabelRect);
    
    self.drawMode.frame     = drawSection;
    self.analysisMode.frame = analysisSection;

//    self.drawMode.frame     = CGRectCenteredInRect(drawSection,drawSection.size);
//    self.analysisMode.frame = CGRectCenteredInRect(analysisSection, analysisSection.size);

    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
    
    
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
@end
