//
//  TouchOverlayDelegaate.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/2/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CircleOverlayDelegate : NSObject {
    NSArray* points; // Array with NSValues containing CGPoints
    UIColor* markColor;
    CGFloat radius;
}

@property (nonatomic, retain) NSArray* points;
@property (nonatomic, retain) UIColor* markColor;
@property (nonatomic, assign) CGFloat radius;

@end
