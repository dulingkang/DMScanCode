//
//  DMVideoCamera.h
//  DMScanCode
//
//  Created by ShawnDu on 2017/4/27.
//  Copyright © 2017年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface DMVideoCamera : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic) CGRect scanRect;
@property (nonatomic) CGFloat zoomFactor; // 1 is original scale
@property (nonatomic, strong) CALayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;

- (void)start;
- (void)stop;
@end
