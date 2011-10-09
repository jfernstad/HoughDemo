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
-(void)layoutViews;
@end

@implementation ConfigurationBaseView
@synthesize lobeView;
@synthesize backgroundView;
@synthesize isOpen;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage* lobeImage  = [UIImage imageNamed:@"lobe.png"];
        self.lobeView       = [[[UIImageView alloc] initWithImage:lobeImage] autorelease];
        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        
        self.exclusiveTouch = YES;
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.lobeView];
    
//        [self layoutViews];
    }
    return self;
}

-(void)dealloc{
    self.lobeView = nil;
    self.backgroundView = nil;
    
    [super dealloc];
}

-(void)layoutViews{
    CGRect newFrame = self.frame;
    CGRect imgRect  = self.bounds;
    CGSize lobeSize = self.lobeView.image.size;

    contentRect = CGRectZero;
    
    newFrame.size.height = lobeSize.height;
    imgRect.size = newFrame.size;
    
    lobeView.frame = CGRectCenteredInRect(imgRect, lobeSize);
    
    // Hide everything except the lobe. 
    newFrame.origin.y = newFrame.origin.y - newFrame.size.height + lobeSize.height;
    
    self.backgroundView.frame = contentRect;
    self.frame = newFrame;
    originalRect = self.frame;
}

-(void)showViewAnimated:(BOOL)useAnimation{
    CGRect maxRect = CGRectOffset(originalRect, 0, originalRect.size.height-self.lobeView.bounds.size.height);
    
    [UIView beginAnimations:@"AnimateClose" context:nil];
    self.frame = maxRect;
    [UIView commitAnimations];
    self.isOpen = YES;
}

-(void)dismissViewAnimated:(BOOL)useAnimation{
    [UIView beginAnimations:@"AnimateClose" context:nil];
    self.frame = originalRect;
    [UIView commitAnimations];
    self.isOpen = NO;
}

#pragma mark - Update position - Children should override

-(void)updatePosition:(CGPoint)startPos withPosition:(CGPoint)newPoint{
    CGFloat delta = newPoint.y - startPoint.y;
    CGPoint newPosition = self.frame.origin;
    
    newPosition.y += delta;
    newPosition.y = MAX(MIN(newPosition.y,CGRectGetMaxY(originalRect)-self.lobeView.bounds.size.height),CGRectGetMinY(originalRect));
    
    CGRect myRect = originalRect;
    myRect.origin = newPosition;
    
    self.frame = myRect;
}

#pragma mark - Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* firstTouch = [touches anyObject]; // Should probably use first object
    
    startPoint = [firstTouch locationInView:self];
    startRect  = self.frame;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* currentTouch = [touches anyObject]; // Should probably use first object

    [self updatePosition:startPoint withPosition:[currentTouch locationInView:self]];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* aTouch = [touches anyObject]; // Should probably use first object
    CGFloat frameDelta = self.frame.origin.y - originalRect.origin.y;
    CGFloat touchDelta = startPoint.y - [aTouch locationInView:self].y;

    if((int)touchDelta == 0){ // Toggle
        if (self.isOpen) {
            [self dismissViewAnimated:YES];
        }
        else{
            [self showViewAnimated:YES];
        }
    }
    else if (frameDelta >= originalRect.size.height/2.0) {
        [self showViewAnimated:YES];
        DLog(@"Showing view");
    }
    else{
        [self dismissViewAnimated:YES];
        DLog(@"Dismissing view");
    }
}
@end
