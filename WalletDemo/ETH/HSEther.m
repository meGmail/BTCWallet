//
//  HSEther.m
//  HSEther
//
//  Created by 侯帅 on 2018/4/20.
//  Copyright © 2018年 com.houshuai. All rights reserved.
//

#import "HSEther.h"
#import <ethers/Account.h>
#import "Signer.h"
#import "CloudKeychainSigner.h"
#import <ethers/SecureData.h>
#import <ethers/EtherscanProvider.h>//查询代币余额
#import "Wallet.h"
#import <ethers/JsonRpcProvider.h>
#import <ethers/InfuraProvider.h>

@interface HSEther()
{
    ArrayPromise *_addressInspectionPromise;
    BigNumber *_fuzzyEstimate;
    BigNumber *_gasPriceEstimate;
}
//转账相关
@property (nonatomic, readonly) Transaction *transaction;

@property (nonatomic, readonly) Signer *signer;

@property (nonatomic, copy) NSString *address, *count, *remark, *gasPrice, *gasLimit, *password;

@property (nonatomic, assign) BOOL feeReady;

@property (nonatomic, strong) BigNumber *gasEstimate;

@end

@implementation HSEther

+(void)hs_createWithPwd:(NSString *)pwd block:(void(^)(NSString *address,NSString *keyStore,NSString *mnemonicPhrase,NSString *privateKey))block{
    Account *account = [Account randomMnemonicAccount];
    [account encryptSecretStorageJSON:pwd callback:^(NSString *json) {
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        //地址
        NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
        //私钥
        NSString *privateKeyStr = [SecureData dataToHexString:account.privateKey];
        //助记词account.mnemonicPhrase
        //助记keyStore 就是json字符串
        
        block(addressStr,json,account.mnemonicPhrase,privateKeyStr);
    }];
}

+(void)hs_inportMnemonics:(NSString *)mnemonics pwd:(NSString *)pwd block:(void(^)(NSString *address,NSString *keyStore,NSString *mnemonicPhrase,NSString *privateKey,BOOL suc,HSWalletError error))block{
    if (mnemonics.length < 1) {
        block(@"",@"",@"",@"",NO,HSWalletErrorMnemonicsLength);
        return;
    }
//    if (pwd.length < 1) {
//        block(@"",@"",@"",@"",NO,HSWalletErrorPwdLength);
//        return;
//    }
    NSArray *arrayMnemonics = [mnemonics componentsSeparatedByString:@" "];
    if (arrayMnemonics.count != 12) {
        block(@"",@"",@"",@"",NO,HSWalletErrorMnemonicsCount);
        return;
    }
    for (NSString *m in arrayMnemonics) {
        if (![Account isValidMnemonicWord:m]) {
            NSString *msg = [NSString stringWithFormat:@"助记词 %@ 有误", m];
            NSLog(@"%@",msg);
            block(@"",@"",@"",@"",NO,HSWalletErrorMnemonicsValidWord);
            return;
        }
    }
    if (![Account isValidMnemonicPhrase:mnemonics]) {
        block(@"",@"",@"",@"",NO,HSWalletErrorMnemonicsValidPhrase);
        return;
    }
    //1 创建
    Account *account = [Account accountWithMnemonicPhrase:mnemonics];
//    if (pwd == nil || [pwd isEqualToString:@""]) {
//        block(account.address.checksumAddress,@"没有keystore，请传入密码即可生成私钥",account.mnemonicPhrase,@"没有私钥，请传入密码即可生成私钥",YES,HSWalletImportMnemonicsSuc);
//    }else{
        //2 生成keystore
        [account encryptSecretStorageJSON:pwd callback:^(NSString *json) {
            NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            //3 获取地址 （account.address也可以）
            NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
            //4 获取私钥
            NSString *privateKeyStr = [SecureData dataToHexString:account.privateKey];
            //5 获取助记词 account.mnemonicPhrase
            //6 获取keyStore 就是json字符串
            //7 block 回调
            block(addressStr,json,account.mnemonicPhrase,privateKeyStr,YES,HSWalletImportMnemonicsSuc);
            
        }];
//    }
    
}

+(void)hs_importKeyStore:(NSString *)keyStore
                     pwd:(NSString *)pwd
                   block:(void(^)(NSString *address,NSString *keyStore,NSString *mnemonicPhrase,NSString *privateKey,BOOL suc,HSWalletError error))block{
//    if (pwd.length < 1) {
//        block(@"",@"",@"",@"",NO,HSWalletErrorPwdLength);
//        return;
//    }
    if (keyStore.length < 1) {
        block(@"",@"",@"",@"",NO,HSWalletErrorKeyStoreLength);
        return;
    }
    //1 解密keystory
    [Account decryptSecretStorageJSON:keyStore password:pwd callback:^(Account *account, NSError *NSError) {
        if (NSError) {
            //2.1 解密失败
            NSLog(@"keyStore解密失败%@",NSError.localizedDescription);
            block(@"",@"",@"",@"",NO,HSWalletErrorKeyStoreValid);
            return ;
        }else{
//            if (pwd == nil || [pwd isEqualToString:@""]) {
//                block(account.address.checksumAddress,@"没有keystore，请传入密码即可生成私钥",account.mnemonicPhrase,@"没有私钥，请传入密码即可生成私钥",YES,HSWalletImportKeyStoreSuc);
//            }else{
                //2.2 解密成功
                [account encryptSecretStorageJSON:pwd callback:^(NSString *json) {
                    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:nil];
                    //3 获取地址 （account.address也可以）
                    NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
                    //4 获取私钥
                    NSString *privateKeyStr = [SecureData dataToHexString:account.privateKey];
                    //5 获取助记词 account.mnemonicPhrase
                    //6 获取keyStore 就是json字符串
                    //7 block 回调
                    block(addressStr,json,account.mnemonicPhrase,privateKeyStr,YES,HSWalletImportKeyStoreSuc);
                }];
//            }
        }
    }];
}

+(void)hs_importWalletForPrivateKey:(NSString *)privateKey
                                pwd:(NSString *)pwd
                              block:(void(^)(NSString *address,NSString *keyStore,NSString *mnemonicPhrase,NSString *privateKey,BOOL suc,HSWalletError error))block{
    if (privateKey.length < 1) {
        block(@"",@"",@"",@"",NO,HSWalletErrorPrivateKeyLength);
        return;
    }
//    if (pwd.length < 1) {
//        block(@"",@"",@"",@"",NO,HSWalletErrorPwdLength);
//        return;
//    }
    //1 解密私钥
    Account *account = [Account accountWithPrivateKey:[SecureData hexStringToData:[privateKey hasPrefix:@"0x"]?privateKey:[@"0x" stringByAppendingString:privateKey]]];
    
    //2 生成keystore
    [account encryptSecretStorageJSON:pwd callback:^(NSString *json) {
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:nil];
        //3 获取地址 （account.address也可以）
        NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
        //4 获取私钥
        NSString *privateKeyStr = [SecureData dataToHexString:account.privateKey];
        //5 获取助记词 account.mnemonicPhrase
        //6 获取keyStore 就是json字符串
        //7 block 回调
        block(addressStr,json,account.mnemonicPhrase,privateKeyStr,YES,HSWalletImportPrivateKeySuc);
    }];
}


+(void)hs_getBalanceWithTokens:(NSArray<NSString *> *)arrayToken
                   withAddress:(NSString *)address
                         block:(void(^)(NSArray *arrayBanlance,BOOL suc))block{
    
    if (address.length != @"0x4f3B600378BD40b93B85DFd8A4aDf7c05E719672".length) {
        NSLog(@"%@ 地址错误",address);
        block([NSArray array],NO);
        return;
    }
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@{@"contractAddress":address,@"symbol":@"eth",@"type":@"eth"}];
    for (NSString *tokenStr in arrayToken) {
        [array addObject:@{@"contractAddress":tokenStr,@"symbol":@"",@"type":@"eth"}];
    }
    //全局搜索HSCoinListArrayM，只提供查询方式，可以自己根据需求封装
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"HSCoinListArrayM"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    EtherscanProvider *e = [[EtherscanProvider alloc]initWithChainId:ChainIdHomestead];
    Address *a = [Address addressWithString:address];
    [[e getTokenBalance:a] onCompletion:^(ArrayPromise *promise) {
        if (!promise.result || promise.error) {
            NSLog(@"%@ hs_getBalanceWithTokens 获取失败",address);
            
            block([NSArray array],NO);
        }else{
            NSMutableArray *arrayBalance = [NSMutableArray array];
            for (Erc20Token *obj in promise.value) {
                [arrayBalance addObject:obj.balance.decimalString];
            }
            block(arrayBalance,YES);
        }
    }];
    
}



//转账必读！！！！
//【 1】供3种方式  1 以太坊官方限流配置https://etherscan.io/apis   2 web3配置（找你们公司后台）  3 infura配置（https://infura.io）  本方式使用以太坊官方限流配置RCWEX6WYBXMJZHD5FD617NZ99TZADKBEDJ（这个是我侯帅的key，你们最好自己去申请）
// 【2】 转账前先弄清楚参数意义 see https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sendtransaction
//  【3】 转账签名方式 分为eth转账和 erc20（代币）转账，分别是不同的签名。
//【4】有任何问题 问我微信，我不是大神，你也不是菜鸟，我们是在交流，哈哈哈
//【5】自己自己再写钱包的时候，自己手里屯点币，上交易所就套现
//【6】虚拟货币投资有风险 自己需谨慎
// 【7】没什么说的了

//另外补充一下 18年9月
//a 钱包修改密码功能：就是把原来的钱包 私钥 助记词 拿过来，重新导入一次钱包，设置新的密码。
//b web3接口使用类 搜索JsonRpcProvider.h  ChainId为正式环境和测试环境选择枚举
//c infura接口使用类 搜索InfuraProvider.h  ChainId为正式环境和测试环境选择枚举
//d 助记词加密方式 ，全局搜索 “助记词加密方式这里参考” 汉子，我在那里打了注释
//e 交易记录，最好由你们公司后台提供接口，我这里提供一个第三方接口https://github.com/EverexIO/Ethplorer/wiki/ethplorer-api
//f 一定要理解： 不同代币 有不同的小数位数，要学会小数转换！！！！！！学会使用Payment BigNumber两个类进行小数处理！！！！
//g 代币转账，先仔细上网查询资料，再仔细走一遍转账流程，才能真正体会。特别是nonce gasPrice gasLimit等参数
//h imtoken收款二维码相关  研究Payment.m类


+(void)hs_sendToAssress:(NSString *)toAddress money:(NSString *)money tokenETH:(NSString *)tokenETH decimal:(NSString *)decimal currentKeyStore:(NSString *)keyStore pwd:(NSString *)pwd gasPrice:(NSString *)gasPrice gasLimit:(NSString *)gasLimit block:(void(^)(NSString *hashStr,BOOL suc,HSWalletError error))block{
    
    __block Account *a;
    //提供3种方式  1 以太坊官方限流配置   2 web3配置  3 infura配置  本方式使用以太坊官方限流配置RCWEX6WYBXMJZHD5FD617NZ99TZADKBEDJ
    //假如你要用 web3 你就新建
//    __block JsonRpcProvider *e = [[JsonRpcProvider alloc] initWithChainId:ChainIdRinkeby url:[NSURL URLWithString:@"http://192.168.10.133:8545"]];
    //同理 infura 用InfuraProvider.h类库新建即可
    __block InfuraProvider *e = [[InfuraProvider alloc] initWithChainId:ChainIdPrivate url:[NSURL URLWithString:@"http://192.168.10.133:8545"]];
//    __block EtherscanProvider *e = [[EtherscanProvider alloc]initWithChainId:ChainIdHomestead apiKey:@"RCWEX6WYBXMJZHD5FD617NZ99TZADKBEDJ"];
    
    
    
    NSData *jsonData = [keyStore dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    //地址
    __block NSString *addressStr = [NSString stringWithFormat:@"0x%@",dic[@"address"]];
    
    __block Transaction *transaction = [Transaction transactionWithFromAddress:[Address addressWithString:addressStr]];
    //
    //1 account自己解密
    
    NSLog(@"1 开始新建钱包");
    [Account decryptSecretStorageJSON:keyStore password:pwd callback:^(Account *account, NSError *NSError) {
        if (NSError == nil){
            a = account;
            NSLog(@"2 新建钱包成功 开始获取nonce");
            [[e getTransactionCount:transaction.fromAddress] onCompletion:^(IntegerPromise *pro) {
                if (pro.error != nil) {
                    NSLog(@"%@获取nonce失败",pro.error);
                    
                    block(@"",NO,HSWalletErrorNotNonce);
                }else{
                    
                    NSLog(@"3 获取nonce成功 值为%ld",pro.value);
                    transaction.nonce = pro.value;
                    
                    
                    
                    NSLog(@"4 开始获取gasPrice");
                    [[e getGasPrice] onCompletion:^(BigNumberPromise *proGasPrice) {
                        if (proGasPrice.error == nil) {
                            
                            NSLog(@"5 获取gasPrice成功 值为%@",proGasPrice.value.decimalString);
                            
                            if (gasPrice == nil) {
                                
                                transaction.gasPrice = proGasPrice.value;
                            }else{
                                NSLog(@"手动设置了gasPrice = %@",gasPrice);
                                transaction.gasPrice = [BigNumber bigNumberWithDecimalString:gasPrice];
//                                transaction.gasPrice = [[BigNumber bigNumberWithDecimalString:gasPrice] mul:[BigNumber bigNumberWithDecimalString:@"1000000000"]];
                            }
                            
                            
                            transaction.chainId = e.chainId;
                            
                            transaction.toAddress = [Address addressWithString:toAddress];
                            
                            //转账金额  原来的方法会越界NSInteger  建议使用Payment转换后 再用BigNumber里面的加减乘除运算方法
                            //                            NSInteger i = money.doubleValue * pow(10.0, decimal.integerValue);
                            //                            BigNumber *b = [BigNumber bigNumberWithInteger:i];
                            //                            transaction.value = b;
                            
                            NSInteger new_decimal = decimal.length - 1;
                            transaction.value = [[Payment parseEther:money] div:[BigNumber bigNumberWithInteger:pow(10.0, new_decimal)]];
                            
                            
                            
                            if (tokenETH == nil) {//默认eth
                                
                                if (gasLimit == nil) {
                                    
                                    transaction.gasLimit = [BigNumber bigNumberWithDecimalString:@"21000"];
                                }else{
                                    
                                    NSLog(@"手动设置了gasLimit = %@",gasLimit);
                                    transaction.gasLimit = [BigNumber bigNumberWithDecimalString:gasLimit];
                                }
                                
                                
                                transaction.data = [SecureData secureDataWithCapacity:0].data;
                                
                            }else{
                                
                                if (gasLimit == nil) {
                                    
                                    transaction.gasLimit = [BigNumber bigNumberWithDecimalString:@"60000"];
                                }else{
                                    
                                    NSLog(@"手动设置了gasLimit = %@",gasLimit);
                                    transaction.gasLimit = [BigNumber bigNumberWithDecimalString:gasLimit];
                                }
                                SecureData *data = [SecureData secureDataWithCapacity:68];
                                [data appendData:[SecureData hexStringToData:@"0xa9059cbb"]];
                                
                                NSData *dataAddress = transaction.toAddress.data;//转入地址（真实代币转入地址添加到data里面）
                                for (int i=0; i < 32 - dataAddress.length; i++) {
                                    [data appendByte:'\0'];
                                }
                                [data appendData:dataAddress];
                                
                                NSData *valueData = transaction.value.data;//真实代币交易数量添加到data里面
                                for (int i=0; i < 32 - valueData.length; i++) {
                                    [data appendByte:'\0'];
                                }
                                [data appendData:valueData];
                                
                                transaction.value = [BigNumber constantZero];
                                transaction.data = data.data;
                                transaction.toAddress = [Address addressWithString:tokenETH];//合约地址（代币交易 转入地址为合约地址）
                                
                                
                            }
                            
                            
                            
                            
                            
                            
                            //签名
                            [a sign:transaction];
                            //发送
                            NSData *signedTransaction = [transaction serialize];
                            
                            NSLog(@"6 开始转账");
                            [[e sendTransaction:signedTransaction] onCompletion:^(HashPromise *pro) {
                                
                                NSLog(@"CloudKeychainSigner: Sent - signed=%@ hash=%@ error=%@", signedTransaction, pro.value, pro.error);
                                
                                if (pro.error == nil){
                                    NSLog(@"\n---------------【生成转账交易成功！！！！】--------------\n哈希值 = %@\n",transaction.transactionHash.hexString);
                                    NSLog(@" 7成功 哈希值 =  %@",pro.value.hexString);
                                    
                                    block(pro.value.hexString,YES,HSWalletSucSend);
                                    [[e getTransaction:pro.value]onCompletion:^(TransactionInfoPromise *info) {
                                        if (info.error == nil) {
                                            NSLog(@"===%@",info.value.transactionHash.hexString);
                                        }else{
                                            
                                            NSLog(@" 9查询哈希%@失败 %@",pro.value.hexString,pro.error);
                                        }
                                    }];
                                    
                                }else{
                                    NSLog(@" 8转账失败 %@",pro.error);
                                    block(@"",NO,HSWalletErrorSend);
                                }
                            }];
                        }else{
                            
                            block(@"",NO,HSWalletErrorNotGasPrice);
                        }
                    }];
                    
                    
                    
                }
            }];
            
            
            
        }else{
            NSLog(@"密码错误%@",NSError);
            block(@"",NO,HSWalletErrorPWD);
        }
    }];
}



@end
