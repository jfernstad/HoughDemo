//
//  InfoViewController.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/10/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "InfoViewController.h"

@implementation InfoViewController
@synthesize webView;

- (void)dealloc{

    self.webView = nil;
    [super dealloc];
}

- (void)loadView{
    
    [super loadView];

    NSURLRequest* infoRequest = [[[NSURLRequest alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"information" withExtension:@"html"]] autorelease];
    webView = [[UIWebView alloc] initWithFrame:CGRectZero];

    self.webView.frame = self.contentRect;
    [self.webView loadRequest:infoRequest];
    
    self.webView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.webView.opaque = NO;

    [self.view addSubview:webView];
}


@end
