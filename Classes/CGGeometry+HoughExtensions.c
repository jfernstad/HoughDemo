//
//  CGGeometry+HoughExtensions.c
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/2/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#include "CGGeometry+HoughExtensions.h"
#include "math.h"

#define MAX(A,B)	((A) > (B) ? (A) : (B))

// 
// CGRECT
// 

CGRect CGRectWithCenter(CGPoint p, CGFloat radius){
	return CGRectMake(p.x-radius, p.y-radius, 2*radius+1, 2*radius+1);
}

CGRect CGRectCenteredInRect(CGRect referenceRect, CGSize sizeToCenter){
    CGRect outRect = CGRectZero;
    
    outRect.origin = CGPointMake(referenceRect.origin.x + (referenceRect.size.width  - sizeToCenter.width)/2, 
                                 referenceRect.origin.y + (referenceRect.size.height - sizeToCenter.height)/2);
    outRect.size = sizeToCenter;
    
    return outRect;
}

// 
// CGSIZE
// 

CGSize CGSizeIntegral(CGSize inputSize){
    CGSize integralSize = CGSizeZero;
    
    integralSize.width  = floorf(inputSize.width  + 0.5);
    integralSize.height = floorf(inputSize.height + 0.5);
    
    return integralSize;
}

CGSize CGSizeAspectFitSize(CGSize inputSize, CGSize parentSize){
    CGSize outSize = CGSizeZero;
    
    if (CGSizeEqualToSize(inputSize, CGSizeZero)) return CGSizeZero;
    if (CGSizeEqualToSize(parentSize, CGSizeZero)) return CGSizeZero;
    
    CGFloat scale = MAX(inputSize.width/parentSize.width,
                        inputSize.height/parentSize.height);
    
    outSize.width  = inputSize.width /scale;
    outSize.height = inputSize.height/scale;
    
    return outSize;
}

