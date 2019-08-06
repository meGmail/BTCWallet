//
//  BTCApi.h
//  BTCDemo
//
//  Created by iOS on 2019/4/11.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BTCApi : NSObject

//查询交易
+ (void)getBTCTransactionWithTxid:(NSString *)txId
                       completion:(void(^)(NSDictionary *info))completion;



//获取未花费
+ (void)unspentOutputsWithAddress:(NSString *)address
                       completion:(void(^)(NSArray *array))completion;

//广播交易
+ (void)pushTx:(NSString *)txHash
    completion:(void(^)(NSString *hash))completion;


//获取区块链信息
+ (void)getBTCChainInfo:(void(^)(NSDictionary *info))completion;

//获取UTXO的交易信息
+ (void)getUTXOHexsWithTx_hashs:(NSArray *)tx_hashs completion:(void(^)(BOOL suc, NSDictionary *hexs))completion;

@end
