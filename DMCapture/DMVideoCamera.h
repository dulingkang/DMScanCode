//
//  DMVideoCamera.h
//  DMScanCode
//
//  Created by ShawnDu on 2017/4/27.
//  Copyright © 2017年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface DMVideoCamera : NSObject
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic) CGRect scanRect;
@property (nonatomic) CGFloat zoomFactor; // 1 is original scale
- (void)start;
- (void)stop;
@end
