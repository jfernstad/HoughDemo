//
//  LoadingView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 5/22/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "LoadingView.h"
#import "CGGeometry+HoughExtensions.h"

@implementation LoadingView
@dynamic text;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        progress     = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
        loadingLabel.font = [UIFont fontWithName:@"helvetica" size:24.0];
        loadingLabel.textColor       = [UIColor whiteColor];
        loadingLabel.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        
        [self addSubview:loadingLabel];
        [self addSubview:progress];
     
        self.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews{

    CGRect screen        = self.bounds;
    CGRect indicatorRect = CGRectZero;
    CGRect textRect      = CGRectZero;

    CGSize textSize = [loadingLabel.text sizeWithFont:loadingLabel.font];
    
    CGSize progressSize = CGSizeMake(textSize.height, textSize.height); // Make square
    
    textRect = CGRectCenteredInRect(screen, textSize);

    indicatorRect.origin = CGPointMake(textRect.origin.x - progressSize.width - 7, textRect.origin.y); // Padding
    indicatorRect.size = progressSize;
    
    loadingLabel.frame = textRect;
    progress.frame     = indicatorRect;
}

- (void)dealloc
{
    [loadingLabel release];
    [progress release];
    
    [super dealloc];
}

#pragma mark -
#pragma Methods

- (void)startProgress{

    [progress startAnimating];

    self.hidden = NO;
    [self.superview bringSubviewToFront:self];
    
    [UIView beginAnimations:@"ShowView" context:nil];
    self.alpha         = 1.0;
    loadingLabel.alpha = 1.0;
    progress.alpha     = 1.0;
    [UIView commitAnimations];
    
}
- (void)stopProgress{
    [UIView beginAnimations:@"HideView" context:nil];
    self.alpha         = 0.0;
    loadingLabel.alpha = 0.0;
    progress.alpha     = 0.0;
    [UIView commitAnimations];

    [progress stopAnimating];
}

- (void) setText:(NSString *)text{
    loadingLabel.text = text;
    [self setNeedsLayout];
}

- (NSString*) text{
    return loadingLabel.text;
}

@end
