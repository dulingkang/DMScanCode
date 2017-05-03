//
//  ViewController.m
//  DMScanDemo
//
//  Created by ShawnDu on 2017/4/27.
//  Copyright © 2017年 dmall. All rights reserved.
//

#import "ViewController.h"
#import <DMScanCode/DMScanCodeCamera.h>
#import <DMScanCode/CKCameraMaskView.h>

#define NavHeight  64
#define SCREEN_WID ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEI ([UIScreen mainScreen].bounds.size.height)
#define kScanWidth              SCREEN_WID*0.9    //扫描宽度
#define kScanHeight             (SCREEN_HEI-NavHeight)*0.37    //扫描高度
#define kScanY                  (SCREEN_HEI-NavHeight)*0.05+NavHeight    //扫描Y坐标
#define ckScanQRCodeMaskRect  CGRectMake((SCREEN_WID - kScanWidth)/2,kScanY,kScanWidth,kScanHeight)


@interface ViewController ()<DMScanCodeCameraDelegate>
@property (nonatomic, strong) DMScanCodeCamera *camera;
@property (nonatomic, strong) CKCameraMaskView *maskView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addScanCodeCamera];
    [self addMaskView];
}

#pragma mark - DMScanCodeCameraDelegate
- (void)captureCodeStringOutput:(NSString *)outputString {
    [self.maskView stopScan];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:outputString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.camera.hasScanned = NO;
        [self.maskView startScan];
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark - private method
- (void)addScanCodeCamera {
    _camera = [DMScanCodeCamera new];
    _camera.scanCodeDelegate = self;
    [self.view.layer addSublayer:_camera.previewLayer];
    _camera.zoomFactor = 1.6;
    _camera.rectOfInterest = CGRectMake(ckScanQRCodeMaskRect.origin.y/SCREEN_HEI, ckScanQRCodeMaskRect.origin.x/ SCREEN_WID, ckScanQRCodeMaskRect.size.height/SCREEN_HEI, ckScanQRCodeMaskRect.size.width/SCREEN_WID);
    [_camera start];
}

- (void)addMaskView {
    _maskView = [[CKCameraMaskView alloc] initWithFrame:self.view.bounds];
    [_maskView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:_maskView];
    [_maskView setNoMaskRect:ckScanQRCodeMaskRect];
    [_maskView setMaskType:MaskTypeQRCode];
    [_maskView startScan];
}
@end
