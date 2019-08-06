//
//  BTCAccount.m
//  BTCDemo
//
//  Created by iOS on 2019/4/8.
//  Copyright © 2019 iOS. All rights reserved.
//

#import "BTCAccount.h"
#import "CoreBitcoin.h"
#import "NSString+Bitcoin.h"
#import "BRBIP32Sequence.h"
#import "NSData+BTCData.h"
#import "BTCNodeManage.h"
#import "BTCApi.h"
#import "NSString+Category.h"

@interface BTCAccount ()

@property (nonatomic, strong) NSString *privateKey;
@property (nonatomic, strong) NSString *publicKey;
@property (nonatomic, strong) NSString *WIF;
@property (nonatomic, strong) BTCKey *btcKey;
@property (nonatomic, assign) BOOL segwit;

@end

@implementation BTCAccount

#pragma mark - 初始化
- (instancetype)initWithMnemonic:(NSString *)mnemonics isSegwit:(BOOL)segwit slot:(int)slot {
    if (self = [super init]) {
        _segwit = segwit;
        NSArray *mnemonicArray = [mnemonics componentsSeparatedByString:@" "];
        BTCMnemonic *btcMnemonic = [[BTCMnemonic alloc] initWithWords:mnemonicArray password:nil wordListType:BTCMnemonicWordListTypeEnglish];
        if (btcMnemonic) {
            BTCMnemonic *mnemonic = [[BTCMnemonic alloc] initWithWords:mnemonicArray password:nil wordListType:BTCMnemonicWordListTypeEnglish];
            BTCKeychain *masterKey = mnemonic.keychain;
            
            BOOL isMain = [BTCNodeManage mainOrTest];
            NSString *AccountPath;
            if (segwit) {
                if (isMain) {
                    AccountPath = @"m/49'/0'/0'";
                } else {
                    AccountPath = @"m/49'/1'/0'";
                }
            } else {
                if (isMain) {
                    AccountPath = @"m/44'/0'/0'";
                } else {
                    AccountPath = @"m/44'/1'/0'";
                }
            }
            NSString *BIP32Path = [NSString stringWithFormat:@"%@/0",AccountPath];
            _btcKey = [[masterKey derivedKeychainWithPath:BIP32Path] keyAtIndex:slot];
            
            //公钥
            _publicKey = [NSString hexWithData:_btcKey.publicKey];
            //私钥
            _privateKey = [_btcKey.privateKey hex];
            if (isMain) {
                _WIF = _btcKey.WIF;
            } else {
                _WIF = _btcKey.WIFTestnet;
            }
        }
    }
    return self;
}

- (instancetype)initWithPrivateKey:(NSString *)privateKey compressed:(BOOL)compressed isSegwit:(BOOL)segwit {
    if (self = [super init]) {
        _segwit = segwit;
        NSData *privateData = [privateKey hexToData];
        _btcKey = [[BTCKey alloc] initWithPrivateKey:privateData compressed:compressed];
        
        //公钥
        _publicKey = [NSString hexWithData:_btcKey.publicKey];
        //私钥
        _privateKey = privateKey;
        BOOL isMain = [BTCNodeManage mainOrTest];
        if (isMain) {
            _WIF = _btcKey.WIF;
        } else {
            _WIF = _btcKey.WIFTestnet;
        }
    }
    return self;
}

- (instancetype)initWithPrivateKey:(NSString *)privateKey isSegwit:(BOOL)segwit {
    return [self initWithPrivateKey:privateKey compressed:YES isSegwit:segwit];
}


- (instancetype)initWithWIF:(NSString *)WIF isSegwit:(BOOL)segwit {
    if (self = [super init]) {
        _segwit = segwit;
        _btcKey = [[BTCKey alloc] initWithWIF:WIF];
        //公钥
        _publicKey = [NSString hexWithData:_btcKey.publicKey];
        //私钥
        _privateKey = [_btcKey.privateKey hex];
        BOOL isMain = [BTCNodeManage mainOrTest];
        if (isMain) {
            _WIF = _btcKey.WIF;
        } else {
            _WIF = _btcKey.WIFTestnet;
        }
    }
    return self;
}

- (void)changeSegWit:(BOOL)segwit {
    _segwit = segwit;
}

- (NSString *)address {
    NSString *address;
    BOOL isMain = [BTCNodeManage mainOrTest];
    if (_segwit) {
        if (isMain) {
            address = _btcKey.witnessAddress.string;
        } else {
            address = _btcKey.witnessAddressTestnet.string;
        }
    } else {
        if (isMain) {
            address = _btcKey.address.string;
        } else {
            address = _btcKey.addressTestnet.string;
        }
    }
    return address;
}


+ (void)test1 {
    BTCAccount *account = [[BTCAccount alloc] initWithWIF:@"cUrUYQPFEQxpvFPZtErt1hFR8j9h7eUJMQ55qC8xeUmsxghqeUw6" isSegwit:NO];
    [account transactionTo:@"mhbQQZvbUMbkNZhtRSWFnfzPUnBbXR4RQq" amount:@"0.00000001" fee:@"30000" completion:^(NSString *txHash) {
        if (txHash) {
            NSLog(@"转账成功 - %@",txHash);
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[BTCNodeManage btcTradeDetailUrlWithTxId:txHash]]];
        }
    }];
}

+ (void)test2 {
    BTCAccount *account = [[BTCAccount alloc] initWithMnemonic:@"exile honey always mother trophy mouse seek scorpion mansion into record address" isSegwit:YES slot:0];
    [account transactionTo:@"2NDsFsAFwWQ6afPxsYNsL1kMRKd1C1rdrDX" amount:@"0.002" fee:@"0.001" completion:^(NSString *txHash) {
        if (txHash) {
            NSLog(@"转账成功 - %@",txHash);
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[BTCNodeManage btcTradeDetailUrlWithTxId:txHash]]];
        }
    }];

}

#pragma mark - omni转账
- (void)transactionTo:(NSString *)toAddress
                  fee:(NSString *)feeString
            omniValue:(NSString *)omniValue
               omniId:(NSString *)omniId
           completion:(void(^)(NSString *txHash))completion {
    [BTCApi unspentOutputsWithAddress:self.address completion:^(NSArray *array) {
        [self transactionTo:toAddress fee:feeString omniValue:omniValue omniId:omniId utxos:array completion:completion];
    }];
}

- (void)transactionTo:(NSString *)toAddress
                  fee:(NSString *)feeString
            omniValue:(NSString *)omniValue
               omniId:(NSString *)omniId
                utxos:(NSArray *)utxos
           completion:(void(^)(NSString *txHash))completion {
    long long fee = [NSDecimalNumber decimalNumberWithString:feeString].longLongValue;
    [self transactionTo:toAddress fee:fee omniValue:omniValue omniId:omniId utxos:utxos transactionCallBack:^(NSError *error, BTCTransaction *transaction) {
        [self pushTx:transaction completion:completion];
    }];
}

#pragma mark - 转账BTC
- (void)transactionTo:(NSString *)toAddress
               amount:(NSString *)amount
                  fee:(NSString *)feeString
           completion:(void(^)(NSString *txHash))completion {
    [BTCApi unspentOutputsWithAddress:self.address completion:^(NSArray *array) {
        [self transactionTo:toAddress amount:amount fee:feeString utxos:array completion:completion];
    }];
}

- (void)transactionTo:(NSString *)toAddress
               amount:(NSString *)amount
                  fee:(NSString *)feeString
                utxos:(NSArray *)utxos
           completion:(void(^)(NSString *txHash))completion {
    long long fee = [NSDecimalNumber decimalNumberWithString:feeString].longLongValue;
    [self transactionTo:toAddress amount:amount fee:fee utxos:utxos transactionCallBack:^(NSError *error, BTCTransaction *transaction) {
        [self pushTx:transaction completion:completion];
    }];
}

#pragma mark - 构造签名btc交易
- (void)transactionTo:(NSString *)toAddress
               amount:(NSString *)amountString
                  fee:(BTCAmount)fee
                utxos:(NSArray *)utxos
  transactionCallBack:(void(^)(NSError *error, BTCTransaction *transaction))transactionCallBack {
    long long amount = [NSString numberValueString:amountString decimal:@"8" isPositive:YES].longLongValue;
    [BTCAccount createTransactionFrom:self.address to:toAddress amount:amount fee:fee omniId:nil omniValue:nil utxos:utxos segwit:self.segwit transactionCallBack:^(NSError *error, BTCTransaction *transaction) {
        [BTCAccount signTransaction:transaction btcKey:self.btcKey segwit:self.segwit transactionCallBack:transactionCallBack];
    }];
}


#pragma mark - 构造签名Omni交易
- (void)transactionTo:(NSString *)toAddress
                  fee:(BTCAmount)fee
            omniValue:(NSString *)omniValue
               omniId:(NSString *)omniId
                utxos:(NSArray *)utxos
  transactionCallBack:(void(^)(NSError *error, BTCTransaction *transaction))transactionCallBack {
    [BTCAccount createTransactionFrom:self.address to:toAddress amount:546 fee:fee omniId:omniId omniValue:omniValue utxos:utxos segwit:self.segwit transactionCallBack:^(NSError *error, BTCTransaction *transaction) {
        [BTCAccount signTransaction:transaction btcKey:self.btcKey segwit:self.segwit transactionCallBack:transactionCallBack];
    }];
}

#pragma mark - 广播交易
- (void)pushTx:(BTCTransaction *)transaction completion:(void(^)(NSString *txHash))completion {
    if (transaction) {
        NSString *tx;
        if (self.segwit) {
            tx = transaction.hexWithWitness;
        } else {
            tx = transaction.hex;
        }
        [BTCApi pushTx:tx completion:^(NSString *hash) {
            if (hash) {
                if (completion) {
                    completion(hash);
                }
            } else {
                if (completion) {
                    completion(nil);
                }
            }
        }];
    } else {
        if (completion) {
            completion(nil);
        }
    }
}

#pragma mark - 预估手续费
+ (void)estimateFeeAddress:(NSString *)address
                    amount:(NSString *)amountString
                    isOmni:(BOOL)isOmni
                      utxo:(NSArray *)utxos
                completion:(void(^)(NSString *estimate))completion {
    __block NSInteger utxoCount = 0;
    __block NSInteger outputCount = isOmni ? 3 : 2;

    long long amount = 546;
    if (!isOmni) {
        amount = [NSString numberValueString:amountString decimal:@"8" isPositive:YES].longLongValue;
    }

    if (!utxos) {
        if (completion) {
            NSString *estimate = [NSString stringWithFormat:@"%@",@(148 * utxoCount + (34 * outputCount) + 10)];

            completion(estimate);
        }
        return;
    }
    
    if (utxos.count == 0) {
        if (completion) {
            NSString *estimate = [NSString stringWithFormat:@"%@",@(148 * utxoCount + (34 * outputCount) + 10)];
            
            completion(estimate);
        }
        return;
    }
    
    // Find enough outputs to spend the total amount.
    // Sort utxo in order of
    utxos = [utxos sortedArrayUsingComparator:^(BTCTransactionOutput *obj1, BTCTransactionOutput *obj2) {
        if (obj1.value > obj2.value) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    long total = 0;
    
    BTCAmount totalAmount = amount;
    for (BTCTransactionOutput* txout in utxos) {
        utxoCount += 1;
        total += txout.value;
        if (total >= totalAmount) {
            if (total == totalAmount) {
                utxoCount += 1;
            }
            break;
        }
    }
    
    if (completion) {
        NSString *estimate = [NSString stringWithFormat:@"%@",@(148 * utxoCount + (34 * outputCount) + 10)];
        
        completion(estimate);
    }
    
}


#pragma mark - 签名交易
+ (void)signTransaction:(BTCTransaction *)tx
                 btcKey:(BTCKey *)key
                 segwit:(BOOL)segwit
    transactionCallBack:(void(^)(NSError *error, BTCTransaction *transaction))transactionCallBack {
    if (!key) {
        if (transactionCallBack) {
            transactionCallBack([NSError errorWithDomain:@"com.seal.BTCDemo.errorDomain" code:100 userInfo:@{NSLocalizedDescriptionKey: @"error account"}], nil);
        }
        return;
    }
    NSError *error;
    // Sign all inputs. We now have both inputs and outputs defined, so we can sign the transaction.
    for (int i = 0; i < tx.inputs.count; i++) {
        // Normally, we have to find proper keys to sign this txin, but in this
        // example we already know that we use a single private key.
        BTCTransactionInput *txin = tx.inputs[i];
        
        BTCSignatureHashType hashtype = BTCSignatureHashTypeAll;
        
        NSData *hash;
        if (segwit) {
            NSString *scriptHex = [NSString stringWithFormat:@"1976a914%@88ac",BTCHash160(key.publicKey).hex];
            BTCScript *scriptCode = [[BTCScript alloc] initWithHex:scriptHex];
            hash = [tx signatureHashForScript:scriptCode forSegWit:segwit inputIndex:i hashType:hashtype error:&error];
        } else {
            BTCScript *txoutScript = txin.signatureScript;
            hash = [tx signatureHashForScript:txoutScript forSegWit:segwit inputIndex:i hashType:hashtype error:&error];
        }
        
        if (!hash) {
            if (transactionCallBack) {
                transactionCallBack(error, nil);
            }
            return;
        }
        NSData *signature = [key signatureForHash:hash hashType:hashtype];
        if (segwit) {
            txin.witnessData = [[[BTCScript new] appendData:signature] appendData:key.publicKey];
            txin.signatureScript = [[BTCScript new] appendScript:key.witnessRedeemScript];
        } else {
            BTCScript *signatureScript = [[[BTCScript new] appendData:signature] appendData:key.publicKey];
            txin.signatureScript = signatureScript;
        }
    }
    if (transactionCallBack) {
        transactionCallBack(nil, tx);
    }
}


#pragma mark - 构造交易
+ (void)createTransactionFrom:(NSString *)fromAddress
                           to:(NSString *)toAddress
                       amount:(BTCAmount)amount
                          fee:(BTCAmount)fee
                       omniId:(NSString *)omniId
                    omniValue:(NSString *)omniValue
                        utxos:(NSArray *)utxos
                       segwit:(BOOL)segwit
          transactionCallBack:(void(^)(NSError *error, BTCTransaction *transaction))transactionCallBack {
    NSError* error = nil;
    
    if (!utxos) {
        if (transactionCallBack) {
            transactionCallBack(error, nil);
        }
        return;
    }
    
    if (utxos.count == 0) {
        if (transactionCallBack) {
            transactionCallBack([NSError errorWithDomain:@"com.seal.BTCDemo.errorDomain" code:100 userInfo:@{NSLocalizedDescriptionKey: @"No free outputs to spend"}], nil);
        }
        return;
    }
    
    BTCAddress *from = [BTCAddress addressWithString:fromAddress];
    BTCAddress *to = [BTCAddress addressWithString:toAddress];
    
    // Find enough outputs to spend the total amount.
    BTCAmount totalAmount = amount + fee;
    
    // Sort utxo in order of
    utxos = [utxos sortedArrayUsingComparator:^(BTCTransactionOutput *obj1, BTCTransactionOutput *obj2) {
        if (obj1.value > obj2.value) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    NSMutableArray* txouts = [[NSMutableArray alloc] init];
    long total = 0;
    
    for (BTCTransactionOutput* txout in utxos) {
        [txouts addObject:txout];
        total += txout.value;
        if (total >= (totalAmount)) {
            break;
        }
    }
    
    if (total < totalAmount) {
        if (transactionCallBack) {
            transactionCallBack(error, nil);
        }
        return;
    }
    
    // Create a new transaction
    BTCTransaction *tx = [[BTCTransaction alloc] init];
    if (segwit) {
        tx.version = 2;
    }
    tx.fee = fee;
    BTCAmount spentCoins = 0;
    
    // Add all outputs as inputs
    
    for (BTCTransactionOutput *txout in txouts) {
        BTCTransactionInput *txin = [[BTCTransactionInput alloc] init];
        txin.isSegwit = segwit;
        txin.previousHash = txout.transactionHash;
        txin.previousIndex = txout.index;
        txin.signatureScript = txout.script;
//        txin.sequence = 4294967295;
        txin.value = txout.value;
        
        [tx addInput:txin];
        spentCoins += txout.value;
    }
    
    
    if (omniId != nil) {
        //构造omni交易
        BTCScript *omniScript = [[BTCScript alloc] init];
        [omniScript appendOpcode:OP_RETURN];
        long long omniAmount = [NSString numberValueString:omniValue decimal:@"8" isPositive:YES].longLongValue;
        NSString *omniHex = [NSString stringWithFormat:@"6f6d6e69%016x%016llx", [omniId intValue], omniAmount];
        [omniScript appendData:BTCDataFromHex(omniHex)];
        BTCTransactionOutput *omniOutput = [[BTCTransactionOutput alloc] initWithValue:0 script:omniScript];
        [tx addOutput:omniOutput];
    }
    
    // Add required outputs - payment and change
    BTCTransactionOutput* paymentOutput = [[BTCTransactionOutput alloc] initWithValue:amount address:to];
    [tx addOutput:paymentOutput];


    BTCTransactionOutput* changeOutput = [[BTCTransactionOutput alloc] initWithValue:(spentCoins - totalAmount) address:from];
    // Idea: deterministically-randomly choose which output goes first to improve privacy.
    if (changeOutput.value > 0) {
        [tx addOutput:changeOutput];
    }
    
    if (transactionCallBack) {
        transactionCallBack(nil, tx);
    }
}


@end


