//
//  HistogramView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/5/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HistogramView.h"
#import "ImageHist.h"
#import "LoadingView.h"
#import "UIColor+HoughExtensions.h"

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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        loadingView = [[LoadingView alloc] initWithFrame:CGRectZero];
        
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.5];
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
    
    // Reorder histogram to internal representation
    
    // [self setNeedsDisplay]
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
    BOOL skipComponent      = NO;
    
    CGRect totalRect        = CGRectInset(self.bounds, 10, 10);

    if (!color) {
        color = [UIColor houghGray].CGColor;
    }
    
    for (NSNumber* n in keys) {
        
        curDic = [self.histogram objectForKey:n];
        
        if (keys.count != 1) {
            switch ([n integerValue]) {
                case (NSInteger)EPixelBufferAlpha:
                    skipComponent = YES;
                    break;
                case (NSInteger)EPixelBufferRed:
                    skipComponent = NO;
                    color = [UIColor colorWithRed:1 green:0 blue:0 alpha:1/alpha].CGColor;
                    break;
                case (NSInteger)EPixelBufferGreen:
                    skipComponent = NO;
                    color = [UIColor colorWithRed:0 green:1 blue:0 alpha:1/alpha].CGColor;
                    break;
                case (NSInteger)EPixelBufferBlue:
                    skipComponent = NO;
                    color = [UIColor colorWithRed:0 green:0 blue:1 alpha:1/alpha].CGColor;
                    break;
                default:
                    break;
            }
        }
        
//        NSInteger ii = 0;
        NSArray* componentKeys  = [curDic allKeys];
        NSInteger nValues       = componentKeys.count;
        CGRect nextRect         = totalRect;
        CGFloat height          = totalRect.size.height/MIN(nValues, 1); // Seriously count on not having 0 objects in the array.
        nextRect.size           = CGSizeMake(0, totalRect.size.height/MIN(nValues, 1)); 
        
        CGContextSetFillColorWithColor(context, color);
        
        // This will actually miss 0-intensity colors, bad bad. 
        for (NSNumber* compNum in componentKeys) {
            nextRect.size.width = [(NSNumber*)[curDic objectForKey:compNum] intValue];
            nextRect.origin.y  += height;
            CGContextAddRect(context, nextRect);
            
            NSLog(@"[%d] %3d:%8d", [n intValue], [compNum intValue], [(NSNumber*)[curDic objectForKey:compNum] intValue]);
        }
    
        CGContextFillPath(context);
    }
}

@end
