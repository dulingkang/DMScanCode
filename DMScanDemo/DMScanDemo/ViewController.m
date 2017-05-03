//
//  ViewController.m
//  DMScanDemo
//
//  Created by ShawnDu on 2017/4/27.
//  Copyright © 2017年 dmall. All rights reserved.
//

#import "ViewController.h"
#import <DMScanCode/DMScanCodeCamera.h>

@interface ViewController ()
@property (nonatomic, strong) DMScanCodeCamera *camera;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _camera = [DMScanCodeCamera new];
    [self.view.layer addSublayer:_camera.previewLayer];
    _camera.zoomFactor = 1.6;
    [_camera start];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
