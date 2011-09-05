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
@synthesize hideComponents;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        loadingView = [[LoadingView alloc] initWithFrame:CGRectZero];
        
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
        self.hideComponents  = EPixelBufferAlpha;
        
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
                              onComponent:EPixelBufferAll
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
	CGContextRef context    = UIGraphicsGetCurrentContext();
    CGColorRef color        = self.histogramColor.CGColor;
    NSArray* keys           = [self.histogram allKeys];
    CGFloat alpha           = MIN(MAX(1,keys.count),3);

    CGRect totalRect        = CGRectInset(self.bounds, 10, 10);

    CGRect loadingRect = CGRectCenteredInRect(totalRect, CGSizeMake(30, 30));
    self.loadingView.frame = loadingRect;
    
    EPixelBufferComponent component = EPixelBufferNone;
    
    for (NSNumber* n in keys) {
        
        component = (EPixelBufferComponent)[n intValue];
        
        // Hide this component;
        if ((1 << component) & self.hideComponents) {
            continue;
        }
        
        curDic = [self.histogram objectForKey:n];
        
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
        
//        NSInteger ii = 0;
        NSArray* componentKeys  = [curDic allKeys];
        NSInteger nValues       = componentKeys.count;
        CGRect nextRect         = totalRect;
        CGFloat height          = totalRect.size.height/255.0;
        nextRect.size           = CGSizeMake(0, height); 
        
        CGContextSetFillColorWithColor(context, color);
        
        for (NSNumber* compNum in componentKeys) {
            nextRect.size.width = [(NSNumber*)[curDic objectForKey:compNum] intValue]/100;
            nextRect.origin.y   = totalRect.origin.y + (255 - [compNum intValue]) * height;
            CGContextAddRect(context, nextRect);
        }
    
        CGContextFillPath(context);
    }
}

@end
