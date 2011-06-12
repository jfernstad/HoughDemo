//
//  Hough.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

// Dictionary keys
#define kOperationNameKey           @"OperationName"
#define kHoughIntersectionArrayKey  @"HoughIntersectionArray"

// Operation names
#define kOperationAnalyzeHoughSpace @"AnalyzeHoughSpace"

typedef enum{
    kFreeHandDots = 0,
    kFreeHandDraw,
    kManualInteraction,
    
    kNumInteractionModes
} EInteractionMode;

@protocol HoughOperationDelegate

-(void)houghWillBeginOperation:(NSString*)operation;
-(void)houghDidFinishOperationWithDictionary:(NSDictionary*)dict; // Operation in kOperationNameKey

@end

@interface HoughIntersection : NSObject {

    CGFloat    theta;
    CGFloat    length;
    NSUInteger intensity;
}

@property (nonatomic, assign) CGFloat theta;
@property (nonatomic, assign) CGFloat length;
@property (nonatomic, assign) NSUInteger intensity;

@end

@interface Hough : NSObject {
	CGSize size;
	
	NSArray* pointsCopy;
	NSArray* tmpPointsCopy;
	NSMutableArray* curves;
    NSMutableArray* intersections; // HoughIntersection objects
    
    EInteractionMode interactionMode;
    
    unsigned char* houghSpace;
    unsigned char* tmpHoughSpace;

    BOOL isSetup;
    
    CGColorSpaceRef colorSpace;
    CGFloat yScale;
    
    NSObject<HoughOperationDelegate>* operationDelegate;
}
@property (nonatomic, assign) CGFloat yScale;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) EInteractionMode interactionMode;
@property (nonatomic, assign) NSObject<HoughOperationDelegate>* operationDelegate;

-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points; // Completely redraw houghImage
-(void)clear;
-(void)makePersistent;  // Stores tmpHoughImage to houghImage;
-(CGPoint)equationForPoint:(CGRect)pointInRect;
-(void)analyzeHoughSpace;
-(NSArray*)allIntersections;
@end
