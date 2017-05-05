//
//  NSString+encrypt.m
//  DMScanDemo
//
//  Created by ShawnDu on 2017/5/3.
//  Copyright © 2017年 dmall. All rights reserved.
//

#import "NSString+encrypt.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (encrypt)

- (NSString *)sha1_base64 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSData *base64 = [[NSData alloc]initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    NSString *base64Str = [base64 base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return base64Str;
}

- (NSString *)sha256_base64 {
    const char *str = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG) strlen(str), result);
     NSData *data = [NSData dataWithBytes:(const void *)result
                          length:sizeof(unsigned char)*CC_SHA256_DIGEST_LENGTH];
    return [self base64StringFromData:data];
}

- (NSString *)base64StringFromData:(NSData *)theData
{
    const uint8_t *input = (const uint8_t *)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for ( NSInteger i=0; i<length; i+=3 ) {
        NSInteger value = 0;
        for ( NSInteger j=i; j<(i+3); j++) {
            value <<= 8;
            if ( j < length ) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i/3)*4;
        output[theIndex + 0] =                  table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                  table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i+1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i+2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (NSString *)sha256
{
    const char *str = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG) strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for ( int i=0; i<CC_SHA256_DIGEST_LENGTH; i++ ) {
        [ret appendFormat:@"%02x",result[i]];
    }
    
    return ret;
}

- (NSString *)hmacsha1_base64:(NSString *)secret {
    const char *cKey = [secret cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [self cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *signature = [HMAC base64EncodedStringWithOptions:0];
    return signature;
}

- (NSString *)md5{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}
@end
