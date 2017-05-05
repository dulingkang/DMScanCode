//
//  DMVideoCamera.m
//  DMScanCode
//
//  Created by ShawnDu on 2017/4/27.
//  Copyright © 2017年 dmall. All rights reserved.
//

#import "DMVideoCamera.h"
#import <UIKit/UIKit.h>

@interface DMVideoCamera()
@property (nonatomic, strong) dispatch_queue_t captureQueue;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@end

@implementation DMVideoCamera

- (instancetype)init {
    if (self = [super init]) {
        [self setupCamera];
    }
    return self;
}
#pragma mark - public method
- (void)start {
    [self output];
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

- (void)stop {
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (_hasScanned) {
        return ;
    }
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    if ([self.videoCameraDelegate respondsToSelector:@selector(captureImageOutput:)]) {
        [self.videoCameraDelegate captureImageOutput:image];
    }
}

- (CGImageRef)createImageFromBuffer:(CVImageBufferRef)buffer
                               left:(size_t)left
                                top:(size_t)top
                              width:(size_t)width
                             height:(size_t)height CF_RETURNS_RETAINED {
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    size_t dataWidth = CVPixelBufferGetWidth(buffer);
    size_t dataHeight = CVPixelBufferGetHeight(buffer);
    
    if (left + width > dataWidth ||
        top + height > dataHeight) {
        [NSException raise:NSInvalidArgumentException format:@"Crop rectangle does not fit within image data."];
    }
    
    size_t newBytesPerRow = ((width*4+0xf)>>4)<<4;
    
    CVPixelBufferLockBaseAddress(buffer,0);
    
    int8_t *baseAddress = (int8_t *)CVPixelBufferGetBaseAddress(buffer);
    
    size_t size = newBytesPerRow*height;
    int8_t *bytes = (int8_t *)malloc(size * sizeof(int8_t));
    if (newBytesPerRow == bytesPerRow) {
        memcpy(bytes, baseAddress+top*bytesPerRow, size * sizeof(int8_t));
    } else {
        for (int y=0; y<height; y++) {
            memcpy(bytes+y*newBytesPerRow,
                   baseAddress+left*4+(top+y)*bytesPerRow,
                   newBytesPerRow * sizeof(int8_t));
        }
    }
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(bytes,
                                                    width,
                                                    height,
                                                    8,
                                                    newBytesPerRow,
                                                    colorSpace,
                                                    kCGBitmapByteOrder32Little|
                                                    kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef result = CGBitmapContextCreateImage(newContext);
    
    CGContextRelease(newContext);
    
    free(bytes);
    
    return result;
}

#pragma mark - setter
- (void)setZoomFactor:(CGFloat)zoomFactor {
    _zoomFactor = zoomFactor;
    NSError *error;
    if ([_device lockForConfiguration:&error]) {
        _device.videoZoomFactor = zoomFactor;
        [_device unlockForConfiguration];
    }
}

#pragma mark - getter
- (CALayer *)previewLayer {
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)_previewLayer;
    if (!_previewLayer) {
        previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _previewLayer = previewLayer;
    }
    return previewLayer;
}

- (AVCaptureVideoDataOutput *)output {
    if (!_output) {
        _output = [[AVCaptureVideoDataOutput alloc] init];
        [_output setVideoSettings:@{(NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]}];
        [_output setAlwaysDiscardsLateVideoFrames:YES];
        [_output setSampleBufferDelegate:self queue:_captureQueue];
        [self.session addOutput:_output];
    }
    return _output;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            _session.sessionPreset = AVCaptureSessionPreset1920x1080;
        } else {
            _session.sessionPreset = AVCaptureSessionPreset1280x720;
        }
        _device  = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        [_session addInput:_input];
    }
    return _session;
}

#pragma mark - private method
- (void)setupCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    if(![self isAVCaptureActive]) {
        [self showAccessAlert];
    }
    _captureQueue = dispatch_queue_create("com.dmall.VideoQueue", DISPATCH_QUEUE_SERIAL);
}

- (BOOL)isAVCaptureActive {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusNotDetermined || authStatus == AVAuthorizationStatusAuthorized)
    {
        return YES;
    }
    return NO;
}

- (void)showAccessAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"此应用程序没有权限来访问相机" message:@"您可以在\"隐私设置\"中启用访问" delegate:self cancelButtonTitle:@"取消"otherButtonTitles:@"设置",nil];
    [alertView show];
}
@end
