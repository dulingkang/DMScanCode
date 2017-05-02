//
//  ViewController.m
//  DMScanDemo
//
//  Created by ShawnDu on 2017/4/27.
//  Copyright © 2017年 dmall. All rights reserved.
//

#import "ViewController.h"
#import <DMScanCode/DMVideoCamera.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DMVideoCamera *camera = [DMVideoCamera new];
    AVCaptureVideoPreviewLayer *previewLayer =[AVCaptureVideoPreviewLayer layerWithSession:camera.session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:previewLayer];
    camera.zoomFactor = 1.6;
    [camera start];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
