//
//  DMScanCodeCamera.m
//  Pods
//
//  Created by ShawnDu on 2017/5/3.
//
//

#import "DMScanCodeCamera.h"

@interface DMScanCodeCamera()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureMetadataOutput *metaOutput;
@property (nonatomic, strong) dispatch_queue_t scanQueue;
@end
@implementation DMScanCodeCamera

- (instancetype)init {
    if (self = [super init]) {
        _scanQueue = dispatch_queue_create("com.dmall.scanQueue", DISPATCH_QUEUE_SERIAL);
    }
    return  self;
}

#pragma mark - public method rewrite father method
- (void)start {
    [self output];
    [self metaOutput];
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate rewrite father mathod
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.hasScanned) {
        return;
    }
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    NSArray *features = [[self highAccuracyQRDetector] featuresInImage:image];
    CIQRCodeFeature *feature = features.firstObject;
    if (feature.messageString.length > 0) {
        self.hasScanned = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.scanCodeDelegate respondsToSelector:@selector(captureCodeStringOutput:)]) {
                [self.scanCodeDelegate captureCodeStringOutput:feature.messageString];
            }
        });
    }
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count == 0 || self.hasScanned) {
        return ;
    }
    AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects firstObject];
    NSString *stringValue = metadataObject.stringValue;
    if (stringValue != nil && [metadataObject.type isEqualToString:AVMetadataObjectTypeEAN13Code] && [stringValue hasPrefix:@"0"] && [stringValue length]==13) {
        stringValue = [stringValue substringFromIndex:1];
    }
    if (stringValue.length > 0) {
        self.hasScanned = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.scanCodeDelegate respondsToSelector:@selector(captureCodeStringOutput:)]) {
                [self.scanCodeDelegate captureCodeStringOutput:stringValue];
            }
        });
    }
}

#pragma mark - getter
- (AVCaptureMetadataOutput *)metaOutput {
    if (!_metaOutput) {
        _metaOutput = [[AVCaptureMetadataOutput alloc] init];
        [_metaOutput setMetadataObjectsDelegate:self queue:_scanQueue];
        [self.session addOutput:_metaOutput];
        [_metaOutput setMetadataObjectTypes:@[AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeDataMatrixCode,AVMetadataObjectTypeITF14Code]];
    }
    return _metaOutput;
}

#pragma mark - setter
- (void)setRectOfInterest:(CGRect)rectOfInterest {
    _rectOfInterest = rectOfInterest;
    self.metaOutput.rectOfInterest = rectOfInterest;
}

#pragma mark - private method
- (CIDetector *)highAccuracyQRDetector
{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
                  });
    return detector;
}
@end
