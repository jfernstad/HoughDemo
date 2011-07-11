//
//  Hough.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "Hough.h"
#import <Accelerate/Accelerate.h>

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

-(BOOL) isPointAlreadyInArray:(CGPoint)p;
-(void) setupHough;
-(NSArray*) createCurvesForPoints:(NSArray*)points;
-(CGImageRef) houghImageFromCurves:(NSArray*)curves persistant:(BOOL)pointsArePersistent;
-(CGColorSpaceRef)createColorSpace;
@end

@implementation Hough
@synthesize size;
@synthesize pointsCopy;
@synthesize tmpPointsCopy;
@synthesize curves;
@synthesize yScale;
@synthesize intersections;
@synthesize operationDelegate;
@synthesize storeAfterDraw;
@synthesize operationQueue;

-(id)init{
    
	if ((self = [super init])) {
		self.curves = [NSMutableArray arrayWithCapacity:0];
        isSetup = NO;
        self.storeAfterDraw = NO;
        self.yScale = Y_SCALE;
        operationQueue = [[NSOperationQueue alloc] init];
    }
	
	return self;
}

-(void)clear{
    self.pointsCopy = nil;
    [self.curves removeAllObjects];
    [self.operationQueue cancelAllOperations];
    
	int maxDist = self.size.height;
	int maxVals = self.size.width;
    NSUInteger area = maxDist * maxVals;
	
    memset(houghSpace,   0, area);
    memset(tmpHoughSpace, 0, area);
}

-(void)makePersistent{

	int maxDist = self.size.height;
	int maxVals = self.size.width;
    NSUInteger area = maxDist * maxVals;
    
    memcpy(houghSpace, tmpHoughSpace, area);
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
    
    size = CGSizeMake(maxVals, maxDist);
    
    
    [self setupHough];
}

-(void)setupHough{
    
    NSLog(@"Setting up Hough!");
    
    NSUInteger area = self.size.width * self.size.height;
    
    if (isSetup) {
        free(houghSpace);
        free(tmpHoughSpace);
    }
    
    houghSpace    = (unsigned char*)malloc(area);
    tmpHoughSpace = (unsigned char*)malloc(area);
    
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
        
		xAmp	 = p.x - self.size.width/2;
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
	
    unsigned char* pointer = tmpHoughSpace;
    
    if (pointsArePersistent) {
        pointer = houghSpace;
    }else{
        memcpy(tmpHoughSpace, houghSpace, maxDist * maxVals);
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
	CFDataRef cfImgData = CFDataCreate(NULL, pointer, maxDist * maxVals);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(cfImgData);
	
    //CGColorSpaceRef csp = CGColorSpaceCreateDeviceGray();
    //CGColorSpaceRef csp = [self createColorSpace];
	
	
	CGImageRef tmp = CGImageCreate(maxVals, maxDist, 8, 8, maxVals, colorSpace, kCGImageAlphaNone, dataProvider, decode, NO, kCGRenderingIntentDefault);
    
	CGColorSpaceRef scpr = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef cr = CGBitmapContextCreate(NULL, 
											maxVals,
											maxDist, 
											8, 
											4*maxVals, 
											scpr, 
											kCGImageAlphaPremultipliedLast);
    
	
	// Convert to 8 bit from whatever.. 
	CGContextDrawImage(cr, CGRectMake(0, 0, maxVals, maxDist), tmp);
	
	outImg = CGBitmapContextCreateImage(cr);
	
	CGDataProviderRelease(dataProvider);
	CFRelease(scpr);
	CGImageRelease(tmp);
	CFRelease(cfImgData);
	CGContextRelease(cr);
	//CGColorSpaceRelease(csp);
	//free(houghSpace);
	return outImg;
}

-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points persistant:(BOOL)pointsArePersistent{
	NSArray* newCurves = [self createCurvesForPoints:points];
    
    CGImageRef outImage = [self houghImageFromCurves:newCurves persistant:pointsArePersistent];
    
    if (self.storeAfterDraw && !pointsArePersistent) {
        [self makePersistent];
        self.storeAfterDraw = NO;
    }
    
    if (!pointsArePersistent) {
        self.tmpPointsCopy = points; // Wtf? Why are these here?
        
    }else{
        
        // Ugh.. Redo this.
        NSMutableArray* totalPoints = [NSMutableArray arrayWithArray:self.pointsCopy];
        [totalPoints addObjectsFromArray:points];
        self.pointsCopy = totalPoints;
    }
    
    [self.curves addObjectsFromArray:newCurves];
    
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
    
	self.curves = nil;
	self.pointsCopy = nil;
	self.intersections = nil;
    self.operationDelegate = nil;
    
    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;
    
    CGColorSpaceRelease(colorSpace);
    free(houghSpace);
    free(tmpHoughSpace);
    
	[super dealloc];
}


#pragma mark -
#pragma mark Operations dispatcher

-(void)executeOperationsWithImage:(UIImage*)rawImage{

    NSOperation* grayscaleOp         = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(grayscaleImage) object:nil] autorelease];
    NSOperation* edgeOp              = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(edgeImage) object:nil] autorelease];
    NSOperation* thinOp              = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(thinImage) object:nil] autorelease];
    NSOperation* createHoughSpaceOp  = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(createHoughSpace) object:nil] autorelease];
    NSOperation* analyzeHoughSpaceOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(analyzeHoughSpace) object:nil] autorelease];

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
-(void)grayscaleImage{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationGrayscaleImage waitUntilDone:NO];
    }

    NSLog(@"grayscaleImage: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");

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
-(void)edgeImage{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationEdgeImage waitUntilDone:NO];
    }
    
    NSLog(@"edgeImage: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");

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
-(void)thinImage{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationThinImage waitUntilDone:NO];
    }
    
    NSLog(@"thinImage: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");

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
-(void)createHoughSpace{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationCreateHoughSpaceImage waitUntilDone:NO];
    }
    
    NSLog(@"createHoughSpace: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");

    // Do operation
    // Temporary
    [NSThread sleepForTimeInterval:SLEEPTIME];
    
    NSMutableArray* points = [NSMutableArray arrayWithCapacity:40];
    
    CGFloat x = 0, y = 0;
    NSUInteger ii = 0;

    // Line 1
    for (ii = 0; ii < 40; ii++) {
        x = 12 * ii + 40;
        y = 140;
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    // Line 2
    for (ii = 0; ii < 40; ii++) {
        x = 12 * ii + 340;
        y = 340;
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }

    // Line 3
    for (ii = 0; ii < 40; ii++) {
        y = 12 * ii + 40;
        x = 140;
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }

    // Line 4
    for (ii = 0; ii < 40; ii++) {
        y = 12 * ii + 340;
        x = 340;
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }

    CGImageRelease([self newHoughSpaceFromPoints:points persistant:YES]); 
        
    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObject:kOperationCreateHoughSpaceImage forKey:kOperationNameKey];
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }
    // Temporary
    [NSThread sleepForTimeInterval:SLEEPTIME];
    
    [pool drain];
}
-(void)analyzeHoughSpace{
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    //    NSLog(@"analyzeHoughSpace: IsMainThread? %@", [[NSThread currentThread] isMainThread]?@"Yes":@"NO");
    
	int imgHeight = (int)self.size.height;
	int imgWidth  = (int)self.size.width;
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationAnalyzeHoughSpace waitUntilDone:NO];
    }
    
    self.intersections = [[[NSMutableArray alloc] init] autorelease];
    
	int maxPoint = 0;
	int n = 0, x = 0, y = 0;
    NSUInteger idx = 0;
    NSUInteger intensity = 0;
	CGPoint maxPos   = CGPointZero;
    CGPoint equation = CGPointZero;
	CGRect pointRect = CGRectZero;
    pointRect.size   = self.size;
    
	// Get Positions from Maxima in Houghspace
    //	for( n = 0; n < imgHeight * imgWidth; n++){
    maxPoint = 0;
    for( y = 0; y < imgHeight; y++){
        for( x = 0; x < imgWidth; x++){
            
            idx = x + y*imgWidth;
            intensity = houghSpace[idx];
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
	
    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObject:kOperationAnalyzeHoughSpace forKey:kOperationNameKey];
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }
    
    [pool drain];
}


@end
