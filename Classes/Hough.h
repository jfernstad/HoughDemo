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
#define kOperationUIImageKey        @"ResultingUIImage"
#define kHoughIntersectionArrayKey  @"HoughIntersectionArray"

// Operations
#define kOperationPrepareImage          @"OperationPrepareImage"
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
    CGSize imgSize;
	
    // Result arrays
    NSMutableArray* intersections; // HoughIntersection objects
    
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
    CVImageBufferRef houghSpace;
    CVImageBufferRef tmpHoughSpace;
    
    // Interrim images
    UIImage* inputUIImage;
    CVImageBufferRef inputImage; 
    CVImageBufferRef grayScaleImage;
    CVImageBufferRef edgeImage;
    CVImageBufferRef thinnedImage;
}
@property (nonatomic, assign) CGFloat yScale;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL storeAfterDraw;
@property (nonatomic, assign) NSObject<HoughOperationDelegate>* operationDelegate;

@property (nonatomic, readonly) CVImageBufferRef InputImage;
@property (nonatomic, readonly) CVImageBufferRef HoughImage;
@property (nonatomic, readonly) CVImageBufferRef GrayScaleImage;
@property (nonatomic, readonly) CVImageBufferRef EdgeImage;
@property (nonatomic, readonly) CVImageBufferRef ThinnedImage;


// Manual Interaction methods
-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points persistent:(BOOL)pointsArePersistent; // Completely redraw houghImage. TODO: Remove?
//-(void)createHoughWithWithPoints:(NSArray*)points persistent:(BOOL)pointsArePersistent;
//-(CGImageRef)renderHough;


// Useful methods?
-(void)clear;
-(void)makePersistent;  // Stores tmpHoughImage to houghImage;
-(CGPoint)equationForPoint:(CGRect)pointInRect;
-(NSArray*)allIntersections;

// Operations
-(void)executeOperationsWithImage:(UIImage*)rawImage;
-(void)cancelOperations;
@end
