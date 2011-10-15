//
//  Hough.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoughConstants.h"
#import "IntersectionLinkedList.h"

// Dictionary keys
#define kOperationNameKey           @"OperationName"
#define kOperationUIImageKey        @"ResultingUIImage"
#define kHoughIntersectionArrayKey  @"HoughIntersectionArray"

// Operations
#define kOperationPrepareImage          @"OperationPrepareImage"
#define kOperationGrayscaleImage        @"OperationGrayscaleImage"
#define kOperationEdgeImage             @"OperationEdgeImage"
#define kOperationThinImage             @"OperationThinImage"
#define kOperationCreateHoughSpaceImage @"OperationCreateHoughSpace"
#define kOperationAnalyzeHoughSpace     @"OperationAnalyzeHoughSpace"

@class PointLinkedList;

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
    CGSize imgSize;
	
    // Result arrays
//    NSMutableArray* intersections; // HoughIntersection objects
    IntersectionLinkedList* intersections; // HoughIntersection objects
    
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

    // Hough buffers
    CVPixelBufferRef houghSpace;
    CVPixelBufferRef tmpHoughSpace;
    
    // Interrim images
    UIImage* inputUIImage;
    CVPixelBufferRef inputImage; 
    CVPixelBufferRef grayScaleImage;
    CVPixelBufferRef edgeImage;
    CVPixelBufferRef thinnedImage;
    
    //Configuration
    NSUInteger maxHoughInput;
    NSUInteger grayscaleThreshold;
    NSUInteger houghThreshold;
}
@property (nonatomic, assign) CGFloat yScale;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL storeAfterDraw;
@property (nonatomic, assign) NSObject<HoughOperationDelegate>* operationDelegate;

@property (nonatomic, readonly) CVPixelBufferRef InputImage;
@property (nonatomic, readonly) CVPixelBufferRef HoughImage;
@property (nonatomic, readonly) CVPixelBufferRef GrayScaleImage;
@property (nonatomic, readonly) CVPixelBufferRef EdgeImage;
@property (nonatomic, readonly) CVPixelBufferRef ThinnedImage;

@property (nonatomic, assign) NSUInteger maxHoughInput;
@property (nonatomic, assign) NSUInteger grayscaleThreshold;
@property (nonatomic, assign) NSUInteger houghThreshold;
#ifdef DEBUG
@property (nonatomic, assign) BOOL debugEnabled;
#endif


// Manual Interaction methods
-(CGImageRef)newHoughSpaceFromPoints: (PointLinkedList*)points persistent:(BOOL)pointsArePersistent;

// Useful methods?
-(void)clear;
-(void)makePersistent;  // Stores tmpHoughImage to houghImage;
-(CGPoint)equationForPoint:(CGRect)pointInRect;
-(IntersectionLinkedList*)allIntersections;

// Operations
-(void)executeOperationsWithImage:(UIImage*)rawImage;
-(void)executeHoughSpaceOperation;
-(void)executeAnalysisOperation;
-(void)cancelOperations;
@end
