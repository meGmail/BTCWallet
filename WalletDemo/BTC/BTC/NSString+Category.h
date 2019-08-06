//
//  NSString+Category.h
//  BTCDemo
//
//  Created by iOS on 2018/7/23.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)

/**
 保留小数后几位

 @param number number
 @param roundMode 四舍五入规则，  四舍五入NSRoundPlain 舍NSRoundDown 进1 NSRoundUp
 @param position 位数
 @return 返回值
 */
+ (NSString *)formatDecimalNum:(NSDecimalNumber *)number roundMode:(NSRoundingMode)roundMode afterPoint:(int)position;


/**
 转换精度

 @param value 原值
 @param decimal 小数位
 @return 返回值
 */
+ (NSString *)valueString:(NSString *)value decimal:(NSString *)decimal;



/**
 转换精度

 @param value 原值
 @param decimal 精度
 @param isPositive 正 负
 @return 返回值
 */
+ (NSDecimalNumber *)numberValueString:(NSString *)value decimal:(NSString *)decimal isPositive:(BOOL)isPositive;

/**
 不区分大小写的不交

 @param string string
 @return BOOL
 */
- (BOOL)compareWithString:(NSString *)string;


@end
