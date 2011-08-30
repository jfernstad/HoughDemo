//
//  Buckets.h
//  HoughDemo
//
//  Created by Joakim Fernstad on 6/11/11.
//  Copyright 2011 Joakim Fernstad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bucket : NSObject {
    NSString bucketId;
    NSMutableSet* bucket;
}
@end

@interface Buckets : NSObject {
    NSMutableDictionary* buckets;
    
}

@end
