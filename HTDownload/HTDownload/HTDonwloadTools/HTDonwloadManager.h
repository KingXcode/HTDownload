//
//  HTDonwloadManager.h
//  HTDownload
//
//  Created by King on 2017/3/17.
//  Copyright © 2017年 King. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

/*！定义请求类型的枚举 */
typedef NS_ENUM(NSUInteger, HTHttpRequestType)
{
    /*! get请求 */
    HTHttpRequestTypeGet = 0,
    /*! post请求 */
    HTHttpRequestTypePost,
    /*! put请求 */
    HTHttpRequestTypePut,
    /*! delete请求 */
    HTHttpRequestTypeDelete
};

typedef void(^HTResponseSuccess) (id response);
typedef void(^HTResponseFail)    (NSError *error);
typedef void(^HTDownloadProgress)(int64_t bytesProgress, int64_t totalBytesProgress);



@interface HTDonwloadManager : NSObject


/**
 下载工具管理器初始化工具
 */
+(instancetype)shareInstance;








@property (nonatomic,strong) AFHTTPSessionManager *sharedAFManager;
@property (nonatomic,strong) NSMutableArray       *task;



/*! 和后台协商请求头需要添加数据*/
/*! 请保证数据的正确性        */
+(void)addHTTPHeaderField:(NSString *)field WithValue:(NSString *)value;
-(void)addHTTPHeaderField:(NSString *)field WithValue:(NSString *)value;

/*!
 *  网络请求的实例方法
 *
 *  @param type         get / post / put / delete
 *  @param urlString    请求的地址
 *  @param parameters    请求的参数
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 */
+ (NSURLSessionTask *)requestWithType:(HTHttpRequestType)type
                            urlString:(NSString *)urlString
                           parameters:(NSDictionary *)parameters
                         successBlock:(HTResponseSuccess)successBlock
                         failureBlock:(HTResponseFail)failureBlock;
- (NSURLSessionTask *)requestWithType:(HTHttpRequestType)type
                            urlString:(NSString *)urlString
                           parameters:(NSDictionary *)parameters
                         successBlock:(HTResponseSuccess)successBlock
                         failureBlock:(HTResponseFail)failureBlock;


/*!
 *  取消所有 Http 请求
 */
+ (void)cancelAllRequest;
- (void)cancelAllRequest;
/*!
 *  取消指定 URL 的 Http 请求
 */
+ (void)cancelRequestWithURL:(NSString *)URL;
- (void)cancelRequestWithURL:(NSString *)URL;

@end
