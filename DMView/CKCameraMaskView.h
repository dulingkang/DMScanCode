//
//  CameraMaskView.h
//  LianZhiParent
//
//  Created by jslsxu on 15/5/13.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Frame.h"
#define kAnimationDuration              0.25f
typedef NS_ENUM(NSInteger, MaskType)
{
    MaskTypeQRCode = 0,         //二维码
    MaskTypeBarCode,            //条形码
    MaskTypeInput               //输入
};
@interface DMCKGridLayer : CALayer
@property (nonatomic, assign)CGRect clippingRect;
@property (nonatomic, strong)UIColor *bgColor;
@end

@interface CKCameraMaskView : UIView
{
    DMCKGridLayer*    _gridLayer;
    UIView*         _borderView;
    UILabel*        _hintLabel;
    UIImageView*    _maskImageView;
    UIImageView*    _scanLine;
}
@property (nonatomic, copy)NSAttributedString *title;
@property (nonatomic, assign)CGRect noMaskRect;
@property (nonatomic, assign)MaskType maskType;
@property (nonatomic, strong)UITextField *inputTextField;
- (void)startScan;
- (void)stopScan;
@end
