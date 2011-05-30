//
//  Hough.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    kFreeHandDots = 0,
    kFreeHandDraw,
    kManualInteraction,
    
    kNumInteractionModes
} EInteractionMode;

@interface Hough : NSObject {
	CGSize size;
	
	NSArray* pointsCopy;
	NSArray* tmpPointsCopy;
	NSMutableArray* curves;
    
    EInteractionMode interactionMode;
    
    unsigned char* houghSpace;
    unsigned char* tmpHoughSpace;

    BOOL isSetup;
    
    CGColorSpaceRef colorSpace;
    CGFloat yScale;
}
@property (nonatomic, assign) CGFloat yScale;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) EInteractionMode interactionMode;

-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points; // Completely redraw houghImage
-(void)clear;
-(void)makePersistent;  // Stores tmpHoughImage to houghImage;
-(CGPoint)equationForPoint:(CGRect)pointInRect;

@end
