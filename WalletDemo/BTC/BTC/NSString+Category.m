//
//  NSString+Category.m
//  BTCDemo
//
//  Created by iOS on 2018/7/23.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "NSString+Category.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Category)

#pragma mark - 保留小数后几位
+ (NSString *)formatDecimalNum:(NSDecimalNumber *)number roundMode:(NSRoundingMode)roundMode afterPoint:(int)position {
     NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:roundMode scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    NSDecimalNumber *result = [number decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return result.stringValue;
}


#pragma mark - 精度计算
+ (NSString *)valueString:(NSString *)value decimal:(NSString *)decimal {
    NSDecimalNumber *number = [NSString numberValueString:value decimal:decimal isPositive:NO];
    return number.stringValue;
}

+ (NSDecimalNumber *)numberValueString:(NSString *)value decimal:(NSString *)decimal isPositive:(BOOL)isPositive {
    if (![value isKindOfClass:[NSString class]]) {
        value = [NSString stringWithFormat:@"%@",value];
    }
    NSDecimalNumber *valueNum = [NSDecimalNumber decimalNumberWithString:value];
    NSDecimalNumber *decimalNum = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:decimal.integerValue*(isPositive?1:-1) isNegative:NO];
    NSDecimalNumber *result = [valueNum decimalNumberByMultiplyingBy:decimalNum];
    return result;
}


#pragma mark - u不区分大小写
- (BOOL)compareWithString:(NSString *)string {
    return [self caseInsensitiveCompare:string] == NSOrderedSame;
}

@end
