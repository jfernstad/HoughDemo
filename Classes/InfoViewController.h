//
//  InfoViewController.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/10/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoughBaseViewController.h"

@interface InfoViewController : HoughBaseViewController{
    UIWebView* webView;
}
@property (nonatomic, retain) UIWebView* webView;

@end
