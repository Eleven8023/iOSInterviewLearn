//
//  HashLearn.m
//  Highlevel
//
//  Created by Eleven on 2018/11/4.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "HashLearn.h"
#import <CommonCrypto/CommonDigest.h>

#import <objc/runtime.h>
#import <objc/message.h>
/**
 *  Hash '散列'  将任意长度的输入通过hash算法变换成固定长度的输出
 *  特点  算法是公开的   对相同数据运算,得到的结果是一样的  对不用数据运算, 如MD5得到的结果都是32个字符长度的字符串  没有逆运算
 *  场景  登录密码加密  hash运算加密密码发送服务端验证, 因为无法逆运算 所以真是密码不会泄露   服务端保存的是hash值不是密码本身   重置密码 替代找回密码的功能
 *  md5反向查询 网址   http://www.cmd5.com/
 ** 其他作用: 版权文件识别   通过音视频文件的Hash值对比
 */


@implementation HashLearn
// 加盐    特点  反查询比较困难 安全系数相对较高  存在盐被泄漏的风险
- (void)hashCal{
    NSString *pwd = @"123456";
    // 足够复杂  足够长
    static NSString *salt = @")@#$#@%$#%!(";
    // h将铭文拼接一个盐
    pwd = [pwd stringByAppendingString:salt];
    // 再进行Hash算法
    const char *str = pwd.UTF8String;
    uint8_t buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD2(str, (CC_LONG)strlen(str), buffer);
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5Str appendFormat:@"%02x",buffer[i]];
    }
}

// HMAC  双层加密 更安全 使用一个密钥  并且做两次hash
- (void)doubleHash{
    NSString *pwd = @"123456";
    // 加密用的KEY  从服务器获取的
    NSString *key = @"ghjkl";
    // 转成C串
    const char *keyData = key.UTF8String;
    const char *strData = pwd.UTF8String;
    uint8_t buffer[CC_MD5_DIGEST_LENGTH];
    // hmac加密
//    CCHmac(kCCHmacAlgSHA1,keyData, strlen(keyData), strData, strlen(strData), buffer);
    NSMutableString *hmacStr = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hmacStr appendFormat:@"%02x", buffer[i]];
    }

    id objc_getAssociatedObject(id object, const void *key);
    void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy);
    void objc_removeAssociatedObjects(id objeect);

}

@end



























