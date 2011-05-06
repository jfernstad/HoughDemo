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
}
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) EInteractionMode interactionMode;

+(CGFloat)yScale;
-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points; // Completely redraw houghImage
-(void)clear;
-(void)makePersistent;  // Stores tmpHoughImage to houghImage;

@end
