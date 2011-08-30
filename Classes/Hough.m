//
//  Hough.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "Hough.h"
#import <Accelerate/Accelerate.h>
#import <CoreVideo/CoreVideo.h>

#define Y_SCALE 2.0f
#define MIN_INTENSITY 10    // TODO: Parameterize

// TMP
#define SLEEPTIME 0.1

@implementation HoughIntersection
@synthesize theta;
@synthesize length;
@synthesize intensity;


-(id)init{
    if ((self = [super init])) {
    }
    return self;
}
+(id)houghIntersectionWithTheta:(CGFloat)t length:(CGFloat)l andIntensity:(NSUInteger)i{
    HoughIntersection* intersection = [[[HoughIntersection alloc] init] autorelease];
    intersection.theta = t;
    intersection.length = l;
    intersection.intensity = i;
    
    return intersection;
}
-(NSString*)description{
    return [NSString stringWithFormat:@"HoughIntersection: theta: %3.2f, length: %3.2f, intensity: %d", self.theta, self.length, self.intensity];
}

@end

@interface Hough ()
@property (nonatomic, copy)   NSArray* pointsCopy;
@property (nonatomic, copy)   NSArray* tmpPointsCopy;
@property (retain) NSMutableArray* curves;
@property (retain) NSMutableArray* intersections;
@property (nonatomic, retain) NSOperationQueue* operationQueue;
@property (nonatomic, retain) UIImage* inputUIImage;
@property (nonatomic, assign) CGSize imgSize;

@property (nonatomic, retain) __attribute__((NSObject)) CVImageBufferRef houghSpace;
@property (nonatomic, retain) __attribute__((NSObject)) CVImageBufferRef tmpHoughSpace;
@property (nonatomic, retain) __attribute__((NSObject)) CVImageBufferRef inputImage; 
@property (nonatomic, retain) __attribute__((NSObject)) CVImageBufferRef grayScaleImage;
@property (nonatomic, retain) __attribute__((NSObject)) CVImageBufferRef edgeImage;
@property (nonatomic, retain) __attribute__((NSObject)) CVImageBufferRef thinnedImage;

-(BOOL) isPointAlreadyInArray:(CGPoint)p;
-(void) setupHough;
-(NSArray*) createCurvesForPoints:(NSArray*)points;
-(CGImageRef) houghImageFromCurves:(NSArray*)curves persistant:(BOOL)pointsArePersistent;
-(CGColorSpaceRef)createColorSpace;

-(CGImageRef)CGImageWithCVPixelBuffer:(CVPixelBufferRef)pixBuf;
-(CVPixelBufferRef)CVPixelBufferWithCGImage:(CGImageRef)cgImg;
-(CVPixelBufferRef)newEmptyCVPixelBuffer:(CGSize)size;
@end

@implementation Hough
@synthesize size;
@synthesize imgSize;
@synthesize pointsCopy;
@synthesize tmpPointsCopy;
@synthesize curves;
@synthesize yScale;
@synthesize intersections;
@synthesize operationDelegate;
@synthesize storeAfterDraw;
@synthesize operationQueue;
@synthesize inputUIImage;

@synthesize houghSpace;
@synthesize tmpHoughSpace;
@synthesize inputImage;
@synthesize grayScaleImage;
@synthesize edgeImage;
@synthesize thinnedImage;

-(id)init{
    
	if ((self = [super init])) {
		isSetup = NO;
        self.storeAfterDraw = NO;
        self.yScale = Y_SCALE;
        operationQueue = [[NSOperationQueue alloc] init];
    }
	
	return self;
}

-(void)clear{
    self.pointsCopy = nil;
    [self.operationQueue cancelAllOperations];
    
	int houghSize    = CVPixelBufferGetDataSize(houghSpace);
	int tmpHoughSize = CVPixelBufferGetDataSize(tmpHoughSpace);
	
    CVPixelBufferLockBaseAddress(houghSpace, 0);
    CVPixelBufferLockBaseAddress(tmpHoughSpace, 0);

    unsigned char* p1 = CVPixelBufferGetBaseAddress(houghSpace);
    unsigned char* p2 = CVPixelBufferGetBaseAddress(tmpHoughSpace);
    
    memset(p1, 0, houghSize);
    memset(p2, 0, tmpHoughSize);

    CVPixelBufferUnlockBaseAddress(houghSpace, 0);
    CVPixelBufferUnlockBaseAddress(tmpHoughSpace, 0);
}

-(void)makePersistent{

	int maxDist = self.size.height;
	int maxVals = self.size.width;
    NSUInteger area = maxDist * maxVals;
    
    CVPixelBufferLockBaseAddress(houghSpace, 0);
    CVPixelBufferLockBaseAddress(tmpHoughSpace, 0);
    
    unsigned char* p1 = CVPixelBufferGetBaseAddress(houghSpace);
    unsigned char* p2 = CVPixelBufferGetBaseAddress(tmpHoughSpace);
    
    memcpy(p1, p2, area);
    
    CVPixelBufferUnlockBaseAddress(houghSpace, 0);
    CVPixelBufferUnlockBaseAddress(tmpHoughSpace, 0);
}
-(BOOL) isPointAlreadyInArray:(CGPoint) p{
	
	BOOL ret = NO;
	CGPoint tp;
	
	for (NSValue *v in self.pointsCopy) {
		[v getValue:&tp];
		
		if (CGPointEqualToPoint(tp, p)) {
			ret = YES;
			break;
		}
	}
	
	return ret;
}

-(void)setSize:(CGSize)rectSize{
    int maxDist = round(sqrt(powf(rectSize.height, 2) +
							 powf(rectSize.width,  2))/self.yScale+0.5f);
    int maxVals = rectSize.width;
    
    imgSize = rectSize;
    size = CGSizeMake(maxVals, maxDist);
    
    
    [self setupHough];
}

-(void)setupHough{
    
    NSLog(@"Setting up Hough!");
    
    if (isSetup) {
        self.houghSpace = nil;
        self.tmpHoughSpace = nil;
    }
    
    houghSpace    = [self newEmptyCVPixelBuffer:self.size];
    tmpHoughSpace = [self newEmptyCVPixelBuffer:self.size];
    
    if (!self.houghSpace || !self.tmpHoughSpace) {
        NSLog(@" FAILED TO CREATE HOUGH PIXELBUFFERS !");
    }

    if (!colorSpace) colorSpace = [self createColorSpace];
    
    isSetup = YES;
    // TODO: verify we have memory
}

// WOHO   4 times faster than createHoughSpace!
-(NSArray*)createCurvesForPoints: (NSArray*)points{
    
    NSAssert(isSetup, @"! Hough doesn't have a frame! call .frame = rect. ");
    
    int maxVals = self.size.width;
    
	float startVal	= 0.0f;
	float thetaInc	= M_PI/self.size.width;
	float angles   [ maxVals ] __attribute__((aligned));
	float cosValues[ maxVals ] __attribute__((aligned));
	float sinValues[ maxVals ] __attribute__((aligned));
	float cosPart  [ maxVals ] __attribute__((aligned));
	float sinPart  [ maxVals ] __attribute__((aligned));
	float yValues  [ maxVals ] __attribute__((aligned));
	float yOffset  [ maxVals ] __attribute__((aligned));
	
	vDSP_vramp(&startVal, &thetaInc, angles, 1, maxVals); // Create angles used in cos/sin
    
#ifdef __i386__
	vvcosf(cosValues, angles, &maxVals);
	vvsinf(sinValues, angles, &maxVals);
#else
	// Store these somewhere
	for (int i = 0; i < maxVals; i++) {
		cosValues[i] = cos(angles[i]);
		sinValues[i] = sin(angles[i]);
	}
#endif
    
	NSMutableArray* tmpArray = nil;
	CGPoint p, p2;
	int k			= 0;
	
	float offset = self.size.height/2.0f;
	float xAmp	 = 0.0;
	float yAmp	 = 0.0;
	
	float compressedOffset = (self.size.height - self.size.height/self.yScale)/2.0f; // To see the entire wave we need to scale and offset the amplitude. 
	
    NSMutableArray* outArray = [NSMutableArray arrayWithCapacity:points.count];
    
	for (NSValue* val in points) {
		
		p = [val CGPointValue];
        
		xAmp	 = p.x - self.imgSize.width/2; // TODO: Doh, this should be input image half width
		yAmp	 = p.y - offset;
		
		// calc cos part: (x-180)*cos
		vDSP_vsmul(cosValues, 1, &xAmp, cosPart, 1, maxVals);
		// calc sin part: (y-maxDist/2)*sin
		vDSP_vsmul(sinValues, 1, &yAmp, sinPart, 1, maxVals);
		
		vDSP_vadd(cosPart, 1, sinPart, 1, yValues, 1, maxVals);
		vDSP_vsadd(yValues,1, &offset, yOffset, 1, maxVals);
		
		tmpArray = [NSMutableArray arrayWithCapacity:maxVals];
		
		// TODO: SIMD this
		for(k = 0; k < maxVals; k++){
			p2.x = k;
			p2.y = (int)(yOffset[k]/self.yScale + compressedOffset);
			
			[tmpArray addObject:[NSValue valueWithCGPoint:p2]];
		}
        
        [outArray addObject:tmpArray];
	}
    
    return outArray;
}

-(CGImageRef)houghImageFromCurves:(NSArray*)newCurves persistant:(BOOL)pointsArePersistent{
	CGImageRef outImg = NULL; // 8 bit grayscale
    
    NSAssert(isSetup, @"! Hough doesn't have a frame! call .frame = rect. ");
    
	int maxDist = self.size.height;
	int maxVals = self.size.width;
	
    CVPixelBufferLockBaseAddress(houghSpace, 0);
    CVPixelBufferLockBaseAddress(tmpHoughSpace, 0);

    unsigned char* pointer = CVPixelBufferGetBaseAddress(tmpHoughSpace);

//    CVPixelBufferLockBaseAddress(buffer, 0);
    
    if (pointsArePersistent) {
        pointer = CVPixelBufferGetBaseAddress(houghSpace);
    }else{
        unsigned char* d = CVPixelBufferGetBaseAddress(houghSpace);
        memcpy(pointer, d, maxDist * maxVals);
    }
	
	// Draw the curves
	int y = 0;
	CGPoint p;
	int position = 0;
	for (NSArray* curve in newCurves) {
		for (NSValue* val in curve) {
			
			p = [val CGPointValue];
			y = (int)p.y;
			
			if (y > 0 && y <= maxDist){
				position = (int)(p.x + y * maxVals);
				pointer[ position ]++;
			}
		}
	}
	
	CGFloat decode [] = {0.0f, 255.0f}; // TODO: Change to dynamic range. Calc Max/Min per image.
    CFDataRef cfImgData = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pointer, maxDist * maxVals, kCFAllocatorNull);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(cfImgData);
	
    CVPixelBufferUnlockBaseAddress(tmpHoughSpace, 0);
    CVPixelBufferUnlockBaseAddress(houghSpace, 0);

	CGImageRef tmp = CGImageCreate(maxVals, maxDist, 8, 8, maxVals, colorSpace, kCGImageAlphaNone, dataProvider, decode, NO, kCGRenderingIntentDefault);
    
	CGColorSpaceRef scpr = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef cr = CGBitmapContextCreate(NULL, 
											maxVals,
											maxDist, 
											8, 
											4*maxVals, 
											scpr, 
											kCGImageAlphaPremultipliedFirst);
    
	
	// Convert to 8 bit from whatever.. 
	CGContextDrawImage(cr, CGRectMake(0, 0, maxVals, maxDist), tmp);
	
	outImg = CGBitmapContextCreateImage(cr);
	
	CGDataProviderRelease(dataProvider);
	CFRelease(scpr);
	CGImageRelease(tmp);
	CFRelease(cfImgData);
	CGContextRelease(cr);
	return outImg;
}

-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points persistant:(BOOL)pointsArePersistent{
	NSArray* newCurves = [self createCurvesForPoints:points];
    
    CGImageRef outImage = [self houghImageFromCurves:newCurves persistant:pointsArePersistent];
    
    if (self.storeAfterDraw && !pointsArePersistent) {
        [self makePersistent];
        self.storeAfterDraw = NO;
    }
    
	return outImage;
}

-(CGColorSpaceRef)createColorSpace{
    
    CGColorSpaceRef outSpace = NULL;
    
    NSUInteger i = 0;
    
    unsigned char colorTable[256*3];
    
    // 0 = black
    colorTable[0] = 0;
    colorTable[1] = 0;
    colorTable[2] = 0;
    
    for (i = 1; i < 255; i++) {
        colorTable[i * 3 + 0] = 255;
        colorTable[i * 3 + 1] = MAX(0,255-(i-1)*255/15);
        colorTable[i * 3 + 2] = MAX(0,255-(i-1)*255/15);
        //        colorTable[i * 3 + 0] = MIN(128 + i * 10, 255);
        //        colorTable[i * 3 + 1] = MAX(128 + i, 0);
        //        colorTable[i * 3 + 2] = MAX(128 + i, 0);
    }
    
    outSpace = CGColorSpaceCreateIndexed(CGColorSpaceCreateDeviceRGB(), 255, colorTable);
    
    return outSpace;
    
}

-(NSArray*)allIntersections{
    return self.intersections;
}
//
// Input format: .origin = Position in Hough Space with size .size
//

-(CGPoint)equationForPoint:(CGRect)pointInRect{
    CGPoint outp  = CGPointZero;
    CGFloat theta = 0;
    CGFloat len   = 0;
    
    theta   = M_PI - pointInRect.origin.x * M_PI/pointInRect.size.width;
    len     = (pointInRect.size.height - pointInRect.origin.y*self.yScale); // * Y_SCALE = 2
    
    outp.x  = theta;
    outp.y  = len;
    
    return outp;    
}
-(void)dealloc{
    
	self.pointsCopy = nil;
	self.intersections = nil;
    self.operationDelegate = nil;
    self.inputUIImage = nil;
    
    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;
    
    CGColorSpaceRelease(colorSpace);

    self.houghSpace     = nil;
    self.tmpHoughSpace  = nil;
    
    self.inputImage     = nil;
    self.grayScaleImage = nil;
    self.edgeImage      = nil;
    self.thinnedImage   = nil;
    
	[super dealloc];
}


#pragma mark -
#pragma mark Operations dispatcher

-(void)executeOperationsWithImage:(UIImage*)rawImage{

//    if (!rawImage) {
//    }

    [self clear];
    
    self.inputUIImage = rawImage;
    self.size = self.inputUIImage.size; // TODO: Should I really do this?

    // Use pixeldata in CGImage as input to vImage_ functions
    
//    CGImageRef imgRef = self.inputUIImage.CGImage;

    
    
    NSOperation* grayscaleOp         = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(grayscaleImageOp) object:nil] autorelease];
    NSOperation* edgeOp              = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(edgeImageOp) object:nil] autorelease];
    NSOperation* thinOp              = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(thinImageOp) object:nil] autorelease];
    NSOperation* createHoughSpaceOp  = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(createHoughSpaceOp) object:nil] autorelease];
    NSOperation* analyzeHoughSpaceOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(analyzeHoughSpaceOp) object:nil] autorelease];

    [analyzeHoughSpaceOp addDependency:createHoughSpaceOp];
    [createHoughSpaceOp addDependency:thinOp];
    [thinOp addDependency:edgeOp];
    [edgeOp addDependency:grayscaleOp];
    
    [self.operationQueue addOperation:grayscaleOp];
    [self.operationQueue addOperation:edgeOp];
    [self.operationQueue addOperation:thinOp];
    [self.operationQueue addOperation:createHoughSpaceOp];
    [self.operationQueue addOperation:analyzeHoughSpaceOp];
}

-(void)cancelOperations{
    [self.operationQueue cancelAllOperations];
}
#pragma mark -
#pragma mark Operations

//
// Analyze hough space threaded. 
//
-(void)grayscaleImageOp{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationGrayscaleImage waitUntilDone:NO];
    }

//    NSLog(@"grayscaleImage: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");

    // Do operation
    // Temporary
    [NSThread sleepForTimeInterval:SLEEPTIME];
    
    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObject:kOperationGrayscaleImage forKey:kOperationNameKey];
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }

    // Temporary
    [NSThread sleepForTimeInterval:SLEEPTIME];

    [pool drain];
}
-(void)edgeImageOp{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationEdgeImage waitUntilDone:NO];
    }
    
//    NSLog(@"edgeImage: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");

    // Do operation
    // Temporary
    [NSThread sleepForTimeInterval:SLEEPTIME];
    
    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObject:kOperationEdgeImage forKey:kOperationNameKey];
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }
    
    // Temporary
    [NSThread sleepForTimeInterval:SLEEPTIME];
    [pool drain];
}
-(void)thinImageOp{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationThinImage waitUntilDone:NO];
    }
    
//    NSLog(@"thinImage: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");

    // Do operation
    // Temporary
    [NSThread sleepForTimeInterval:SLEEPTIME];

    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObject:kOperationThinImage forKey:kOperationNameKey];
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }
    
    // Temporary
    [NSThread sleepForTimeInterval:SLEEPTIME];

    [pool drain];
}
-(void)createHoughSpaceOp{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationCreateHoughSpaceImage waitUntilDone:NO];
    }
    
//    NSLog(@"createHoughSpace: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");

    // Do operation
    // Temporary
    [NSThread sleepForTimeInterval:SLEEPTIME];
    
    NSMutableArray* points = [NSMutableArray arrayWithCapacity:40];
    
    CGSize origSize = self.inputUIImage.size;
    
    CGFloat x = 0, y = 0;
    NSUInteger ii = 0;

    // Line 1
    for (ii = 0; ii < 40; ii++) {
        x = origSize.width/2 + ii * origSize.width/100;//imgSize.width/2 - (CGFloat)(ii*10);
        y = origSize.height/2;// - size.height/5;

//        x = 0 + ii*10;
//        y = 500;
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        NSLog(@"P: %@", NSStringFromCGPoint(CGPointMake(x, y)));
    }
    
    // Line 2
//    for (ii = 0; ii < 40; ii++) {
//        x = imgSize.width/20 * ii + imgSize.height/6;
//        y = imgSize.width/2;
//        
//        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
//    }
//
//    // Line 3
//    for (ii = 0; ii < 40; ii++) {
//        y = 1 * ii + imgSize.height/8;
//        x = ii;
//        
//        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
//    }
//
//    // Line 4
//    for (ii = 0; ii < 40; ii++) {
//        y = imgSize.height/20 * ii + imgSize.height/6;
//        x = imgSize.width/2;
//        
//        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
//    }

    
    CGImageRef  tImg = [self newHoughSpaceFromPoints:points persistant:YES]; 
    CGImageRef imgTest = [self CGImageWithCVPixelBuffer:self.houghSpace];
    
    UIImage* hImg = [UIImage imageWithCGImage:tImg]; 
//    UIImage* hImg = [UIImage imageWithCGImage:imgTest];
    
    CGImageRelease(tImg);
    CGImageRelease(imgTest);
    
    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:kOperationCreateHoughSpaceImage, kOperationNameKey, hImg, kOperationUIImageKey, nil];
        
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }
    // Temporary
    [NSThread sleepForTimeInterval:SLEEPTIME];
    
    [pool drain];
}
-(void)analyzeHoughSpaceOp{
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    //    NSLog(@"analyzeHoughSpace: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");
    
	int imgHeight = (int)self.size.height;
	int imgWidth  = (int)self.size.width;
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationAnalyzeHoughSpace waitUntilDone:NO];
    }
    
    self.intersections = [[[NSMutableArray alloc] init] autorelease];
    
	int maxPoint = 0;
	int x = 0, y = 0;
    NSUInteger idx = 0;
    NSUInteger intensity = 0;
//	CGPoint maxPos   = CGPointZero;
    CGPoint equation = CGPointZero;
	CGRect pointRect = CGRectZero;
    pointRect.size   = self.size;
    
    CVPixelBufferLockBaseAddress(houghSpace, 0); // Is this neccessary?
    unsigned char *rasterData = CVPixelBufferGetBaseAddress(houghSpace);
    
	// Get Positions from Maxima in Houghspace
    //	for( n = 0; n < imgHeight * imgWidth; n++){
    maxPoint = 0;
    for( y = 0; y < imgHeight; y++){
        for( x = 0; x < imgWidth; x++){
            
            idx = x + y*imgWidth;
            intensity = rasterData[idx];
            if( intensity > MIN_INTENSITY ){
                pointRect.origin.x = x;
                pointRect.origin.y = y;
                
                equation = [self equationForPoint:pointRect];
                maxPoint = intensity;
                
                [self.intersections addObject:
                 [HoughIntersection houghIntersectionWithTheta:equation.x 
                                                        length:equation.y 
                                                  andIntensity:maxPoint]];
            }
        }
    }
    //	}
    
    CVPixelBufferUnlockBaseAddress(houghSpace, 0);
	
    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:kOperationAnalyzeHoughSpace, kOperationNameKey, self.intersections, kHoughIntersectionArrayKey, nil];
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }
    
    [pool drain];
}

#pragma mark Internal -
-(CGImageRef)CGImageWithCVPixelBuffer:(CVPixelBufferRef)pixBuf{
    CGImageRef outImg = NULL;
    
    if (!pixBuf) {
        return NULL;
    }
    
    NSInteger w   = CVPixelBufferGetWidth(pixBuf);
    NSInteger h   = CVPixelBufferGetHeight(pixBuf);
    NSInteger bpr = CVPixelBufferGetBytesPerRow(pixBuf);
    NSInteger s   = CVPixelBufferGetDataSize(pixBuf);
    
    CVPixelBufferLockBaseAddress(pixBuf, 0);
    
    unsigned char* pointer = CVPixelBufferGetBaseAddress(pixBuf);

    CFDataRef cfImgData = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pointer, s, kCFAllocatorNull);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(cfImgData);
	CGColorSpaceRef scpr = CGColorSpaceCreateDeviceRGB();
	
    CVPixelBufferUnlockBaseAddress(pixBuf, 0);
    
	outImg = CGImageCreate(w, h, 8, 8*bpr/w, bpr, scpr, kCGImageAlphaPremultipliedFirst, dataProvider, NULL, NO, kCGRenderingIntentDefault);
	
	CGDataProviderRelease(dataProvider);
	CGColorSpaceRelease(scpr);
	CFRelease(cfImgData);
    
    return outImg;
}
-(CVPixelBufferRef)CVPixelBufferWithCGImage:(CGImageRef)cgImg{
    CVPixelBufferRef outBuf = NULL;
    

    return outBuf;
}

-(CVPixelBufferRef)newEmptyCVPixelBuffer:(CGSize)size{
    CVPixelBufferRef newBuffer = NULL;
    
    CVReturn ret = kCVReturnError;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                         [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    
    ret = CVPixelBufferCreate(NULL, 
                              self.size.width,
                              self.size.height, 
                              kCVPixelFormatType_32ARGB,
                              (CFDictionaryRef)dic,
                              &newBuffer);

    if (ret != kCVReturnSuccess) {
        NSLog(@"newEmptyCVPixelBuffer: FAILED TO CREATE NEW PIXELBUFFER !");
        newBuffer = NULL;
    }

    return newBuffer;
}

@end
