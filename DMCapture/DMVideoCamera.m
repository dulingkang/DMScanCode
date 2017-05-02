//
//  DMVideoCamera.m
//  DMScanCode
//
//  Created by ShawnDu on 2017/4/27.
//  Copyright © 2017年 dmall. All rights reserved.
//

#import "DMVideoCamera.h"
#import <UIKit/UIKit.h>

@interface DMVideoCamera()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) dispatch_queue_t captureQueue;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
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
    if (![_session isRunning]) {
        [_session startRunning];
    }
}

- (void)stop {
    if ([_session isRunning]) {
        [_session stopRunning];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef videoFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    CGImageRef imageRef = [self createImageFromBuffer:videoFrame left:0 top:0 width:CVPixelBufferGetWidth(videoFrame) height:CVPixelBufferGetHeight(videoFrame)];
    if (!CGRectIsEmpty(self.scanRect)) {
        CGImageRef croppedImage = CGImageCreateWithImageInRect(imageRef, self.scanRect);
        CFRelease(imageRef);
        imageRef = croppedImage;
    }
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:imageRef]];
    for (CIFeature *feature in features) {
        NSLog(@"feature: %@", feature.type);
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
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

#pragma mark - getter setter
- (void)setZoomFactor:(CGFloat)zoomFactor {
    _zoomFactor = zoomFactor;
    NSError *error;
    if ([_device lockForConfiguration:&error]) {
        _device.videoZoomFactor = zoomFactor;
        [_device unlockForConfiguration];
    }
}

#pragma mark - private method
- (void)setupCamera {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return;
    }
    if([self isAVCaptureActive]) {
        _captureQueue = dispatch_queue_create("com.dmall.ScanQueue", NULL);
        NSError *error = nil;
        _device  = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        _session = [[AVCaptureSession alloc] init];
        [self configSessionPreset];
        
        _output  = [[AVCaptureVideoDataOutput alloc] init];
        [_output setVideoSettings:@{
                                    (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
                                    }];
        [_output setAlwaysDiscardsLateVideoFrames:YES];
        [_output setSampleBufferDelegate:self queue:_captureQueue];
        
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
        if ([_session canAddInput:_input]) {
            [_session addInput:_input];
        }
        if ([_session canAddOutput:_output]) {
            [_session addOutput:_output];
        }
        
    }
    else {
        [self showAccessAlert];
    }
    
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

- (void)configSessionPreset {
    if ([UIScreen mainScreen].bounds.size.height <= 480) {
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [_session setSessionPreset:AVCaptureSessionPreset1280x720];
        } else if ([_session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [_session setSessionPreset:AVCaptureSessionPreset1920x1080];
        }
    } else {
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            [_session setSessionPreset:AVCaptureSessionPreset1920x1080];
        } else {
            [_session setSessionPreset: AVCaptureSessionPresetHigh];
        }
    }
}
@end