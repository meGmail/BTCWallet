//
//  CypherRequest.m
//  BTCDemo
//
//  Created by iOS on 2019/4/10.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "CypherRequest.h"
#import "BTCTransactionOutput.h"
#import "BTCScript.h"
#import "BTCData.h"
#import "BTCTransaction.h"
#import "NSString+Bitcoin.h"
#import "BTCNodeManage.h"

@interface CypherRequest ()

@property (nonatomic, assign) BOOL isTest;

@end

@implementation CypherRequest

#pragma mark - 未花费
+ (void)unspentOutputsWithAddress:(NSString *)address
                       completion:(void(^)(NSArray *array))completion {
    CypherRequest *request = [[CypherRequest alloc] init];
    request.urlStr = [NSString stringWithFormat:@"addrs/%@?unspentOnly=1&includeScript=1",address];
    request.method = YTKRequestMethodGET;
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *dic = request.responseObject;
        if (dic && [dic isKindOfClass:[NSDictionary class]]) {
            NSArray *txrefs = dic[@"txrefs"];
            if (txrefs) {
                NSMutableArray *result = [NSMutableArray array];
                for (NSDictionary *item in txrefs) {
                    BTCTransactionOutput* txout = [[BTCTransactionOutput alloc] init];
                    txout.value = [item[@"value"] longLongValue];
                    txout.script = [[BTCScript alloc] initWithData:BTCDataFromHex(item[@"script"])];
                    txout.index = [item[@"tx_output_n"] intValue];
                    txout.confirmations = [item[@"confirmations"] unsignedIntegerValue];
                    txout.transactionHash = (BTCReversedData(BTCDataFromHex(item[@"tx_hash"])));
                    txout.blockHeight = [item[@"block_height"] integerValue];
                    [result addObject:txout];
                }
                if (completion) {
                    completion(result);
                }
            } else {
                if (completion) {
                    completion(nil);
                }
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - 广播交易
+ (void)pushTx:(NSString *)tx
    completion:(void(^)(NSString *hash))completion {
    
    CypherRequest *request = [[CypherRequest alloc] init];
    request.urlStr = @"send";
    request.method = YTKRequestMethodPOST;
    request.parameter = @{@"sign":tx};
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *responseTx = request.responseObject[@"tx"];
        if (responseTx && [responseTx isKindOfClass:[NSDictionary class]]) {
            NSString *hash = responseTx[@"hash"];
            if (completion) {
                completion(hash);
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - 查询交易
+ (void)getBTCTransactionWithTxid:(NSString *)txId
                       completion:(void(^)(NSDictionary *info))completion {
    CypherRequest *request = [[CypherRequest alloc] init];
    request.method = YTKRequestMethodGET;
    request.urlStr = [NSString stringWithFormat:@"txs/%@",txId];
    request.parameter = @{
                          @"limit":@(1)//限制只返回一个input output，因为此接口现在不需要这些信息
                          };
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *result = request.responseObject;
        if (result && !result[@"error"]) {
            if (completion) {
                completion(result);
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - 查询余额
+ (void)getBTCBalanceWithAddress:(NSString *)address completion:(void (^)(NSString *))completion {
    CypherRequest *request = [[CypherRequest alloc] init];
    request.method = YTKRequestMethodGET;
    request.urlStr = [NSString stringWithFormat:@"addrs/%@/balance",address];
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *result = request.responseObject;
        if (result && !result[@"error"]) {
            if (completion) {
                completion(result[@"final_balance"]);
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - 获取链信息
+ (void)getBTCChainInfo:(void(^)(NSDictionary *info))completion {
    CypherRequest *request = [[CypherRequest alloc] init];
    request.method = YTKRequestMethodGET;
    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *result = request.responseObject;
        if (result) {
            if (completion) {
                completion(result);
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        if (completion) {
            completion(nil);
        }
    }];
}

#pragma mark - 获取UTXO的交易信息
+ (void)getUTXOHexsWithTx_hashs:(NSArray *)tx_hashs completion:(void(^)(BOOL suc, NSDictionary *hexs))completion {
    if (tx_hashs.count <= 0) {
        if (completion) {
            completion(NO, nil);
        }
        return;
    }
    NSMutableArray *requestArray = [NSMutableArray array];
    for (NSString *txId in tx_hashs) {
        CypherRequest *request = [[CypherRequest alloc] init];
        request.method = YTKRequestMethodGET;
        request.urlStr = [NSString stringWithFormat:@"txs/%@",txId];
        request.parameter = @{
                              @"includeHex":@(1),
                              @"limit":@(1)//限制只返回一个input output，因为此接口现在不需要这些信息
                              };
        [requestArray addObject:request];
    }
    
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:requestArray];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest * _Nonnull batchRequest) {
        NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
        for (YTKRequest *request in batchRequest.requestArray) {
            NSDictionary *result = request.responseObject;
            if (result && !result[@"error"]) {
                NSString *txId = result[@"hash"];
                NSString *hex = result[@"hex"];
                if (txId && hex) {
                    [resultDic setValue:hex forKey:txId];
                }
            }
        }
        if (resultDic.count == tx_hashs.count) {
            if (completion) {
                completion(YES, resultDic);
            }
        } else {
            if (completion) {
                completion(NO, nil);
            }
        }
    } failure:^(YTKBatchRequest * _Nonnull batchRequest) {
        if (completion) {
            completion(NO, nil);
        }
    }];
}

#pragma mark - 继承
- (NSString *)baseUrl {
    if ([BTCNodeManage mainOrTest]) {
        return @"https://api.blockcypher.com/v1/btc/main";
    } else {
        return @"https://api.blockcypher.com/v1/btc/test3";
    }
}


- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return @{
             @"Accept":@"application/json",
             @"Content-Type":@"text/html; charset=utf-8"
             };
}


@end
