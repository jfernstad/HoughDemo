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
#define MIN_INTENSITY 10

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
//-(NSUInteger)hash{
//    NSUInteger h = (NSUInteger)(self.theta * self.theta * 2048 + self.length * self.length * 1024);
////    NSLog(@"Hash: %X", h);
//    return h;
//}
@end


@interface Hough ()
@property (nonatomic, copy)   NSArray* pointsCopy;
@property (nonatomic, copy)   NSArray* tmpPointsCopy;
@property (nonatomic, retain) NSMutableArray* curves;
@property (retain) NSMutableArray* intersections;

-(BOOL) isPointAlreadyInArray:(CGPoint)p;
-(void) setupHough;
-(NSArray*) createCurvesForPoints:(NSArray*)points;
-(CGImageRef) houghImageFromCurves:(NSArray*)curves;
-(CGColorSpaceRef)createColorSpace;
@end

@implementation Hough
@synthesize size, pointsCopy, tmpPointsCopy, curves, interactionMode, yScale, intersections, operationDelegate;

-(id)init{
    
	if (self == [super init]) {
		self.curves = [NSMutableArray arrayWithCapacity:0];
        self.interactionMode = kFreeHandDots;
        isSetup = NO;
        self.yScale = Y_SCALE;
    }
	
	return self;
}

-(void)clear{
    self.pointsCopy = nil;
    [self.curves removeAllObjects];
    
	int maxDist = self.size.height;
	int maxVals = self.size.width;
    NSUInteger area = maxDist * maxVals;
	
    memset(houghSpace,   0, area);
    memset(tmpHoughSpace, 0, area);
}

-(void)makePersistent{
    // TODO: Copy houghImage to tmpHoughImage;
	int maxDist = self.size.height;
	int maxVals = self.size.width;
    NSUInteger area = maxDist * maxVals;
    
    //    memcpy(tmpHoughSpace, houghSpace, size);
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
    
    houghSpace    = (unsigned char*)malloc(area);
    tmpHoughSpace = (unsigned char*)malloc(area);
    colorSpace    = [self createColorSpace];
    
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

-(CGImageRef)houghImageFromCurves:(NSArray*)newCurves{
	CGImageRef outImg = NULL; // 8 bit grayscale
    
    NSAssert(isSetup, @"! Hough doesn't have a frame! call .frame = rect. ");
    
	int maxDist = self.size.height;
	int maxVals = self.size.width;
	
    unsigned char* pointer = tmpHoughSpace;
    
    if (self.interactionMode == kFreeHandDraw) {
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

-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points{
	NSArray* newCurves = [self createCurvesForPoints:points];
    
    CGImageRef outImage = [self houghImageFromCurves:newCurves];
    
    if (self.interactionMode == kFreeHandDots) {
        self.tmpPointsCopy = points;
        
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
        colorTable[i * 3 + 1] = 255-(i-1)*255/10;
        colorTable[i * 3 + 2] = 255-(i-1)*255/10;
        //        colorTable[i * 3 + 0] = MIN(128 + i * 10, 255);
        //        colorTable[i * 3 + 1] = MAX(128 + i, 0);
        //        colorTable[i * 3 + 2] = MAX(128 + i, 0);
    }
    
    outSpace = CGColorSpaceCreateIndexed(CGColorSpaceCreateDeviceRGB(), 255, colorTable);
    
    return outSpace;
    
}

//
// Analyze hough space threaded. 
//

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
    
    CGColorSpaceRelease(colorSpace);
    free(houghSpace);
    free(tmpHoughSpace);
    
	[super dealloc];
}
@end
