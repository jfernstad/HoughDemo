//
//  HoughPresentationView.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 3/12/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HoughOverlayProtocol
-(void)overlayLines:(NSArray*)lines;  
-(void)overlayCircles:(NSArray*)circles;
@end


@interface HoughTouchView : UIView {
	NSObject<HoughOverlayProtocol>* delegate;
}

@property (nonatomic, assign) NSObject<HoughOverlayProtocol>* delegate;

@end
