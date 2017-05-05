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
#import "NSString+encrypt.h"
#import "NSData+encrypt.h"

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
    NSString *urlStr = @"https://api.productai.cn/detect_ordinary_products/_0000030";
    NSString *secretKey = @"1660382f1af3f421217e80d509d5e728";
    [self requestMaLong:urlStr image:[UIImage imageNamed:@"test1.jpg"] key:secretKey];
//    [self addScanCodeCamera];
//    [self addMaskView];
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

- (void)requestMaLong:(NSString *)urlStr image:(UIImage *)image key:(NSString *)key {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 20;
    NSTimeInterval timeInSeconds = [[NSDate date] timeIntervalSince1970];
    NSString *timeStr = [NSString stringWithFormat:@"%ld", (long)timeInSeconds];
    NSData *bodyData = UIImageJPEGRepresentation(image, 0.6);
    NSString *str = [NSString stringWithFormat:@"requestmethod=POST&x-ca-accesskeyid=22217560eea449af05cd0a185445c754&x-ca-signaturenonce=%@&x-ca-timestamp=%@&x-ca-version=1", timeStr,timeStr];
    request.allHTTPHeaderFields = @{@"x-ca-version" : @"1",
                                    @"x-ca-accesskeyid" : @"22217560eea449af05cd0a185445c754",
                                    @"x-ca-timestamp" : timeStr,
                                    @"x-ca-signature" : [str hmacsha1_base64:key],
                                    @"x-ca-signaturenonce" : timeStr,
                                    @"requestmethod" : @"POST"};

    request.HTTPBody = bodyData;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@", response);
    }];
//    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:bodyData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"%@", response);
//    }];
    [task resume];
}

@end
