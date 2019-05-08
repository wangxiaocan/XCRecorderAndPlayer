//
//  BaseEncryption.h
//  XCRecorderAndPlayer
//
//  Created by xiao can on 2019/5/8.
//  Copyright © 2019 xiaocan. All rights reserved.
//

#import <Foundation/Foundation.h>

//数据加密

@interface NSString (MyEncryption)

/** MD5 加密 */
- (NSString *)md5String;

/** sha1 加密 */
- (NSString*)sha1String;


- (NSString *)base64EncodeString;
- (NSString *)base64DecodeString;

/** aes 加密 */
- (NSString *)aesEncodeString:(NSString *)key;

/** aes 解密 */
- (NSString *)aesDecodeString:(NSString *)key;


/** unicode转成字符串 */
- (NSString*)lUnicodeToString;

/** 字符串转换成unicode */
- (NSString *)lStringToUnicode;




@end

@interface NSData (MyEncryption)

/** MD5 加密 */
- (NSString*)md5Data;

/** aes 加密 */
- (NSData *)aesEncoeData:(NSString *)key;

/** aes 解密 */
- (NSData *)aesDecodeData:(NSString *)key;

@end
