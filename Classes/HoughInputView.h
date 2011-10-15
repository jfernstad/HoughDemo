//
//  HoughInputView.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoughTouchView.h"

#define kHoughInputGestureState @"GestureState"

@class HoughLineOverlayDelegate;
@class Hough;
@class PointLinkedList;

@protocol HoughInputProtocol
-(void)updateInputWithPoints:(PointLinkedList*)pointArray;
@end


@interface HoughInputView : UIView {
	PointLinkedList* points;
	UIColor* pointsColor;
    
	UITapGestureRecognizer* tap;
	UIPanGestureRecognizer* pan;

	NSValue* currentPoint;

	NSObject<HoughInputProtocol>* delegate;
    Hough* houghRef;

    BOOL persistentTouch;
}

@property (nonatomic, retain) PointLinkedList* points; // Array of CGPoints
@property (nonatomic, retain) NSValue* currentPoint; 
@property (nonatomic, assign) NSObject<HoughInputProtocol>* delegate;
@property (nonatomic, retain) UIColor* pointsColor;
@property (nonatomic, assign) Hough* houghRef;
@property (nonatomic, assign) BOOL persistentTouch;

- (void)clear;

@end
