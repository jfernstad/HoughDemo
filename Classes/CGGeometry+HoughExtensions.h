//
//  CGGeometry+HoughExtensions.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/2/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#include <CoreGraphics/CGGeometry.h>

// CGRect related
CGRect CGRectWithCenter(CGPoint p, CGFloat radius);
CGRect CGRectCenteredInRect(CGRect referenceRect, CGSize sizeToCenter);

// CGSize related
CGSize CGSizeIntegral(CGSize inputSize);
CGSize CGSizeAspectFitSize(CGSize inputSize, CGSize parentSize);