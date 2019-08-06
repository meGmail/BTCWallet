//
//  Request.m
//  BTCDemo
//
//  Created by iOS on 2018/7/20.
//  Copyright © 2018年 iOS. All rights reserved.
//

#import "Request.h"


@implementation Request

- (instancetype)init {
    if (self = [super init]) {
        self.method = YTKRequestMethodPOST;
    }
    return self;
}

#pragma mark - 请求地址
- (NSString *)baseUrl {
    return @"";
}

///请求超时
- (NSTimeInterval)requestTimeoutInterval {
    return 10.f;
}

//缓存时间<使用默认的start，在缓存周期内并没有真正发起请求>
- (NSInteger)cacheTimeInSeconds
{
    return -1;
}


//请求参数
- (id)requestArgument {
    return self.parameter?:@{};
}

- (NSString *)requestUrl {
    return self.urlStr?:@"";
}

- (YTKRequestMethod)requestMethod {
    return self.method;
}


- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}

- (void)requestCompletionBlockWithSuccess:(requestSuccess)success failure:(requestFail)failure {
    [self requestCompletionBlockWithSuccess:success failure:failure useCache:NO];
}

- (void)requestCompletionBlockWithSuccess:(requestSuccess)success failure:(requestFail)failure useCache:(BOOL)useCache {
    if ([self isExecuting]) {
        [[YTKNetworkAgent sharedAgent] cancelRequest:self];
    }
    
    if (useCache && [self loadCacheWithError:nil] && !self.hadLoadCache) {
        [self dealRequest:self success:success failure:nil];
    }

    __weak typeof(self) weakSelf = self;
    [self setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        __strong typeof(self) strongSelf = weakSelf;
        if (request.responseObject) {
            strongSelf.hadLoadCache = YES;
        }
        [strongSelf dealRequest:request success:success failure:failure];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSString *errStr = nil;
        NSError *error = request.error;
        NSInteger code = error.code;
        switch (code) {
            case RequestStateFailTimedOut: {
                if (failure) {
                    failure(RequestStateFailTimedOut,errStr);
                }
            }
                break;
            case RequestStateNotConnectedToInternet: {
                if (failure) {
                    failure(RequestStateNotConnectedToInternet,errStr);
                }
            }
                break;
            default: {
                if (failure) {
                    failure(RequestStateOtherFail,errStr);
                }
            }
                break;
        }
    }];
    
    [self startWithoutCache];
}



- (void)dealRequest:(YTKBaseRequest *)request success:(requestSuccess)success failure:(requestFail)failure {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self saveResponseDataToCacheFile:request.responseData];
    });
    success(request.responseJSONObject);
}

- (BOOL)statusCodeValidator {
    return YES;
}


+ (BOOL)resultIsInvalid:(id)responseObject {
    return responseObject[@"error"] || !responseObject[@"result"] || [responseObject[@"result"] isKindOfClass:[NSNull class]];
}

@end
