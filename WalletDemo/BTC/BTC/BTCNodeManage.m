//
//  BTCNodeManage.m
//  BTCDemo
//
//  Created by iOS on 2019/4/11.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "BTCNodeManage.h"

#define CC_BTC_CURRENT_NODE @"cc_btc_current_node"

@implementation BTCNodeManage

#pragma mark - 节点列表
+ (NSArray *)nodesArray {
    if ([self mainOrTest]) {
        return @[@"https://api.blockcypher.com/v1/btc/main"];
    } else {
        return @[@"https://api.blockcypher.com/v1/btc/test3"];
    }
}

+ (NSString *)saveKey {
    return [NSString stringWithFormat:@"%@_%@",CC_BTC_CURRENT_NODE,[self mainOrTest]?@"main":@"test"];
}


#pragma mark - 当前节点
+ (NSString *)currentNode {
    return [NSString stringWithFormat:@"%@_%@",CC_BTC_CURRENT_NODE,[self mainOrTest]?@"main":@"test"];
}

#pragma mark - 更换节点
+ (void)changeCurrentNode:(NSString *)node {
    NSString *saveKey = [BTCNodeManage saveKey];
    [[NSUserDefaults standardUserDefaults] setObject:node forKey:saveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 是否是主网
+ (BOOL)mainOrTest {
    return NO;
}

#pragma mark - 浏览器查看地址详情
+ (NSString *)addressBTCExplorerWithAddress:(NSString *)address {
        return [self mainOrTest]?[NSString stringWithFormat:@"https://live.blockcypher.com/btc/address/%@",address]:[NSString stringWithFormat:@"https://live.blockcypher.com/btc-testnet/address/%@",address];
}

#pragma mark - 浏览器查看交易记录
+ (NSString *)btcTradeDetailUrlWithTxId:(NSString *)txId {
    if ([txId hasPrefix:@"0x"]) {
        txId = [txId substringFromIndex:2];
    }
        return [self mainOrTest]?[NSString stringWithFormat:@"https://live.blockcypher.com/btc/tx/%@",txId]:[NSString stringWithFormat:@"https://live.blockcypher.com/btc-testnet/tx/%@",txId];
}

@end
