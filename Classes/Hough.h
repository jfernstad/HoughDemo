//
//  Hough.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    kFreeHandDots = 0,
    kFreeHandDraw,
    
    kNumInteractionModes
} EInteractionMode;

@interface Hough : NSObject {
	CGRect frame;
	
	NSArray* pointsCopy;
	NSArray* tmpPointsCopy;
	NSMutableArray* curves;
    
    EInteractionMode interactionMode;
    
    unsigned char* houghSpace;
    unsigned char* tmpHoughSpace;

    BOOL isSetup;
}
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) EInteractionMode interactionMode;

+(CGFloat)yScale;
-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points; // Completely redraw houghImage
-(void)clear;
-(void)makePersistent;  // Stores tmpHoughImage to houghImage;

@end
