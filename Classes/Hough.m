//
//  Hough.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import "Hough.h"
#import <Accelerate/Accelerate.h>

#define Y_SCALE 2.0f

@interface Hough ()
@property (nonatomic, copy)   NSArray* pointsCopy;
@property (nonatomic, retain) NSMutableArray* curves;

-(BOOL) isPointAlreadyInArray:(CGPoint)p;
-(void) createCurvesForPoints: (NSArray*)points;
-(CGImageRef)newHoughImageFromCurves;
@end


@implementation Hough
@synthesize frame, pointsCopy, curves;

-(id)init{

	if (self == [super init]) {
		self.curves = [NSMutableArray arrayWithCapacity:0];
	}
	
	return self;
}

+(CGFloat)yScale{
	return Y_SCALE;
}

-(void)clear{
    self.pointsCopy = nil;
    [self.curves removeAllObjects];
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

// WOHO   4 times faster than createHoughSpace!
-(void)createCurvesForPoints: (NSArray*)points{
	int maxDist	  = round(sqrt(frame.size.height*frame.size.height + frame.size.width*frame.size.width)/2.0f+0.5f);
	// First try of vectorized Hough transform
	int maxVals		= frame.size.width;
	float startVal	= 0.0f;
	float thetaInc	= M_PI/frame.size.width;
	float angles [ maxVals ] __attribute__((aligned));
	
	vDSP_vramp(&startVal, &thetaInc, angles, 1, maxVals); // Create angles used in cos/sin

	
	float cosValues[ maxVals ] __attribute__((aligned));
	float sinValues[ maxVals ] __attribute__((aligned));
	float cosPart  [ maxVals ] __attribute__((aligned));
	float sinPart  [ maxVals ] __attribute__((aligned));
	float yValues  [ maxVals ] __attribute__((aligned));
	float yOffset  [ maxVals ] __attribute__((aligned));
	
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
	
	float offset = maxDist/2.0f;
	float xAmp	 = 0.0;
	float yAmp	 = 0.0;
	
	float compressedOffset = (maxDist - maxDist/Y_SCALE)/2.0f; // To see the entire wave we need to scale and offset the amplitude. 
	
	for (NSValue* val in points) {
		
		p = [val CGPointValue];

		if ([self isPointAlreadyInArray:p]) { // Extreme difference in performance
			continue;
		}

		xAmp	 = p.x - maxVals/2;
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
			p2.y = (int)(yOffset[k]/Y_SCALE + compressedOffset);
			
			[tmpArray addObject:[NSValue valueWithCGPoint:p2]];
		}

		if (points.count > self.curves.count) {
			///NSLog(@"Added curve");
			[self.curves addObject:tmpArray];
		}
		else {
			// TODO: Refactor to handle multiple touches. 
			//NSLog(@"Replaced curve");
			[self.curves replaceObjectAtIndex:self.curves.count-1 withObject:tmpArray];
		}
	}
}

-(CGImageRef)newHoughImageFromCurves{
	CGImageRef outImg = NULL; // 8 bit grayscale

	int maxDist = round(sqrt(powf(self.frame.size.height, 2) +
							 powf(self.frame.size.width,  2))/2.0f+0.5f);
	int maxVals = self.frame.size.width;
	
	unsigned char* houghSpace = (unsigned char*)malloc(maxDist * maxVals); // MaxDist x angle
	
	// Draw the curves
	int y = 0;
	CGPoint p;
	int position = 0;
	for (NSArray* curve in self.curves) {
		for (NSValue* val in curve) {
			
			p = [val CGPointValue];
			y = (int)p.y;
			
			if (y > 0 && y <= maxDist){
				position = (int)(p.x + y * maxVals);
				houghSpace[ position ]++;
			}
		}
	}
	
	CGFloat decode [] = {0.0f, 100.0f};
	CFDataRef cfImgData = CFDataCreate(NULL, houghSpace, maxDist * maxVals);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(cfImgData);
	CGColorSpaceRef csp = CGColorSpaceCreateDeviceGray();
	
	
	CGImageRef tmp = CGImageCreate(maxVals, maxDist, 8, 8, maxVals, csp, kCGImageAlphaNone, dataProvider, decode, NO, kCGRenderingIntentDefault);

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
	CGColorSpaceRelease(csp);
	free(houghSpace);
	return outImg;
}
-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points{
	//NSLog(@" - newHoughSpaceFromPoints - ");


    NSDate* start = [NSDate date];
    NSTimeInterval stop;
	[self createCurvesForPoints:points];
    stop = [start timeIntervalSinceNow];
//    NSLog(@" Time for Hough creation: %2.3fms, %d curves, (%2.3f ms/curve)",-stop*1000.0f, points.count, -stop/1000.0f*(CGFloat)points.count);

	self.pointsCopy = points;
	return [self newHoughImageFromCurves];
}

-(void)dealloc{

	self.pointsCopy = nil;
	self.curves = nil;
	
	[super dealloc];
}

@end
