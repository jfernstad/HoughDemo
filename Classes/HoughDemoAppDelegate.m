//
//  HoughDemoAppDelegate.m
//  HoughDemo
//
//  Created by Joakim Fernstad on 2/26/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import "HoughConstants.h"
#import "HoughDemoAppDelegate.h"
#import "HoughFreeHandViewController.h"
#import "HoughImageViewController.h"
#import "InfoViewController.h"

@implementation HoughDemoAppDelegate

@synthesize window;
@synthesize tabBar;
@synthesize freehandVC;
@synthesize imageVC;
@synthesize infoVC;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    [UIApplication sharedApplication].statusBarHidden = YES;

    tabBar              = [[UITabBarController alloc] init];
    
    freehandVC = [[HoughFreeHandViewController alloc] init];
    freehandVC.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Freehand" image:[UIImage imageNamed:@"gear.png"] tag:0] autorelease];
    
    imageVC = [[HoughImageViewController alloc] init];
    imageVC.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Image" image:[UIImage imageNamed:@"gear.png"] tag:1] autorelease];

    infoVC = [[InfoViewController alloc] init];
    infoVC.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Info" image:[UIImage imageNamed:@"gear.png"] tag:2] autorelease];
    
    NSArray* vcs = [NSArray arrayWithObjects:freehandVC, imageVC, infoVC, nil];
    
    [tabBar setViewControllers:vcs animated:NO];
    

    // Override point for customization after app launch. 
    [self.window addSubview:tabBar.view];
    [self.window makeKeyAndVisible];

	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    self.freehandVC = nil;
    self.imageVC = nil;
    self.infoVC = nil;
    self.tabBar = nil;
    [window release];
    [super dealloc];
}


@end
