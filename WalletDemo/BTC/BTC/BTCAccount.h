//
//  BTCAccount.h
//  BTCDemo
//
//  Created by iOS on 2019/4/8.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTCUnitsAndLimits.h"

@class BTCTransaction,BTCKey;
@interface BTCAccount : NSObject

@property (nonatomic, strong, readonly) NSString *address;
@property (nonatomic, strong, readonly) NSString *privateKey;
@property (nonatomic, strong, readonly) NSString *publicKey;
@property (nonatomic, strong, readonly) NSString *WIF;
/**
 是否是隔离见证
 */
@property (nonatomic, assign, readonly) BOOL segwit;


/**
 助记词创建
 
 @param mnemonics 助记词
 @param segwit 是否隔离见证
 @param slot slot
 @return BTCAccount
 */
- (instancetype)initWithMnemonic:(NSString *)mnemonics isSegwit:(BOOL)segwit slot:(int)slot;


/**
 WIF创建
 
 @param WIF WIF
 @param segwit 是否隔离见证
 @return BTCAccount
 */
- (instancetype)initWithWIF:(NSString *)WIF isSegwit:(BOOL)segwit;

/**
私钥创建

 @param privateKey 私钥
 @param segwit 是否隔离见证
 @return BTCAccount
 */
- (instancetype)initWithPrivateKey:(NSString *)privateKey isSegwit:(BOOL)segwit;

/**
 切换隔离见证
 
 @param segwit 是否隔离见证
 */
- (void)changeSegWit:(BOOL)segwit;


// omni转账
- (void)transactionTo:(NSString *)toAddress
                  fee:(NSString *)feeString
            omniValue:(NSString *)omniValue
               omniId:(NSString *)omniId
           completion:(void(^)(NSString *txHash))completion;

- (void)transactionTo:(NSString *)toAddress
                  fee:(NSString *)feeString
            omniValue:(NSString *)omniValue
               omniId:(NSString *)omniId
                utxos:(NSArray *)utxos
           completion:(void(^)(NSString *txHash))completion;

// 转账BTC
- (void)transactionTo:(NSString *)toAddress
               amount:(NSString *)amount
                  fee:(NSString *)feeString
           completion:(void(^)(NSString *txHash))completion;

- (void)transactionTo:(NSString *)toAddress
               amount:(NSString *)amount
                  fee:(NSString *)feeString
                utxos:(NSArray *)utxos
           completion:(void(^)(NSString *txHash))completion;


//预估手续费
+ (void)estimateFeeAddress:(NSString *)address
                    amount:(NSString *)amountString
                    isOmni:(BOOL)isOmni
                      utxo:(NSArray *)utxos
                completion:(void(^)(NSString *estimate))completion;

+ (void)test1;
+ (void)test2;

@end
