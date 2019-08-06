//
//  BTCApi.m
//  BTCDemo
//
//  Created by iOS on 2019/4/11.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "BTCApi.h"
#import "BTCNodeManage.h"
#import "CypherRequest.h"

@implementation BTCApi

#pragma mark - 查询交易
+ (void)getBTCTransactionWithTxid:(NSString *)txId
                       completion:(void(^)(NSDictionary *info))completion {
    
    [CypherRequest getBTCTransactionWithTxid:txId completion:completion];
    
}

#pragma mark - 查询余额
+ (void)getBalanceWithAddress:(NSString *)address
                       tokens:(NSArray *)tokens
                   completion:(void(^)(NSArray <NSDictionary *> *balance))completion {
    [CypherRequest getBTCBalanceWithAddress:address completion:^(NSString *balance) {
        if (balance && tokens.count) {
            completion(@[@{@"tokenAddress":tokens.firstObject,
                           @"balance":balance
                           }]);
        } else {
            completion(nil);
        }
    }];
}

#pragma mark - 获取未花费
+ (void)unspentOutputsWithAddress:(NSString *)address
                       completion:(void(^)(NSArray *array))completion {
    
    [CypherRequest unspentOutputsWithAddress:address completion:completion];
}

#pragma mark - 广播交易
+ (void)pushTx:(NSString *)txHash
    completion:(void(^)(NSString *hash))completion {
    
    [CypherRequest pushTx:txHash completion:completion];
}


#pragma mark - 获取区块链信息
+ (void)getBTCChainInfo:(void(^)(NSDictionary *info))completion {
    
    [CypherRequest getBTCChainInfo:completion];
}


#pragma mark -获取UTXO的交易信息
+ (void)getUTXOHexsWithTx_hashs:(NSArray *)tx_hashs completion:(void(^)(BOOL suc, NSDictionary *hexs))completion {
    
    [CypherRequest getUTXOHexsWithTx_hashs:tx_hashs completion:completion];
}

@end
