//
//  UIColor+HoughExtension.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIColor+HoughExtensions.h"


@implementation UIColor (UIColor_HoughExtensions)

#pragma Base palette
+(UIColor*)houghGreen{
    return [UIColor colorWithRed:0.2 green:0.3 blue:0.2 alpha:1.0];
}
+(UIColor*)houghLightGreen{
    return [UIColor colorWithRed:0.05 green:0.1 blue:0.1 alpha:1.0];
}
+(UIColor*)houghRed{
    return [UIColor colorWithRed:0.7 green:0.1 blue:0.3 alpha:1.0];
}
+(UIColor*)houghLightRed{
    return [UIColor colorWithRed:0.7 green:0.5 blue:0.5 alpha:1.0];
}
+(UIColor*)houghWhite{
    return [UIColor colorWithRed:0.2 green:0.3 blue:0.2 alpha:1.0];
}
+(UIColor*)houghGray{
    return [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0];
}
+(UIColor*)houghBlue{
    return [UIColor colorWithRed:0.2 green:0.3 blue:0.2 alpha:1.0];
}
+(UIColor*)houghYellow{
    return [UIColor yellowColor];
}
#pragma Colors
+(UIColor*)borderColor{
    return [UIColor houghGreen];
}
+(UIColor*)mainBackgroundColor{
    return [UIColor houghGray];
}
+(UIColor*)inputBackgroundColor{
    return [UIColor houghLightGreen];
}
+(UIColor*)houghBackgroundColor{
    return [UIColor blackColor];
}
+(UIColor*)toolbarTintColor{
    return [UIColor houghGreen];
}
+(UIColor*)lineColor{
    return [UIColor houghRed];
}
+(UIColor*)markColor{
    return [UIColor houghYellow];
}
@end
