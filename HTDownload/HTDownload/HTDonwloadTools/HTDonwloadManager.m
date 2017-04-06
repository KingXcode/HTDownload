//
//  HTDonwloadManager.m
//  HTDownload
//
//  Created by King on 2017/3/17.
//  Copyright © 2017年 King. All rights reserved.
//

#import "HTDonwloadManager.h"


#define defaultTimeOutInterval 30   //超时时间
#define HTWeak  __weak __typeof(self) weakSelf = self;



@interface HTDonwloadManager ()<NSCopying,NSMutableCopying>


@end

@implementation HTDonwloadManager

+(void)load
{
    [super load];
    [HTDonwloadManager shareInstance];
}

static HTDonwloadManager *instance = nil;
+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL]init];
    });
    return instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [HTDonwloadManager shareInstance];
}

-(id)copyWithZone:(NSZone *)zone
{
    return [HTDonwloadManager shareInstance];
}

-(id)mutableCopyWithZone:(NSZone *)zone
{
    return [HTDonwloadManager shareInstance];
}


-(NSMutableArray *)task
{
    if (_task == nil) {
        _task = [NSMutableArray array];
    }
    return _task;
}


-(AFHTTPSessionManager *)sharedAFManager
{
    if (_sharedAFManager == nil) {
        
        _sharedAFManager = [AFHTTPSessionManager manager];
        
        _sharedAFManager.requestSerializer.timeoutInterval = defaultTimeOutInterval;
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        //默认的缓存策略
        _sharedAFManager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        
        
        
        
        /* 设置请求服务器数类型式为 json */
        /*!
         根据服务器的设定不同还可以设置：
         json：[AFJSONRequestSerializer serializer](常用)
         http：[AFHTTPRequestSerializer serializer]
         */
        AFJSONRequestSerializer *request = [AFJSONRequestSerializer serializer];
        _sharedAFManager.requestSerializer = request;
        
        
        /*! 设置返回数据类型为 json, 分别设置请求以及相应的序列化器 */
        /*!
         根据服务器的设定不同还可以设置：
         json：[AFJSONResponseSerializer serializer](常用)
         http：[AFHTTPResponseSerializer serializer]
         */
        AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
        response.removesKeysWithNullValues = YES;
        _sharedAFManager.responseSerializer = response;
        
        [_sharedAFManager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
        
        /*! 设置响应数据的基本类型 */
        _sharedAFManager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"application/json",
                              @"text/json",
                              @"text/javascript",
                              @"text/html",
                              @"text/css",
                              @"text/xml",
                              @"text/plain",
                              @"application/javascript",
                              @"image/*",
                              nil];
        
    }
    return _sharedAFManager;
}


/*! 和后台协商请求头需要添加数据*/
/*! 请保证数据的正确性        */
+(void)addHTTPHeaderField:(NSString *)field WithValue:(NSString *)value
{
    [[HTDonwloadManager shareInstance] addHTTPHeaderField:field WithValue:value];
}
-(void)addHTTPHeaderField:(NSString *)field WithValue:(NSString *)value
{
    [self.sharedAFManager.requestSerializer setValue:value forHTTPHeaderField:field];
}



#pragma mark - 网络请求的类方法 --- get / post / put / delete
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
                            failureBlock:(HTResponseFail)failureBlock
{
    
    return [[HTDonwloadManager shareInstance] requestWithType:type
                                                    urlString:urlString
                                                   parameters:parameters
                                                 successBlock:successBlock
                                                 failureBlock:failureBlock];
    
}
- (NSURLSessionTask *)requestWithType:(HTHttpRequestType)type
                               urlString:(NSString *)urlString
                              parameters:(NSDictionary *)parameters
                            successBlock:(HTResponseSuccess)successBlock
                            failureBlock:(HTResponseFail)failureBlock
{
    if (urlString == nil)
    {
        return nil;
    }
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];

    NSString *requestType;
    switch (type) {
        case 0:
            requestType = @"Get";
            break;
        case 1:
            requestType = @"Post";
            break;
        case 2:
            requestType = @"Put";
            break;
        case 3:
            requestType = @"Delete";
            break;
            
        default:
            break;
    }
    
    NSLog(@"******************** 请求参数 ***************************");
    NSLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",[self sharedAFManager].requestSerializer.HTTPRequestHeaders, requestType, URLString, parameters);
    NSLog(@"********************************************************");
    
    HTWeak
    NSURLSessionTask *sessionTask = nil;
    if (type == HTHttpRequestTypeGet) {
        
        sessionTask = [self.sharedAFManager GET:URLString
                                     parameters:parameters
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            
                                            if (successBlock) {
                                                successBlock(responseObject);
                                            }
                                            
                                            [weakSelf.task removeObject:sessionTask];
                                            
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                         
                                            if (failureBlock)
                                            {
                                                failureBlock(error);
                                            }
                                            [weakSelf.task removeObject:sessionTask];

                                        }];
        
        
    }else if (type == HTHttpRequestTypePost)
    {
        sessionTask = [self.sharedAFManager POST:URLString
                                      parameters:parameters
                                         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            
                                             if (successBlock) {
                                                 successBlock(responseObject);
                                             }
                                             
                                             [weakSelf.task removeObject:sessionTask];
                                             
                                         }
                                         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
                                             if (failureBlock)
                                             {
                                                 failureBlock(error);
                                             }
                                             [weakSelf.task removeObject:sessionTask];
                                             
                                         }];
        
    }else if (type == HTHttpRequestTypePut)
    {
        
        sessionTask = [self.sharedAFManager PUT:URLString
                                     parameters:parameters
                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            
                                            if (successBlock) {
                                                successBlock(responseObject);
                                            }
                                            
                                            [weakSelf.task removeObject:sessionTask];
                                            
                                        }
                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                            
                                            if (failureBlock)
                                            {
                                                failureBlock(error);
                                            }
                                            [weakSelf.task removeObject:sessionTask];
                                            
                                        }];
        
        
    }else if (type == HTHttpRequestTypeDelete)
    {
        sessionTask = [self.sharedAFManager DELETE:URLString
                                        parameters:parameters
                                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            
                                               if (successBlock) {
                                                   successBlock(responseObject);
                                               }
                                               
                                               [weakSelf.task removeObject:sessionTask];
                                               
                                           }
                                           failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
                                               if (failureBlock)
                                               {
                                                   failureBlock(error);
                                               }
                                               [weakSelf.task removeObject:sessionTask];
                                               
                                           }];
    }
    
    if (sessionTask)
    {
        [weakSelf.task addObject:sessionTask];
    }
    
    return sessionTask;
}



#pragma mark - ***** 文件下载   未实现
/*!
 *  文件下载
 *
 *  @param parameters   文件下载预留参数---视具体情况而定 可移除
 *  @param savePath     下载文件保存路径
 *  @param urlString        请求的url
 *  @param successBlock 下载文件成功的回调
 *  @param failureBlock 下载文件失败的回调
 *  @param progress     下载文件的进度显示
 */
- (NSURLSessionTask *)ba_downLoadFileWithUrlString:(NSString *)urlString
                                        parameters:(NSDictionary *)parameters
                                          savaPath:(NSString *)savePath
                                      successBlock:(HTResponseSuccess)successBlock
                                      failureBlock:(HTResponseFail)failureBlock
                                  downLoadProgress:(HTDownloadProgress)progress
{
    if (urlString == nil)
    {
        return nil;
    }
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];

    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSLog(@"******************** 请求参数 ***************************");
    NSLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",[self sharedAFManager].requestSerializer.HTTPRequestHeaders, @"download",URLString, parameters);
    NSLog(@"********************************************************");
    
    
    NSURLSessionTask *sessionTask = nil;
    

 
    return sessionTask;
}




#pragma mark - 取消 Http 请求
+ (void)cancelAllRequest
{
    [[HTDonwloadManager shareInstance] cancelAllRequest];
}

+ (void)cancelRequestWithURL:(NSString *)URL
{
    [[HTDonwloadManager shareInstance] cancelRequestWithURL:URL];
}

/*!
 *  取消所有 Http 请求
 */
- (void)cancelAllRequest
{
    // 锁操作
    @synchronized(self)
    {
        [self.task enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [self.task removeAllObjects];
    }
}

/*!
 *  取消指定 URL 的 Http 请求
 */
- (void)cancelRequestWithURL:(NSString *)URL
{
    if (!URL)
    {
        return;
    }
    @synchronized (self)
    {
        [self.task enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL])
            {
                [task cancel];
                [self.task removeObject:task];
                *stop = YES;
            }
        }];
    }
}


#pragma mark - url 中文格式化
- (NSString *)strUTF8Encoding:(NSString *)str
{
    /*! ios9适配的话 打开第一个 */
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0)
    {
        return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    }
    else
    {
        return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
}

@end
