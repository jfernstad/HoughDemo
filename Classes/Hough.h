//
//  Hough.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 NOW Electronics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hough : NSObject {
	CGRect frame;
	
	NSArray* pointsCopy;
	NSMutableArray* curves;
}
@property (nonatomic, assign) CGRect frame;

+(CGFloat)yScale;
-(CGImageRef)newHoughSpaceFromPoints: (NSArray*)points;
-(void)clear;
@end
