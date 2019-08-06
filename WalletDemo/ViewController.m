//
//  ViewController.m
//  WalletDemo
//
//  Created by 徐俊 on 2019/8/6.
//  Copyright © 2019 wallet. All rights reserved.
//

#import "ViewController.h"
#import "HSEther.h"
#import "BTCAccount.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self BTCMethod];
    
    [self ETHMethod];
}

- (void)BTCMethod
{
    //1.在需要使用BTC的地方 导入 BTCAccount.h
    //2.提供助记词,WIF,私钥导入钱包的方法
    //3.获取助记词可使用ETH生成的也可使用其它方法生成的
    //4.BTC项目分主网和测试网 生产要改到主网 搜索方法 mainOrTest 返回YES
    //!!!!!5.转账获取未花费以及广播交易需要调用自己的接口或者免费的三方接口,现测试用的接口有次数限制
    //接口部分看BTCRequest 接口需要改成自己后台或者免费第三方api,现在使用的有请求次数限制
    
    //助记词导入
       BTCAccount *account = [[BTCAccount alloc] initWithMnemonic:@"intact gospel fashion you mammal video reveal private draw toast minimum dog" isSegwit:NO slot:0];
        NSLog(@"BTCAddress:%@\n BTCPrivate:%@\n WIF:%@",account.address,account.privateKey,account.WIF);
    
    BTCAccount *ac = [[BTCAccount alloc] initWithPrivateKey:@"da3d8e3b8dfc9a180dd45ebbcb108076733d887806e5b92eed9b366a3e4f1538" isSegwit:NO];
    NSLog(@"acPr:%@",ac.address);
    
    //6e249ae20823e4269429189d8737b7b3e6df3b29cdfc9494616953c574aa1566
    //da3d8e3b8dfc9a180dd45ebbcb108076733d887806e5b92eed9b366a3e4f1538 mzNYuVQsX5pGA1A1Pa4Drpq3EmQkQh76Ht
    //cUtw3PGN1AJoi2zuPmPJ2xraY1xnSP4dEvNjg8bMhgEhLQfC7aFc
}

- (void)ETHMethod
{
    //1.在需要使用ETH的地方 导入  HSEther.h
    //2.提供助记词,KeyStore,私钥导入钱包的方法
    //3.转账web3j配置地址改成自己后台的即可
    
    //创建钱包
    [HSEther hs_createWithPwd:nil block:^(NSString *address, NSString *keyStore, NSString *mnemonicPhrase, NSString *privateKey) {
        NSLog(@"address:%@,mnemonicPhrase:%@,privateKey:%@",address,mnemonicPhrase,privateKey);
    }];
    
    //导入钱包
    [HSEther hs_inportMnemonics:@"助记词" pwd:nil block:^(NSString *address, NSString *keyStore, NSString *mnemonicPhrase, NSString *privateKey, BOOL suc, HSWalletError error) {
        
    }];
    
    
}


@end
