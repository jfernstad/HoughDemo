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

// Operations
#define kOperationGrayscaleImage        @"OperationGrayscaleImage"
#define kOperationEdgeImage             @"OperationEdgeImage"
#define kOperationThinImage             @"OperationThinImage"
#define kOperationCreateHoughSpaceImage @"OperationCreateHoughSpace"
#define kOperationAnalyzeHoughSpace     @"OperationAnalyzeHoughSpace"

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

+(id)houghIntersectionWithTheta:(CGFloat)t length:(CGFloat)l andIntensity:(NSUInteger)i;

@end

@interface Hough : NSObject {
	CGSize size;
	
    // Result arrays
	NSArray* pointsCopy;
	NSArray* tmpPointsCopy;
	NSMutableArray* curves;
    NSMutableArray* intersections; // HoughIntersection objects
    
    // Hough buffers
    unsigned char* houghSpace;
    unsigned char* tmpHoughSpace;

    // Interaction flags
    BOOL isSetup;
    BOOL storeAfterDraw;
    BOOL operationAborted;
    
    // Visualization params
    CGColorSpaceRef colorSpace;
    CGFloat yScale;

    // Related to operations
    NSOperationQueue* operationQueue;
    NSObject<HoughOperationDelegate>* operationDelegate;

    // Interrim images
    UIImage* grayScaleImage;
    UIImage* edgeImage;
    UIImage* thinnedImage;
}
@property (nonatomic, assign) CGFloat yScale;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL storeAfterDraw;
@property (nonatomic, assign) NSObject<HoughOperationDelegate>* operationDelegate;

-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points persistant:(BOOL)pointsArePersistent; // Completely redraw houghImage
-(void)clear;
-(void)makePersistent;  // Stores tmpHoughImage to houghImage;
-(CGPoint)equationForPoint:(CGRect)pointInRect;
-(NSArray*)allIntersections;

// Operations
-(void)executeOperationsWithImage:(UIImage*)rawImage;
-(void)cancelOperations;
@end
