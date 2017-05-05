 //
//  CameraMaskView.m
//  LianZhiParent
//
//  Created by jslsxu on 15/5/13.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "CKCameraMaskView.h"
#import <QuartzCore/QuartzCore.h>
#define CLOSE_KEY           [[[UIApplication sharedApplication] keyWindow] endEditing:YES]
#define kScanBorderMargin       0
#define kScanLineHeight         59
@interface DMCKGridLayer ()

@end

@implementation DMCKGridLayer
+ (BOOL)needsDisplayForKey:(NSString*)key
{
    if ([key isEqualToString:@"clippingRect"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if(self && [layer isKindOfClass:[DMCKGridLayer class]]){
        self.bgColor   = ((DMCKGridLayer*)layer).bgColor;
        self.clippingRect = ((DMCKGridLayer*)layer).clippingRect;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rct = self.bounds;
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillRect(context, rct);
    
    CGContextClearRect(context, _clippingRect);
}

@end

@implementation CKCameraMaskView

- (void)dealloc
{
    NSLog(@"========%@",self.class);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        
        _gridLayer  = [[DMCKGridLayer alloc] init];
        _gridLayer.bgColor = [UIColor colorWithRed:12/255 green:12/255 blue:23/255 alpha:0.9];
//        [_gridLayer setBgColor:RGBA(12, 12, 23, 0.9)];
        [_gridLayer setFrame:self.bounds];
        [self.layer addSublayer:_gridLayer];
        
        _borderView = [[UIView alloc] initWithFrame:CGRectZero];
        [_borderView.layer setBorderColor:[UIColor clearColor].CGColor];
        [_borderView.layer setBorderWidth:0.5];
        [_borderView setClipsToBounds:YES];
        [self addSubview:_borderView];
        
        _scanLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScanLine"]];
        [_borderView addSubview:_scanLine];
        
        _hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.frame.size.width, 20)];
        [_hintLabel setBackgroundColor:[UIColor clearColor]];
        [_hintLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_hintLabel];

        _maskImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ScanBorder"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)]];
        [self addSubview:_maskImageView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        self.inputTextField = [[UITextField alloc]initWithFrame:_borderView.frame];
        self.inputTextField.backgroundColor= [UIColor whiteColor];
        self.inputTextField.font = [UIFont boldSystemFontOfSize:16];
//        self.inputTextField.textColor=[UIColor colorWithString:@"0x383838"];
        self.inputTextField.textAlignment = NSTextAlignmentCenter;
        self.inputTextField.placeholder = @"请输入商品条形码";
        self.inputTextField.keyboardType = UIKeyboardTypeNumberPad;
        self.inputTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
        self.inputTextField.hidden = YES;
        [self addSubview:self.inputTextField];
    }
    return self;
}

- (void)setTitle:(NSAttributedString *)title
{
    _title = title;
    [_hintLabel setAttributedText:_title];
}

- (void)setNoMaskRect:(CGRect)noMaskRect
{
    CLOSE_KEY;
    self.inputTextField.text = nil;
    CGRect originalRect = _noMaskRect;
    _noMaskRect = noMaskRect;
    if(!CGRectEqualToRect(originalRect, CGRectZero))
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"clippingRect"];
        animation.duration = kAnimationDuration;
        animation.fromValue = [NSValue valueWithCGRect:originalRect];
        animation.toValue = [NSValue valueWithCGRect:_noMaskRect];
        [_gridLayer addAnimation:animation forKey:nil];
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            _maskImageView.frame = CGRectInset(_noMaskRect, - kScanBorderMargin, - kScanBorderMargin);
            _borderView.frame = _noMaskRect;
            
            if (self.maskType==MaskTypeInput) {
                self.inputTextField.hidden = NO;
                self.inputTextField.frame = _borderView.frame;
                [self.inputTextField becomeFirstResponder];
            }else{
                self.inputTextField.hidden = YES;
                self.inputTextField.frame = _borderView.frame;
                
            }
        }];
    }
    else
    {
        _maskImageView.frame = CGRectInset(_noMaskRect, - kScanBorderMargin, - kScanBorderMargin);
        _borderView.frame = _noMaskRect;
        self.inputTextField.frame = _borderView.frame;
    }
    [_scanLine setFrame:CGRectMake(0, - kScanLineHeight, _noMaskRect.size.width, kScanLineHeight)];
    _hintLabel.frame = CGRectMake(_hintLabel.frame.origin.x, _noMaskRect.origin.y - _hintLabel.frame.size.height - 10, _hintLabel.frame.size.width, _hintLabel.frame.size.height);
    _gridLayer.clippingRect = _noMaskRect;
    [_gridLayer setNeedsDisplay];
    
    
    
}

- (void)startScan
{
    [_scanLine setHidden:NO];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(_borderView.frame.size.width / 2, - kScanLineHeight / 2)]];
    [animation setToValue:[NSValue valueWithCGPoint:CGPointMake(_borderView.frame.size.width / 2, self.noMaskRect.size.height + kScanLineHeight / 2)]];
    [animation setRepeatCount:NSIntegerMax];
    [animation setDuration:2];
    [_scanLine.layer addAnimation:animation forKey:@"position"];
}

- (void)stopScan
{
    [_scanLine setHidden:YES];
    [_scanLine.layer removeAllAnimations];
}

- (void)onApplicationBecomeActive
{
    [_scanLine.layer removeAllAnimations];
    [self startScan];
}
@end
