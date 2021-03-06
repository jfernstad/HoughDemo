//
//  NotificationView.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 8/30/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "NotificationView.h"
#import "UIColor+HoughExtensions.h"
#import "HoughConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface NotificationView ()
-(void)setup;
@end

@implementation NotificationView
@dynamic text;
@synthesize label;


- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)dealloc{

    [label release];
    
    [super dealloc];
}

-(void)setup{
    // Initialization code
    label                   = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font              = [UIFont systemFontOfSize:24];
    label.textColor         = [UIColor whiteColor];
    label.backgroundColor   = [UIColor clearColor];
    label.textAlignment     = UITextAlignmentCenter;
    label.lineBreakMode     = UILineBreakModeWordWrap;
    label.numberOfLines     = 0;
    
    self.layer.cornerRadius = CORNER_RADIUS;
    self.layer.borderWidth  = EDGE_WIDTH;
    self.layer.borderColor  = [UIColor houghGray].CGColor;
    self.backgroundColor    = [UIColor blackWithAlpha:0.7];

    [self addSubview:label];
}

+(void)showText:(NSString*)string inView:(UIView*)parentView{

    NotificationView* view = [[[NotificationView alloc] init] autorelease]; 
    
    view.text = string;

    CGPoint padding = {40.0,40.0};
    
    CGRect myFrame    = CGRectZero;
    CGRect labelFrame = CGRectZero;
    
    CGSize textSize = [view.text sizeWithFont:view.label.font
                            constrainedToSize:CGSizeMake(MAX(MIN(parentView.bounds.size.width/2.0, 400), 100), 800)
                                lineBreakMode:view.label.lineBreakMode];

    myFrame.size   = CGSizeMake(textSize.width  + padding.x,
                                textSize.height + padding.y);
    
    myFrame.origin = CGPointMake((parentView.bounds.size.width  - myFrame.size.width)/2, 
                                 (parentView.bounds.size.height - myFrame.size.height)/2);
    
    labelFrame.size   = textSize;
    labelFrame.origin = CGPointMake(padding.x/2, padding.y/2);

    view.frame        = myFrame;
    view.label.frame  = labelFrame;
    
    [parentView addSubview:view];

    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:0.8
                     animations:^{view.alpha = 0.0;}
                     completion:^(BOOL finished){ [view removeFromSuperview]; }];
}

-(void)setText:(NSString *)text{
    label.text = text;
}
-(NSString*)text{
    return label.text;
}

@end
