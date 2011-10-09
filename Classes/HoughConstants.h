//
//  HoughConstants.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/11/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#ifndef HoughDemo_HoughConstants_h
#define HoughDemo_HoughConstants_h

// From http://stackoverflow.com/questions/969130/nslog-tips-and-tricks
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define CORNER_RADIUS 10
#define EDGE_WIDTH     2

#define kSelectedImageNotification      @"SelectedImageNotification" // Value = NSString, UIImagePickerControllerReferenceURL from ImagePickerController

// Configuration keys
#define kHoughAnalysisModeChanged           @"HoughAnalysisModeChanged"
#define kHoughDrawModeChanged               @"HoughDrawModeChanged"
#define kHoughThresholdChanged              @"HoughThresholdChanged"
#define kHoughGrayscaleThresholdChanged     @"HoughGrayscaleThresholdChanged"

#define kHoughDebugFlagChanged              @"HoughDebugFlagChanged"
#endif
