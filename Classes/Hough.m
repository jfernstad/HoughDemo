//
//  Hough.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "Hough.h"
#import "CGGeometry+HoughExtensions.h"
#import <Accelerate/Accelerate.h>
#import <CoreVideo/CoreVideo.h>
#import "PointLinkedList.h"
#import "ListLinkedList.h"

#define Y_SCALE 2.0f
#define MIN_INTENSITY 100    // TODO: Parameterize

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
@property (retain) IntersectionLinkedList* intersections;
@property (nonatomic, retain) NSOperationQueue* operationQueue;
@property (nonatomic, retain) UIImage* inputUIImage;
@property (nonatomic, assign) CGSize imgSize;

@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef houghSpace;
@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef tmpHoughSpace;
@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef inputImage; 
@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef grayScaleImage;
@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef edgeImage;
@property (nonatomic, retain) __attribute__((NSObject)) CVPixelBufferRef thinnedImage;

-(void) setupHough;
-(CGImageRef) houghImageFromPoints:(PointLinkedList*)points persistant:(BOOL)pointsArePersistent;
-(CGColorSpaceRef)createColorSpace;

-(CGImageRef)CGImageWithCVPixelBuffer:(CVPixelBufferRef)pixBuf;
-(CGImageRef)CGImageWithImage:(CGImageRef)inputImg andSize:(CGSize)newSize;
-(CVPixelBufferRef)CVPixelBufferWithCGImage:(CGImageRef)cgImg;
-(CVPixelBufferRef)newEmptyCVPixelBuffer:(CGSize)size;
@end

@implementation Hough
@synthesize size;
@synthesize imgSize;
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

@synthesize maxHoughInput;
@synthesize grayscaleThreshold;
@synthesize houghThreshold;

#ifdef DEBUG
@synthesize debugEnabled;
#endif
-(id)init{
    
	if ((self = [super init])) {
		isSetup = NO;
        self.storeAfterDraw = NO;
        self.yScale = Y_SCALE;
        operationQueue = [[NSOperationQueue alloc] init];
        
        // TODO: Find better default values
        self.maxHoughInput      = 1000;
        self.grayscaleThreshold = 128;
        self.houghThreshold     = MIN_INTENSITY;
        
#ifdef DEBUG
        self.debugEnabled = YES;
#endif
        
    }
	
	return self;
}

-(void)clear{
    [self.operationQueue cancelAllOperations];
    
	int houghSize    = CVPixelBufferGetDataSize(self.houghSpace);
	int tmpHoughSize = CVPixelBufferGetDataSize(self.tmpHoughSpace);
	
    CVPixelBufferLockBaseAddress(self.houghSpace, 0);
    CVPixelBufferLockBaseAddress(self.tmpHoughSpace, 0);
    
    unsigned char* p1 = CVPixelBufferGetBaseAddress(self.houghSpace);
    unsigned char* p2 = CVPixelBufferGetBaseAddress(self.tmpHoughSpace);
    
    memset(p1, 0, houghSize);
    memset(p2, 0, tmpHoughSize);
    
    CVPixelBufferUnlockBaseAddress(self.houghSpace, 0);
    CVPixelBufferUnlockBaseAddress(self.tmpHoughSpace, 0);
}

-(void)makePersistent{
    
	int houghSize    = CVPixelBufferGetDataSize(self.houghSpace);
    
    CVPixelBufferLockBaseAddress(self.houghSpace, 0);
    CVPixelBufferLockBaseAddress(self.tmpHoughSpace, 0);
    
    unsigned char* p1 = CVPixelBufferGetBaseAddress(self.houghSpace);
    unsigned char* p2 = CVPixelBufferGetBaseAddress(self.tmpHoughSpace);
    
    memcpy(p1, p2, houghSize);
    
    CVPixelBufferUnlockBaseAddress(self.houghSpace, 0);
    CVPixelBufferUnlockBaseAddress(self.tmpHoughSpace, 0);
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
    
    DLog(@"Setting up Hough!");
    
    if (isSetup) {
        self.houghSpace = nil;
        self.tmpHoughSpace = nil;
    }
    
    houghSpace    = [self newEmptyCVPixelBuffer:self.size];
    tmpHoughSpace = [self newEmptyCVPixelBuffer:self.size];
    
    if (!self.houghSpace || !self.tmpHoughSpace) {
        DLog(@" FAILED TO CREATE HOUGH PIXELBUFFERS !");
    }
    
    if (!colorSpace) colorSpace = [self createColorSpace];
    
    isSetup = YES;
    // TODO: verify we have memory
}

#pragma mark - Read Only Properties

-(CVPixelBufferRef)InputImage{
    return self.inputImage;
}

-(CVPixelBufferRef)HoughImage{
    return self.houghSpace;
}

-(CVPixelBufferRef)GrayScaleImage{
    return self.grayScaleImage;
}

-(CVPixelBufferRef)EdgeImage{
    return self.edgeImage;
}

-(CVPixelBufferRef)ThinnedImage{
    return self.thinnedImage;
}


#pragma mark - Hough Stuff

-(CGImageRef) houghImageFromPoints:(PointLinkedList*)points persistant:(BOOL)pointsArePersistent;{
    
    NSAssert(isSetup, @"! Hough doesn't have a frame! call .frame = rect. ");
    
    if (points.size == 0) return NULL;
    
    PointNode* node = NULL;
    
    int maxDist = self.size.height;
	int maxVals = self.size.width;
	
    CVPixelBufferLockBaseAddress(self.houghSpace, 0);
    CVPixelBufferLockBaseAddress(self.tmpHoughSpace, 0);
    
    unsigned char* pointer = CVPixelBufferGetBaseAddress(self.tmpHoughSpace);
    
    if (pointsArePersistent) {
        pointer = CVPixelBufferGetBaseAddress(self.houghSpace);
    }else{
        unsigned char* d = CVPixelBufferGetBaseAddress(self.houghSpace);
        memcpy(pointer, d, CVPixelBufferGetDataSize(self.houghSpace));
    }
    
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
    
	CGPoint p, p2;
	int k			= 0;
	
	float yOff = self.imgSize.height/2.0f;
	float xOff = self.size.width/2.0f;
	float xAmp = 0.0;
	float yAmp = 0.0;
	
	float compressedOffset = (self.size.height - self.imgSize.height/self.yScale)/2.0f; // To see the entire wave we need to scale and offset the amplitude. 
    
    int position = 0;
    
    [points resetPosition];
    while ((node = [points next])) {
		
		p = *(node->point);
        
        // Offset point to middle of hough space
		xAmp	 = xOff - p.x;
		yAmp	 = yOff - p.y;
		
		// calc cos part: (x-180)*cos
		vDSP_vsmul(cosValues, 1, &xAmp, cosPart, 1, maxVals);
		// calc sin part: (y-maxDist/2)*sin
		vDSP_vsmul(sinValues, 1, &yAmp, sinPart, 1, maxVals);
		
		vDSP_vadd(cosPart, 1, sinPart, 1, yValues, 1, maxVals);
		vDSP_vsadd(yValues,1, &yOff, yOffset, 1, maxVals);
		
		// TODO: SIMD this
		for(k = 0; k < maxVals; k++){
			p2.x = k;
			p2.y = (int)(yOffset[k]/self.yScale + compressedOffset);
			
			if (p2.y > 0 && p2.y <= maxDist){ // Store pixels
				position = (int)(p2.x + p2.y * maxVals);
				pointer[ position ]++;
			}
		}
	}
    
    // Render
    
    CGFloat decode [] = {0.0f, 255.0f}; // TODO: Change to dynamic range. Calc Max/Min per image.
    CFDataRef cfImgData = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pointer, maxDist * maxVals, kCFAllocatorNull);
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData(cfImgData);
	
    CVPixelBufferUnlockBaseAddress(self.tmpHoughSpace, 0);
    CVPixelBufferUnlockBaseAddress(self.houghSpace, 0);
    
	CGImageRef tmp = CGImageCreate(maxVals, maxDist, 8, 8, maxVals, colorSpace, kCGImageAlphaNone, dataProvider, decode, NO, kCGRenderingIntentDefault);
    
	CGColorSpaceRef scpr = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef cr = CGBitmapContextCreate(NULL, 
											maxVals,
											maxDist, 
											8, 
											4*maxVals, 
											scpr, 
											kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    
	
	// Convert to 8 bit from whatever.. 
	CGContextDrawImage(cr, CGRectMake(0, 0, maxVals, maxDist), tmp);
	
	CGImageRef outImg = CGBitmapContextCreateImage(cr);
	
	CGDataProviderRelease(dataProvider);
	CFRelease(scpr);
	CGImageRelease(tmp);
	CFRelease(cfImgData);
	CGContextRelease(cr);
    
    return outImg;
}

-(CGImageRef)newHoughSpaceFromPoints: (PointLinkedList*)points persistent:(BOOL)pointsArePersistent{
	CGImageRef outImage = [self houghImageFromPoints:points persistant:pointsArePersistent];
    
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

-(IntersectionLinkedList*)allIntersections{
    return self.intersections;
}
//
// Input format: .origin = Position in Hough Space with size .size
//

-(CGPoint)equationForPoint:(CGRect)pointInRect{
    CGPoint outp  = CGPointZero;
    CGFloat theta = 0;
    CGFloat len   = 0;
    
    // Reverse previous offset algorithm
    theta   = M_PI - pointInRect.origin.x * M_PI/pointInRect.size.width;    // Remove earlier theta offset
    //    len     = (pointInRect.size.height - (pointInRect.size.height/2 - pointInRect.origin.y)*self.yScale); // Remove earlier length offset
    len     = (pointInRect.origin.y - pointInRect.size.height/2)*self.yScale; // Remove earlier length offset
    
    outp.x  = theta;
    outp.y  = len;
    
    return outp;    
}

-(void)dealloc{
    
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
    
    if (!CGSizeEqualToSize(self.size, rawImage.size)) {
        self.size = self.inputUIImage.size;
    }
    
    NSOperation* prepareOp           = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(prepareImageOp) object:nil] autorelease];
    NSOperation* grayscaleOp         = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(grayscaleImageOp) object:nil] autorelease];
    NSOperation* edgeOp              = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(edgeImageOp) object:nil] autorelease];
    NSOperation* thinOp              = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(thinImageOp) object:nil] autorelease];
    NSOperation* createHoughSpaceOp  = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(createHoughSpaceOp) object:nil] autorelease];
    NSOperation* analyzeHoughSpaceOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(analyzeHoughSpaceOp) object:nil] autorelease];
    
    [analyzeHoughSpaceOp addDependency:createHoughSpaceOp];
    [createHoughSpaceOp addDependency:thinOp];
    [thinOp addDependency:edgeOp];
    [edgeOp addDependency:grayscaleOp];
    [grayscaleOp addDependency:prepareOp];
    
    [self.operationQueue addOperation:prepareOp];
    [self.operationQueue addOperation:grayscaleOp];
    [self.operationQueue addOperation:edgeOp];
    [self.operationQueue addOperation:thinOp];
    [self.operationQueue addOperation:createHoughSpaceOp];
    [self.operationQueue addOperation:analyzeHoughSpaceOp];
}

-(void)executeHoughSpaceOperation{
    
    [self clear];
    
    NSOperation* createHoughSpaceOp  = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(createHoughSpaceOp) object:nil] autorelease];
    NSOperation* analyzeHoughSpaceOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(analyzeHoughSpaceOp) object:nil] autorelease];
    [analyzeHoughSpaceOp addDependency:createHoughSpaceOp];
    [self.operationQueue addOperation:createHoughSpaceOp];
    [self.operationQueue addOperation:analyzeHoughSpaceOp];
}
-(void)executeAnalysisOperation{
    NSOperation* analyzeHoughSpaceOp = [[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(analyzeHoughSpaceOp) object:nil] autorelease];

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
-(void)prepareImageOp{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationPrepareImage waitUntilDone:NO];
    }

    CGSize newSize = CGSizeIntegral(CGSizeAspectFitSize(self.inputUIImage.size, [UIScreen mainScreen].bounds.size));
    CGImageRef scaledImage = [self CGImageWithImage:self.inputUIImage.CGImage andSize:newSize]; 

    DLog(@"InputSize: %@", NSStringFromCGSize(self.inputUIImage.size));
    DLog(@"NewSize: %@", NSStringFromCGSize(newSize));
    
    self.inputUIImage = [UIImage imageWithCGImage:scaledImage];
    self.size = newSize;
    
    // TEMPORARY
    CVPixelBufferRef tmpImage = [self CVPixelBufferWithCGImage:scaledImage];
    self.inputImage = tmpImage;
    CVPixelBufferRelease(tmpImage);
    // 
    
    CGImageRelease(scaledImage);
    
    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObject:kOperationPrepareImage forKey:kOperationNameKey];
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }
    
    [pool drain];
}

-(void)grayscaleImageOp{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationGrayscaleImage waitUntilDone:NO];
    }
    
    CGImageRef origImage    = self.inputUIImage.CGImage;
    CVPixelBufferRef bufRef = [self CVPixelBufferWithCGImage:origImage];
    self.grayScaleImage     = bufRef;
    
    CVPixelBufferRelease(bufRef);
    
    // Do the actual grayscale implementation
    unsigned char* pixels = NULL;
    
    CVPixelBufferLockBaseAddress(self.grayScaleImage, 0);
    pixels = CVPixelBufferGetBaseAddress(self.grayScaleImage);
    CVPixelBufferUnlockBaseAddress(self.grayScaleImage, 0);
    
    NSUInteger ii = 0;
    NSUInteger grayInt = 0;
    UInt8 grayValue = 0, A = 0, R = 0, G = 0, B = 0;
    
    for (ii = 0; ii < CVPixelBufferGetDataSize(self.grayScaleImage); ii+=4) {
        
        A = pixels[ii+0];
        R = pixels[ii+1];
        G = pixels[ii+2];
        B = pixels[ii+3];
        
        grayInt   = (76 * R + 150 * G + 29 * B)/256;
        grayValue = (UInt8)grayInt;
        
        pixels[ii+0] = A;
        pixels[ii+1] = grayValue;
        pixels[ii+2] = grayValue;
        pixels[ii+3] = grayValue;
    }
    
    // Put blur operation here instead
    // --------
    
    // Stack Blur v1.0
    //
    // Author: Mario Klingemann <mario@quasimondo.com>
    // http://incubator.quasimondo.com
    // created Feburary 29, 2004
    
    
    // This is a compromise between Gaussian Blur and Box blur
    // It creates much better looking blurs than Box Blur, but is
    // 7x faster than my Gaussian Blur implementation.
    //
    // I called it Stack Blur because this describes best how this
    // filter works internally: it creates a kind of moving stack
    // of colors whilst scanning through the image. Thereby it
    // just has to add one new block of color to the right side
    // of the stack and remove the leftmost color. The remaining
    // colors on the topmost layer of the stack are either added on
    // or reduced by one, depending on if they are on the right or
    // on the left side of the stack. 
    //
    // If you are using this algorithm in your code please add
    // the following line:
    // 
    // Stack Blur Algorithm by Mario Klingemann <mario@quasimondo.com>
    
    //    void fastblur(PImage img,int radius){
    //        
    //        if (radius<1){
    //            return;
    //        }
    
    // Pointer to pixels, 32 bit pixels
//    int[] pix = img.pixels;
//    int width = img.width;
//    int height = img.height;
    NSUInteger width  = CVPixelBufferGetWidth(self.grayScaleImage);
    NSUInteger height = CVPixelBufferGetHeight(self.grayScaleImage);
    int widthMax = width-1;
    int heightMax = height-1;
    int nPixels = width*height;
    
    int x,y,i,p,yp,yi,yw;
    int sum, insum, outsum;

    // Radius related vars
    int radius = 5; // TODO: Parametrize
    int r1     = radius+1;
    int div    = radius + radius + 1; // Total radius 2R+1
    
    // divsum = ((div+1)/2)^2 ? // Total kernel size?
    int divsum = (div + 1) >> 1;
    divsum *= divsum;

    // Planar pixel components
    // Some kind of LUT, don't really understand why this is neccessary
    //    int vmin[] = new int[max(w,h)];
    int* vmin = (int*)malloc(MAX(width,height) * sizeof(int));
    unsigned char* dv = (unsigned char*)malloc(256*divsum);    //    int dv[] = new int[256*divsum];
    unsigned char* stack = (unsigned char*)malloc(div);         //    int[][] stack = new int[div][3];
    unsigned char* intensity = (unsigned char*)malloc(nPixels);
    unsigned char* sir;
    
    // Some kind of LUT, weird integer flooring, 
    // results in divsum number of intensities per intensity
    for (i = 0; i < 256 * divsum;i++){
        dv[i] = (i/divsum);
    }
    
    yw=yi=0;
    

    int stackpointer;
    int stackstart;
    int rbs;
    int pixIdx = 0;
    
    // I'm guessing this is blurring in y-direction
    for (y = 0;y < height; y++){
        
        // Reset sums for every line
        sum = insum = outsum = 0;

        // yi = y * width; // Strange use of variable
        // Generate new sums for this line in stack
        for(i = -radius;i <= radius;i++){
            
            // Get pixel values to work with, don't go farther than line allows [0, width]
            pixIdx =  yi + MIN(widthMax, MAX(i,0));
//            DLog(@"x -> pixIdx: %d", pixIdx);
            p = pixels[pixIdx * 4 + 1]; // R-Channel
            
            // Get stack, presumably empty in the beginning
            // Actually store pixel intensities in stack
            sir = &stack[i + radius];
            sir[0] = p;
            
//            DLog(@"Stack Index: %d, %d", i + radius, i);
            
            // Multiply stack components with current position in stack?
            rbs = r1-abs(i);
            sum += sir[0] * rbs;
            
            if (i>0){
                insum += sir[0];
            } else {
                outsum += sir[0];
            }
        }
        stackpointer=radius;
        
        // Actual blur for this row
        for (x=0;x<width;x++){
        
            // Save intensity for current position
            intensity[yi] = dv[sum];

            pixIdx = yi * 4 + 1;
            pixels[pixIdx + 0] = dv[sum];
            pixels[pixIdx + 1] = dv[sum];
            pixels[pixIdx + 2] = dv[sum];
            
            // Countdown sums from outsums, still wondering about this one
            sum -= outsum;
            
            // New pointer position?
            stackstart = stackpointer - radius + div;
            sir        = &stack[ stackstart % div];      // Retrieve pixel pointer
            
            // Decrease outsums with what? Pixelintensity from stack.. ugh
            outsum  -= sir[0];
            
            // First row only, LUT for rest
            // Save ourselves from the left edge? 
            if(y == 0){
                vmin[x] = MIN(x+radius+1,widthMax);
            }
            
            // Get new pixel value
            pixIdx = yw + vmin[x];
//            DLog(@"y -> pixIdx: %d", pixIdx);
            p = pixels[pixIdx * 4 + 1];
            
            // Store pixel intensities in stack
            sir[0] = p;
            
            // Add pixel intensities to insums
            insum += sir[0];
            
            // Accumulate sums with insums
            sum += insum;
            
//            if (sum > divsum * 256) DLog(@"Sum to high: %d > %d", sum ,divsum * 256);
                
            // This is to shift the middle positions, from right part of kernel (in) to left part (out)
            stackpointer = (stackpointer + 1) % div;
            sir = &stack[ (stackpointer) % div];
            
            outsum += sir[0];
            
            insum -= sir[0];
            
            yi++;
        }
        yw+=width;
    }
    
    // I'm guessing this is blurring in y-direction
    for (x=0;x<width;x++){
        
        // Reset sums for every column
        sum = insum = outsum = 0;
        
        yp = -radius * width; // Why is this called yp?
        
        // For each part in the kernel at this x position
        for(i = -radius;i <= radius;i++){
            yi = MAX(0,yp) + x;
            
//            if (0 > yp) {
//                DLog(@"i: %d, x: %d, yi: %d, yp: %d, i+radius: %d",i , x, yi, yp, i+radius);
//            }
            // Get value from stack/kernel again, kernel is now transposed
            sir = &stack[ i + radius ];
            
            // Reset something with color intensities
            sir[0] = intensity[yi];
            
            rbs = r1 - abs(i);
            
            // Accumulate sums again
            sum += intensity[yi] * rbs;
            
            if (i>0){
                insum += sir[0];
            } else {
                outsum += sir[0];
            }
            
            if(i<heightMax){
                yp+=width;
            }
        }
        yi=x;
        stackpointer=radius;
        
        // Store pixel values back to image?
        for (y=0;y<height;y++){
//            pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
//            pixIdx = yi * 4 + 1;
            pixIdx = (y * width + x) * 4 + 1;
            pixels[pixIdx + 0] = dv[sum];
            pixels[pixIdx + 1] = dv[sum];
            pixels[pixIdx + 2] = dv[sum];
            
            sum -= outsum;
            
            stackstart = stackpointer - radius + div;
            sir = &stack[ stackstart % div ];
            
            outsum -= sir[0];
            
            if(x==0){
                vmin[y] = MIN(y+r1,heightMax) * width;
//                DLog(@"%d", vmin[y]);
                //                if ((y+r1)>heightMax) DLog(@"y + r1: %d, y: %d",y + r1 , y);
            }
            
            p = x+vmin[y];
            
            sir[0] = intensity[p];
            
            insum += sir[0];
            
            sum += insum;
            
            stackpointer = (stackpointer+1) % div;
            sir = &stack[stackpointer];
            
            outsum += sir[0];
            
            insum -= sir[0];
            
            yi+=width;
        }
    }
    free(dv);
    free(stack);
    free(vmin);
    free(intensity);
    // }
    //
    
    
    
    // --------
    
    // DEBUG
    UIImage* hImg = nil; 
#ifdef DEBUG
    CGImageRef copiedImage = nil;
    
    if (self.debugEnabled){
        copiedImage = [self CGImageWithCVPixelBuffer:self.grayScaleImage];
        hImg = [UIImage imageWithCGImage:copiedImage];
        
        CGImageRelease(copiedImage);
    }
#endif
    // DEBUG

    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:kOperationGrayscaleImage, kOperationNameKey, hImg, kOperationUIImageKey, nil];
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }
    
    [pool drain];
}
-(void)edgeImageOp{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationEdgeImage waitUntilDone:NO];
    }
    
    CGSize edgeSize = CGSizeMake(CVPixelBufferGetWidth(self.grayScaleImage),
                                 CVPixelBufferGetHeight(self.grayScaleImage));
    
    CVPixelBufferRef newBuf = [self newEmptyCVPixelBuffer:edgeSize];
    self.edgeImage = newBuf;
    CVPixelBufferRelease(newBuf);
    
    // Do the actual grayscale implementation
    unsigned char* pixelsIn  = NULL;
    unsigned char* pixelsOut = NULL;
    
    CVPixelBufferLockBaseAddress(self.edgeImage, 0);
    CVPixelBufferLockBaseAddress(self.grayScaleImage, 0);
    pixelsIn  = CVPixelBufferGetBaseAddress(self.grayScaleImage);
    pixelsOut = CVPixelBufferGetBaseAddress(self.edgeImage);
    
    NSUInteger xx = 0, yy = 0;
    NSInteger kernel[3] = {-1,0,1};
    NSUInteger w = CVPixelBufferGetWidth(self.grayScaleImage);
    NSUInteger h = CVPixelBufferGetHeight(self.grayScaleImage);
    NSUInteger ws = CVPixelBufferGetBytesPerRow(self.grayScaleImage);
    NSUInteger edge = 0; 

    CVPixelBufferRef blurBuf = [self newEmptyCVPixelBuffer:edgeSize];
    CVPixelBufferLockBaseAddress(blurBuf, 0);
    unsigned char* blur = CVPixelBufferGetBaseAddress(blurBuf);
    
    DLog(@"EdgeSize: %@", NSStringFromCGSize(edgeSize));
    DLog(@"GrayScale: {%4d,%4d,%4d}", (int)CVPixelBufferGetWidth(self.grayScaleImage), (int)CVPixelBufferGetHeight(self.grayScaleImage),  (int)CVPixelBufferGetBytesPerRow(self.grayScaleImage));
    DLog(@"EdgeImage: {%4d,%4d,%4d}", (int)CVPixelBufferGetWidth(self.edgeImage), (int)CVPixelBufferGetHeight(self.edgeImage), (int)CVPixelBufferGetBytesPerRow(self.edgeImage));
    DLog(@"BlurBuf:   {%4d,%4d,%4d}", (int)CVPixelBufferGetWidth(blurBuf), (int)CVPixelBufferGetHeight(blurBuf), (int)CVPixelBufferGetBytesPerRow(blurBuf));
    
    // BOX BLUR
    // Skip edge row, edge x-direction
//    for (yy = 1; yy < h - 1; yy++) {
//        for (xx = 1; xx < w - 1; xx++) {
//            
//            // Offset to RED channel
//            edge = (pixelsIn[(xx - 1)*4 + 1 + yy * ws] +
//                    pixelsIn[(xx + 0)*4 + 1 + yy * ws] +
//                    pixelsIn[(xx + 1)*4 + 1 + yy * ws])/3;
//            
//            // Per color-component
//            blur[xx * 4 + 0 + yy * ws] = 255;//*xx/w;
//            blur[xx * 4 + 1 + yy * ws] = edge;
//            blur[xx * 4 + 2 + yy * ws] = edge;
//            blur[xx * 4 + 3 + yy * ws] = edge;
//        }
//    }
//
//    // Skip edge row, edge y-direction, add results
//    for (yy = 1; yy < h - 1; yy++) {
//        for (xx = 1; xx < w - 1; xx++) {
//            
//            // Offset to RED channel
//            edge = (pixelsIn[(xx)*4 + 1 + (yy - 1) * ws]  +
//                    pixelsIn[(xx)*4 + 1 + (yy + 0) * ws]  +
//                    pixelsIn[(xx)*4 + 1 + (yy + 1) * ws])/3;
//            
//            // Per color-component
//            //pixels[xx * 4 + 0 + yy * ws]  = 255;
//            blur[xx * 4 + 1 + yy * ws] += edge;
//            blur[xx * 4 + 2 + yy * ws] += edge;
//            blur[xx * 4 + 3 + yy * ws] += edge;
//        }
//    }
//    
//    
//    pixelsIn = blur; // Replace pointers
    
    // EDGE
    // Skip edge row, edge x-direction
    for (yy = 1; yy < h - 1; yy++) {
        for (xx = 1; xx < w - 1; xx++) {
            
            // Offset to RED channel
            edge = pixelsIn[(xx - 1)*4 + 1 + yy * ws] * kernel[0] +
                   pixelsIn[(xx + 0)*4 + 1 + yy * ws] * kernel[1] +
                   pixelsIn[(xx + 1)*4 + 1 + yy * ws] * kernel[2];
            
            // Per color-component
            pixelsOut[xx * 4 + 0 + yy * ws] = 255;//*xx/w;
            pixelsOut[xx * 4 + 1 + yy * ws] = edge;
            pixelsOut[xx * 4 + 2 + yy * ws] = edge;
            pixelsOut[xx * 4 + 3 + yy * ws] = edge;
        }
    }
    
    // Skip edge row, edge y-direction, add results
    for (yy = 1; yy < h - 1; yy++) {
        for (xx = 1; xx < w - 1; xx++) {
            
            // Offset to RED channel
            edge =  pixelsIn[(xx)*4 + 1 + (yy - 1) * ws] * kernel[0] +
                    pixelsIn[(xx)*4 + 1 + (yy + 0) * ws] * kernel[1] +
                    pixelsIn[(xx)*4 + 1 + (yy + 1) * ws] * kernel[2];
            
            // Per color-component
            //pixels[xx * 4 + 0 + yy * ws]  = 255;
            pixelsOut[xx * 4 + 1 + yy * ws] += edge;
            pixelsOut[xx * 4 + 2 + yy * ws] += edge;
            pixelsOut[xx * 4 + 3 + yy * ws] += edge;
        }
    }
    
    // DEBUG
    UIImage* hImg = nil; 
#ifdef DEBUG
    CGImageRef copiedImage = nil;
    
    if (self.debugEnabled){
        copiedImage = [self CGImageWithCVPixelBuffer:self.edgeImage];
        hImg = [UIImage imageWithCGImage:copiedImage];
        
        CGImageRelease(copiedImage);
    }
#endif
    
    CVPixelBufferUnlockBaseAddress(blurBuf, 0);
    CVPixelBufferRelease(blurBuf);

    CVPixelBufferUnlockBaseAddress(self.edgeImage, 0);
    CVPixelBufferUnlockBaseAddress(self.grayScaleImage, 0);

    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:kOperationEdgeImage, kOperationNameKey, hImg, kOperationUIImageKey, nil];
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }
    
    [pool drain];
}
-(void)thinImageOp{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationThinImage waitUntilDone:NO];
    }
    
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
    PointLinkedList* list   = [[PointLinkedList alloc] init];

    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationCreateHoughSpaceImage waitUntilDone:NO];
    }
    
    CVPixelBufferLockBaseAddress(self.edgeImage, 0); // Is this neccessary?
    unsigned char *pixels = CVPixelBufferGetBaseAddress(self.edgeImage);
    CVPixelBufferUnlockBaseAddress(self.edgeImage, 0);
    
    NSUInteger xx = 0, yy = 0;
    NSUInteger w  = CVPixelBufferGetWidth(self.edgeImage);
    NSUInteger h  = CVPixelBufferGetHeight(self.edgeImage);
    NSUInteger ws = CVPixelBufferGetBytesPerRow(self.edgeImage);
    UInt8 intensity = 0;
    NSUInteger counter = 0;
    
	// Get Positions from pixels in edge image
    for( yy = 0; yy < h; yy++){
        if (counter > self.maxHoughInput) { 
            break;
        }
        for( xx = 0; xx < w; xx++){
            
            intensity = pixels[xx*4 + 1 + yy * ws];
            
            if( intensity > self.grayscaleThreshold ){ // Threshold, Parametrize
                [list addPoint:CGPointMake(xx, yy)];
                
                if (++counter > self.maxHoughInput) {
                    DLog(@"Hit limit @ (%d,%d) %d pixels examined. ", xx,yy,xx*yy*w);
                    break;
                }
            }
        }
    }
    
    DLog(@"Got %d points. ", list.size);
    
    CGImageRef  tImg = [self newHoughSpaceFromPoints:list persistent:YES]; 
    [list release];
    
    UIImage* hImg = nil; 
#ifdef DEBUG
    CGImageRef copiedImage = nil;
    
    if (self.debugEnabled){
        hImg = nil;//[UIImage imageWithCGImage:tImg];      
        CGImageRelease(copiedImage);
    }
#endif
    
    CGImageRelease(tImg);
    
    if (self.operationDelegate) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:kOperationCreateHoughSpaceImage, kOperationNameKey, hImg, kOperationUIImageKey, nil];
        
        [self.operationDelegate performSelectorOnMainThread:@selector(houghDidFinishOperationWithDictionary:) withObject:dic waitUntilDone:NO];
    }

    [pool drain];
}
-(void)analyzeHoughSpaceOp{
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
	int imgHeight = (int)self.size.height;
	int imgWidth  = (int)self.size.width;
    
    if (self.operationDelegate) {
        [self.operationDelegate performSelectorOnMainThread:@selector(houghWillBeginOperation:) withObject:kOperationAnalyzeHoughSpace waitUntilDone:NO];
    }
    
    self.intersections = [[[IntersectionLinkedList alloc] init] autorelease];
    
	int maxPoint = 0;
	int x = 0, y = 0;
    NSUInteger idx = 0;
    NSUInteger intensity = 0;
    CGPoint equation = CGPointZero;
	CGRect pointRect = CGRectZero;
    pointRect.size   = self.size;
    
    CVPixelBufferLockBaseAddress(self.houghSpace, 0);
    unsigned char *rasterData = CVPixelBufferGetBaseAddress(self.houghSpace);
    
	// Get Positions from Maxima in Houghspace
    maxPoint = 0;
    for( y = 0; y < imgHeight; y++){
        for( x = 0; x < imgWidth; x++){
            
            idx = x + y*imgWidth;
            intensity = rasterData[idx];
            if( intensity > self.houghThreshold ){
                pointRect.origin.x = x;
                pointRect.origin.y = y;
                
                equation = [self equationForPoint:pointRect];
                maxPoint = intensity;
                
                [self.intersections addIntersection:
                 [HoughIntersection houghIntersectionWithTheta:equation.x 
                                                        length:equation.y 
                                                  andIntensity:maxPoint]];
            }
        }
    }
    
    CVPixelBufferUnlockBaseAddress(self.houghSpace, 0);
	
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
    
	outImg = CGImageCreate(w, h, 8, 8*bpr/w, bpr, scpr, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big, dataProvider, NULL, NO, kCGRenderingIntentDefault);
	
	CGDataProviderRelease(dataProvider);
	CGColorSpaceRelease(scpr);
	CFRelease(cfImgData);
    
    return outImg;
}
- (CGImageRef)CGImageWithImage:(CGImageRef)inputImg andSize:(CGSize)newSize {
    
    CGColorSpaceRef csp = CGImageGetColorSpace(inputImg);
    CGContextRef context = CGBitmapContextCreate(NULL, newSize.width, newSize.height,
                                                 CGImageGetBitsPerComponent(inputImg),
                                                 newSize.width * 4,
                                                 csp,
                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, newSize.width, newSize.height), inputImg);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);

    CGContextRelease(context);
    
    return imgRef;
}

-(CVPixelBufferRef)CVPixelBufferWithCGImage:(CGImageRef)cgImg{
    
    if (!cgImg) {
        return NULL;
    }
    
    CVPixelBufferRef outBuf = NULL;
    CVReturn ret = kCVReturnError;
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                         [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    
    CGDataProviderRef dataProvider  = NULL;
    CFDataRef imageData             = NULL;
    unsigned int *pixels            = NULL;
    
    
    // TODO: Covert pixel from whatever format into ARGB, 32bitBigEndian
    // TODO: Check if it already has the correct pixelformat. 
    
    // -- BEGIN CONVERSION --
    
    CGColorSpaceRef csp = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, 
                                             CGImageGetWidth(cgImg), 
                                             CGImageGetHeight(cgImg),
                                             8,
                                             CGImageGetWidth(cgImg) * 4,
                                             csp,
                                             kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, CGImageGetWidth(cgImg), CGImageGetHeight(cgImg)), cgImg);
    
    CGImageRef convertedImg = CGBitmapContextCreateImage(ctx);
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(csp);
    //    CFRelease(imageData);
    //    CGDataProviderRelease(dataProvider);
    
    // -- END CONVERSION --
    
    
    dataProvider = CGImageGetDataProvider(convertedImg);
    imageData    = CGDataProviderCopyData(dataProvider);
    pixels       = (void*)CFDataGetBytePtr(imageData);
    
    ret = CVPixelBufferCreateWithBytes(NULL, 
                                       CGImageGetWidth(convertedImg), 
                                       CGImageGetHeight(convertedImg),
                                       kCVPixelFormatType_32ARGB, // FIXME: What if I need a 8-bit luminance channel only?
                                       pixels,
                                       CGImageGetBytesPerRow(convertedImg),
                                       NULL,NULL,
                                       (CFDictionaryRef)dic,
                                       &outBuf);
    
    CGImageRelease(convertedImg); // Should I?
    
    if (ret != kCVReturnSuccess) {
        DLog(@"CVPixelBufferWithCGImage: FAILED TO CREATE PIXELBUFFER FROM CGIMAGE!");
        outBuf = NULL;
    }
    
    return outBuf;
}

-(CVPixelBufferRef)newEmptyCVPixelBuffer:(CGSize)bufSize{
    CVPixelBufferRef newBuffer = NULL;
    
    CVReturn ret = kCVReturnError;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                         [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    
    ret = CVPixelBufferCreate(NULL, 
                              bufSize.width,
                              bufSize.height, 
                              kCVPixelFormatType_32ARGB,
                              (CFDictionaryRef)dic,
                              &newBuffer);
    
    if (ret != kCVReturnSuccess) {
        DLog(@"newEmptyCVPixelBuffer: FAILED TO CREATE NEW PIXELBUFFER !");
        newBuffer = NULL;
    }
    
    return newBuffer;
}

@end
