//
//  ConfigurationsBaseView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/11/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ConfigurationBaseView.h"
#import "HoughConstants.h"
#import "CGGeometry+HoughExtensions.h"

@interface ConfigurationBaseView ()
@property (nonatomic, retain) UIImageView* lobeView;
-(void)layoutViews;
@end

@implementation ConfigurationBaseView
@synthesize lobeView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage* lobeImage = [UIImage imageNamed:@"lobe.png"];
        self.lobeView      = [[[UIImageView alloc] initWithImage:lobeImage] autorelease];

        [self addSubview:self.lobeView];
    
        [self layoutViews];
    }
    return self;
}

-(void)dealloc{
    self.lobeView = nil;
    [super dealloc];
}

-(void)layoutViews{
    CGRect newFrame = self.frame;
    CGRect imgRect  = self.bounds;
    CGSize lobeSize = self.lobeView.image.size;
    
    newFrame.size.height = lobeSize.height;
    imgRect.size = newFrame.size;
    
    lobeView.frame = CGRectCenteredInRect(imgRect, lobeSize);
    
    // Hide everything except the lobe. 
    newFrame.origin.y = self.frame.origin.y - newFrame.size.height + lobeSize.height;
    
    self.frame = newFrame;
    originalRect = self.frame;
}

-(void)showViewAnimated:(BOOL)useAnimation{
    CGRect maxRect = CGRectOffset(originalRect, 0, originalRect.size.height);
    
    [UIView beginAnimations:@"AnimateClose" context:nil];
    self.frame = maxRect;
    [UIView commitAnimations];
}

-(void)dismissViewAnimated:(BOOL)useAnimation{
    [UIView beginAnimations:@"AnimateClose" context:nil];
    self.frame = originalRect;
    [UIView commitAnimations];
}

#pragma mark - Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* firstTouch = [touches anyObject]; // Should probably use first object
    
    startPoint = [firstTouch locationInView:self];
    startRect  = self.frame;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* currentTouch = [touches anyObject]; // Should probably use first object
    CGFloat delta = [currentTouch locationInView:self].y - startPoint.y;
    CGPoint newPosition = self.frame.origin;
    
    newPosition.y += delta;
    newPosition.y = MAX(MIN(newPosition.y,CGRectGetMaxY(originalRect)),CGRectGetMinY(originalRect));
    
    CGRect myRect = originalRect;
    myRect.origin = newPosition;
    
    self.frame = myRect;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGFloat delta = self.frame.origin.y - originalRect.origin.y;

    if (delta >= originalRect.size.height/2.0) {
        [self showViewAnimated:YES];
        NSLog(@"Showing view");
    }
    else{
        [self dismissViewAnimated:YES];
        NSLog(@"Dismissing view");
    }
}
@end
