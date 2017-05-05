//
//  DMScanCodeCamera.h
//  Pods
//
//  Created by ShawnDu on 2017/5/3.
//
//

#import <Foundation/Foundation.h>
#import "DMVideoCamera.h"

@protocol DMScanCodeCameraDelegate <NSObject>
- (void)captureCodeStringOutput:(NSString *)outputString;
@end
@interface DMScanCodeCamera : DMVideoCamera
@property (nonatomic) CGRect rectOfInterest; // (y, x, height, width)
@property (nonatomic, weak) id<DMScanCodeCameraDelegate> scanCodeDelegate;
@end
