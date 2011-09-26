//
//  ConfigurationsBaseView.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/11/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ConfigurationProtocol <NSObject>
-(void)updateConfigurationWithDictionary:(NSDictionary*)changedValues;
@end

@interface ConfigurationBaseView : UIView {
    CGRect contentRect;
    CGRect originalRect;
    CGPoint startPoint;
    CGRect  startRect;
}
@property (nonatomic, retain) UIImageView* lobeView;
@property (nonatomic, retain) UIView* backgroundView;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) id<ConfigurationProtocol>delegate;

-(void)showViewAnimated:(BOOL)useAnimation;
-(void)dismissViewAnimated:(BOOL)useAnimation;
-(void)updatePosition:(CGPoint)startPos withPosition:(CGPoint)newPoint;
@end
