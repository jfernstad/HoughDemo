//
//  FreehandConfigurationView.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 9/11/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigurationBaseView.h"

@interface FreeHandConfigurationView : ConfigurationBaseView{
    UILabel* drawLabel;
    UILabel* analysisLabel;
    UILabel* thresholdLabel;
    
    UISwitch* drawMode;
    UISwitch* analysisMode;
//    UISlider* linesSlider;
    UISlider* thresholdSlider;
}


@end
