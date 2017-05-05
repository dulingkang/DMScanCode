//
//  NSString+encrypt.h
//  DMScanDemo
//
//  Created by ShawnDu on 2017/5/3.
//  Copyright © 2017年 dmall. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (encrypt)
- (NSString *)sha1_base64;
- (NSString *)sha256_base64;
- (NSString *)sha256;
- (NSString *)hmacsha1_base64:(NSString *)secret;
- (NSString *)md5;
@end
