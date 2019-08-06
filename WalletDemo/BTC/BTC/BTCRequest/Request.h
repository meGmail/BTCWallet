//
//  Request.h
//  BTCDemo
//
//  Created by iOS on 2018/7/20.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

typedef NS_ENUM(NSInteger, RequestState) {
    RequestStateSuccess                  = 1,//成功
    RequestStateFail                     = 0,//失败
    
    RequestStateFailTimedOut             = -1001,//超时
    RequestStateNotConnectedToInternet   = -1009,//无法连接到网络
    
    RequestStateOtherFail,//还没有定义失败原因
    RequestStateNone,//还没有定义的状态码
};


typedef void(^requestSuccess)(id responseBody);
typedef void(^requestFail)(RequestState requestType,NSString *errorMsg);

@interface Request : YTKRequest

///请求链接
@property (nonatomic, strong) NSString *urlStr;
///post or other
@property (nonatomic, assign) YTKRequestMethod method;
//参数
@property (nonatomic, strong) NSDictionary *parameter;
///已经使用过缓存
@property (nonatomic, assign) BOOL hadLoadCache;

/**
 请求

 @param success 成功
 @param failure 失败
 */
- (void)requestCompletionBlockWithSuccess:(requestSuccess)success
                                  failure:(requestFail)failure;


/**
 请求

 @param success 成功
 @param failure 失败
 @param useCache 是否使用缓存 YES 使用缓存
 */
- (void)requestCompletionBlockWithSuccess:(requestSuccess)success
                                  failure:(requestFail)failure
                                 useCache:(BOOL)useCache;


+ (BOOL)resultIsInvalid:(id)responseObject;

@end
