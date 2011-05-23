//
//  CGGeometry+HoughExtensions.c
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/2/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#include "CGGeometry+HoughExtensions.h"

CGRect CGRectWithCenter(CGPoint p, CGFloat radius){
	return CGRectMake(p.x-radius, p.y-radius, 2*radius+1, 2*radius+1);
}

CGRect CGRectCenteredInRect(CGRect referenceRect, CGSize sizeToCenter){
    CGRect outRect = CGRectZero;
    
    outRect.origin = CGPointMake((referenceRect.size.width  - sizeToCenter.width)/2, 
                                 (referenceRect.size.height - sizeToCenter.height)/2);
    outRect.size = sizeToCenter;
    
    return outRect;
}