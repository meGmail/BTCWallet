//
//  BTCNodeManage.h
//  BTCDemo
//
//  Created by iOS on 2019/4/11.
//  Copyright © 2019 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTCNodeManage : NSObject

/**
 节点列表
 
 @return 节点列表
 */
+ (NSArray *)nodesArray;

/**
 当前节点
 
 @return 当前节点
 */
+ (NSString *)currentNode;

/**
 更换节点
 
 @param node 新节点
 */
+ (void)changeCurrentNode:(NSString *)node;

/**
 浏览器查看地址详情
 
 @param address 地址
 @return 地址详情网址
 */
+ (NSString *)addressBTCExplorerWithAddress:(NSString *)address;

/**
 浏览器查看交易记录
 
 @param txId txid
 @return 交易记录网址
 */
+ (NSString *)btcTradeDetailUrlWithTxId:(NSString *)txId;

/**
 主网 测试网
 
 @return YES主网 NO测试网
 */
+ (BOOL)mainOrTest;

@end
