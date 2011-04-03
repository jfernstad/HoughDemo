//
//  HoughInputView.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HoughTouchView.h"

@class HoughLineOverlayDelegate;

@protocol HoughInputProtocol
-(void)updateInputWithPoints:(NSArray*)pointArray;
@end


@interface HoughInputView : UIView {
	NSMutableArray* points;
	
	UITapGestureRecognizer* tap;
	UIPanGestureRecognizer* pan;

	NSValue* currentPoint;

	NSObject<HoughInputProtocol>* delegate;
}

@property (nonatomic, retain) NSMutableArray* points; // Array of CGPoints
@property (nonatomic, retain) NSValue* currentPoint; 
@property (nonatomic, assign) NSObject<HoughInputProtocol>* delegate;

- (void)clear;
@end
