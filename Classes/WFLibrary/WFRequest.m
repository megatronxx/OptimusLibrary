//
//  WFRequest.m
//  FrameWorkDemo
//
//  Created by 海莱 on 15/10/8.
//  Copyright (c) 2015年 海莱. All rights reserved.
//
#pragma mark - 网络交互的核心

#import "WFRequest.h"
#import "CacheGroup.h"
#import "WFFunctions.h"
#import "Pods.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define REQUEST_API                 @"requset_api"
#define REQUEST_PARAMETER           @"parameter"
#define REQUEST_BOUNDARY            @"AaB03x"
#define NET_CHECK_HOST_NAME         @"www.baidu.com"
#define WF_NET_FAIL                 @"郁闷，网络不能连接了"
#define WF_NET_TIMEOUT              @"网络不给力啊"
#define WF_NET_DATAERR              @"数据异常请稍后重试！"
#define WF_NET_LINKERR              @"链接出错请稍后重试！"
#define WF_NET_TIMEDURING           10 //网络请求允许的时间
#define kWFCacheKey                 @"hmsdev0"
/**
 *      定义几种网络出错类型
 *      404  数据异常
 *      11   断网状态
 *      12   连接出错
 */
//返回数据出错（格式、内容等）
#define NUM_NET_DATAERR             @"404"
#define NUM_NET_FAIL                @"11"
#define NUM_NET_CONNECT_FAIL        @"12"

///请求结果判定键
#define kRequestResult              @"success"

static NSString *requestKey;

@interface WFRequest ()
@property(nonatomic,strong)NSURL *requestURL;
@property(nonatomic,strong)NSURLConnection *connector;
@property(nonatomic,strong)NSMutableDictionary *requestParameters;
@property(nonatomic,strong)NSMutableData *receiveData;//服务器返回的数据
@property(nonatomic,assign)int requestType;//0 是纯文本 1 image/JPEG 2text/plain
@end

@implementation WFRequest
@synthesize isStopNetWorkActive,cacheType;
@synthesize connector,requestURL = _requestURL,requestParameters = _requestParameters,receiveData = _receiveData,requestType = _requestType;

///保存缓存
-(void)saveCache
{
    NSString *apiname = _requestURL.path.lastPathComponent;
//    NSLog(@"请求接口：%@",apiname);
    NSMutableDictionary *mrequestPara = [[NSMutableDictionary alloc]initWithDictionary:_requestParameters copyItems:YES];
    NSString *token = [mrequestPara objectForKey:@"token"] ?: @"";
    if (token.length > 0) {
        NSMutableArray *tokenms = [[NSMutableArray alloc]initWithArray:[token componentsSeparatedByString:@"_"]];
        NSString *randstr = tokenms[1];
        NSString *tokenf = [token stringByReplacingOccurrencesOfString:randstr withString:@"***"];
        [mrequestPara setObject:tokenf forKey:@"token"];
    }
//    NSLog(@"parameter : %@ and copy : %@",_requestParameters,mrequestPara.description);
    
    NSString *parameter = mrequestPara.description ?: @"no_para";
    //                    NSString *parameters = [AESCrypt decrypt:parameter password:@"hmsdev0"];
    NSString *path = [[WFCashManager sharedManager]getFilePath:parameter directory:apiname];
    
    NSString *resultstr = [[NSString alloc]initWithData:_receiveData encoding:NSUTF8StringEncoding];
    Class AESCrypt = NSClassFromString(@"AESCrypt");
//    NSString *encryptedResult = [AESCrypt encrypt:resultstr password:@"hmsdev0"];
    NSString *encryptedResult = [AESCrypt performSelector:@selector(encrypt:password:) withObject:resultstr withObject:kWFCacheKey];
    [encryptedResult writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

///获得缓存
-(NSMutableDictionary *)getCache
{
    NSMutableDictionary *cache = [[NSMutableDictionary alloc]init];
    NSString *apiname = _requestURL.path.lastPathComponent;
    NSMutableDictionary *mrequestPara = [[NSMutableDictionary alloc]initWithDictionary:_requestParameters copyItems:YES];
    NSString *token = [mrequestPara objectForKey:@"token"] ?: @"";
    if (token.length > 0) {
        NSMutableArray *tokenms = [[NSMutableArray alloc]initWithArray:[token componentsSeparatedByString:@"_"]];
        NSString *randstr = tokenms[1];
        NSString *tokenf = [token stringByReplacingOccurrencesOfString:randstr withString:@"***"];
        [mrequestPara setObject:tokenf forKey:@"token"];
    }
    NSString *parameter = mrequestPara.description ?: @"no_para";
    //        NSString *parameters = [AESCrypt decrypt:parameter password:@"hmsdev0"];
    NSString *path = [[WFCashManager sharedManager]getFilePath:parameter directory:apiname];
    
    NSString *encryptedData = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    Class AESCrypt = NSClassFromString(@"AESCrypt");
//    NSString *mmessage = [AESCrypt decrypt:encryptedData password:@"hmsdev0"];
    NSString *mmessage = [AESCrypt performSelector:@selector(decrypt:password:) withObject:encryptedData withObject:kWFCacheKey];
    NSDictionary *dic = [WFFunctions WFDictionaryWithJsonString:mmessage];
    NSMutableDictionary *resutl_cach = [NSMutableDictionary dictionaryWithDictionary:dic];
    cache = resutl_cach;
    return cache;
}

///处理单元素
-(NSString *)dealObject:(id)object
{
    NSString *result = @"";
    if (![WFFunctions WFStrCheckEmpty:object]) {
        result = [NSString stringWithFormat:@"%@",object];
    }
    return result;
}
///处理数组
-(NSMutableArray *)dealArray:(NSArray *)array
{
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    if (array.count > 0) {
        for (id object in array) {
            if (![WFFunctions WFStrCheckEmpty:object]) {
                ///Array
                if ([object isKindOfClass:[NSArray class]]) {
                    NSMutableArray *marr = [self dealArray:(NSArray *)object];
                    [mArray addObject:marr];
                }else if ([object isKindOfClass:[NSDictionary class]]) {
                    ///dictionary
                    NSMutableDictionary *mdic = [self dealDictionary:(NSDictionary *)object];
                    [mArray addObject:mdic];
                }else{
                    NSString *values = [self dealObject:object];
                    [mArray addObject:values];
                }
            }
        }
    }
    return mArray;
}
///处理字典
-(NSMutableDictionary *)dealDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc]init];
    
    ///处理坑爹的类型问题number null nil
    for (NSString *key in dictionary.allKeys) {
        id value = dictionary[key];
        if (![WFFunctions WFStrCheckEmpty:value]) {
            ///Array
            if ([value isKindOfClass:[NSArray class]]) {
                NSMutableArray *marr = [self dealArray:(NSArray *)value];
                [resultDictionary setObject:marr forKey:key];
            }else if ([value isKindOfClass:[NSDictionary class]]) {
                ///dictionary
                NSMutableDictionary *mdic = [self dealDictionary:(NSDictionary *)value];
                [resultDictionary setObject:mdic forKey:key];
            }else{
                NSString *values = [self dealObject:value];
                [resultDictionary setObject:values forKey:key];
            }
        }
    }
    return resultDictionary;
}
//
- (void)requestWithURL:(NSString *)url callBack:(requestHandler)handler parameter:(NSMutableDictionary *)paramters
{
    if (handler) {
        objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, &requestKey, handler, OBJC_ASSOCIATION_COPY);
    }
    
    if(!self.requestURL)
        self.requestURL = [NSURL URLWithString:url];
    if(!self.requestParameters)
        self.requestParameters = paramters;
    NSLog(@"普通请求 url:%@ parameter:%@",self.requestURL,self.requestParameters);
    
    if([WFRequest canConnectNet])
    {
        if (cacheType == WFRequestCachePriorShow) {
            ///优先展示缓存
            NSMutableDictionary *resutl_cach = [self getCache];
            //返回数据
            requestHandler handler = objc_getAssociatedObject(self, &requestKey);
            handler(resutl_cach);
        }
        //
        self.requestType = [self getRequestType:_requestParameters];
        NSMutableURLRequest* theRequest = [[NSMutableURLRequest alloc] initWithURL:_requestURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:WF_NET_TIMEDURING];
        if(0 == _requestType)
        {
            [theRequest setHTTPMethod:@"POST"];
            NSData *postData = [self getPostData];
            [theRequest setHTTPBody:postData];
            [theRequest setValue:[NSString stringWithFormat:@"%lu",(unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
        }
        if(1 == _requestType)
        {
            [theRequest setHTTPMethod:@"POST"];
            [theRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", REQUEST_BOUNDARY]forHTTPHeaderField:@"Content-Type"];
            [theRequest setHTTPBody:[self getPostData]];
        }
        [self openConnector:theRequest];
    }
    else
    {
        if (cacheType == WFRequestCacheTypeNone) {
            ///不设置缓存
            NSDictionary *dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",NUM_NET_FAIL,WF_NET_FAIL, nil] forKeys:[NSArray arrayWithObjects:kRequestResult,@"status",@"msg", nil]];
            requestHandler handler = objc_getAssociatedObject(self, &requestKey);
            handler(dic);
        }else{
            NSMutableDictionary *resutl_cach = [self getCache];
            //返回数据
            requestHandler handler = objc_getAssociatedObject(self, &requestKey);
            handler(resutl_cach);
        }
    }
}

- (void)requestWithAudioURL:(NSString *)url callBack:(requestHandler)handler parameter:(NSMutableDictionary *)paramters
{
    if (handler) {
        objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, &requestKey, handler, OBJC_ASSOCIATION_COPY);
    }
    
    if(!self.requestURL)
        self.requestURL = [NSURL URLWithString:url];
    if(!self.requestParameters)
        self.requestParameters = paramters;
    NSLog(@"多媒体请求 url:%@ parameter:%@",self.requestURL,self.requestParameters);
    
    if([WFRequest canConnectNet])
    {
        if (cacheType == WFRequestCachePriorShow) {
            ///优先展示缓存
            NSMutableDictionary *resutl_cach = [self getCache];
            //返回数据
            requestHandler handler = objc_getAssociatedObject(self, &requestKey);
            handler(resutl_cach);
        }
        //
        NSMutableURLRequest* theRequest = [[NSMutableURLRequest alloc] initWithURL:_requestURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:WF_NET_TIMEDURING];
        [theRequest setHTTPMethod:@"POST"];
        [theRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", REQUEST_BOUNDARY]forHTTPHeaderField:@"Content-Type"];
        [theRequest setHTTPBody:[self getAudioPostData]];
        [self openConnector:theRequest];
    }
    else
    {
        if (cacheType == WFRequestCacheTypeNone) {
            ///不设置缓存
            NSDictionary *dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",NUM_NET_FAIL,WF_NET_FAIL, nil] forKeys:[NSArray arrayWithObjects:kRequestResult,@"status",@"msg", nil]];
            requestHandler handler = objc_getAssociatedObject(self, &requestKey);
            handler(dic);
        }else{
            NSMutableDictionary *resutl_cach = [self getCache];
            //返回数据
            requestHandler handler = objc_getAssociatedObject(self, &requestKey);
            handler(resutl_cach);
        }
    }
}

//手动关闭连接
- (void)closeConnect
{
    if(connector)
    {
        [connector cancel];connector = nil;
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

//打开连接请求
- (void)openConnector:(NSMutableURLRequest*)request
{
    //追加user_agent
    NSString *user_agent = [[NSUserDefaults standardUserDefaults]objectForKey:kUserAgent];
    [request setValue:user_agent forHTTPHeaderField:@"User-Agent"];
    NSLog(@"%@",user_agent);
    //"正在连接"状态打开
    connector = [NSURLConnection connectionWithRequest:request delegate:self];
    
//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
//        NSLog(@"cookie --- %@", cookie);
//    }
    
//    NSURL *url = request.URL;
//    if (url) {
//        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
//        for (int i = 0; i < [cookies count]; i++) {
//            NSHTTPCookie *cookie = (NSHTTPCookie *)[cookies objectAtIndex:i];
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//        }
//    }
    
    if (connector)
    {
        if(!isStopNetWorkActive)
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        self.receiveData = [[NSMutableData alloc] init];
    }
    else
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:NUM_NET_CONNECT_FAIL,WF_NET_LINKERR, nil] forKeys:[NSArray arrayWithObjects:@"status",@"msg", nil]];
        requestHandler handler = objc_getAssociatedObject(self, &requestKey);
        handler(dic);
        
        [self closeConnect];
    }
}

//检测网络状态
+ (BOOL)canConnectNet
{
    Class Reachability = NSClassFromString(@"Reachability");
//    Reachability *reache = [Reachability reachabilityWithHostName:NET_CHECK_HOST_NAME];
    id reache = [Reachability performSelector:@selector(reachabilityWithHostName:) withObject:NET_CHECK_HOST_NAME];
    
//    switch ([reache currentReachabilityStatus])
    /**
     *      NotReachable = 0
     *      ReachableViaWiFi = 2
     *      ReachableViaWWAN = 1
     */
    NSInteger net_status = [reache performSelector:@selector(currentReachabilityStatus)];
    switch (net_status)
    {
        case 0://无网络
            return NO;
        case 2://wifi网络
            return YES;
        case 1://wwlan网络
            return YES;
        default:
            break;
    }
    return YES;
}

//获取请求类型 1 ： 有文件上传使用rfc1867协议 0 ：没有文件上传不适用rfc1867协议
- (int)getRequestType:(NSDictionary*)para
{
    for(NSObject *object in para.allValues)
    {
        //检索是不是含有文件
        if([object isKindOfClass:[NSData class]])
        {
            return 1;
        }
    }
    return 0;
}

//设置请求数据
- (NSData*)getPostData
{
    NSData *returnData = nil;
    if(0 == _requestType)
    {
        NSMutableString *temMutableString = [NSMutableString stringWithString:@""];
        for(NSString *key in _requestParameters.allKeys)
        {
            [temMutableString appendFormat:@"&%@=%@",key,[_requestParameters objectForKey:key]];
        }
        NSString *str = temMutableString.length > 0 ? [temMutableString substringFromIndex:1] : temMutableString;
        returnData = [str dataUsingEncoding:NSUTF8StringEncoding];
    }
    if(1 == _requestType)
    {
        NSMutableData *temMutableData = [[NSMutableData alloc] init];
        NSString *boundary = REQUEST_BOUNDARY;
        //rfc1867协议样式
        //        --AaB03x\r\n Content-Disposition:form-data;name="title"\r\n \r\n value\r\n
        //        --AaB03x\r\n Content-Disposition:form-data;name="imagetitle";filename="ab.jpg"\r\n Content-Type:image/JPEG\r\n \r\n datavalue\r\n
        //        --AaB03x--\r\n
        for(NSString *key in _requestParameters.allKeys)
        {
            if([[_requestParameters objectForKey:key] isKindOfClass:[NSString class]])
            {
                NSString *temStr = [NSString stringWithFormat:@"--%@\r\nContent-Disposition:form-data;name=\"%@\"\r\n\r\n%@\r\n",boundary,key,[_requestParameters objectForKey:key]];
                [temMutableData appendData:[temStr dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else
            {
                //NSString *temStr = [NSString stringWithFormat:@"--%@\r\nContent-Disposition:form-data;name=\"%@\";filename=\"ab.jpg\"\r\n Content-Type:image/JPEG\r\n\r\n",boundary,key];
                NSString *temStr = [NSString stringWithFormat:@"--%@\r\nContent-Disposition:form-data;name=\"%@\";filename=\"ab.jpg\"\r\n Content-Type:image/jpeg\r\n\r\n",boundary,key];
                [temMutableData appendData:[temStr dataUsingEncoding:NSUTF8StringEncoding]];
                [temMutableData appendData:[_requestParameters objectForKey:key]];
                [temMutableData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        NSString *endStr = [NSString stringWithFormat:@"--%@--\r\n",boundary];
        [temMutableData appendData:[endStr dataUsingEncoding:NSUTF8StringEncoding]];
        returnData = temMutableData;
    }
    return returnData;
}

//设置请求音频数据
- (NSData*)getAudioPostData
{
    NSData *returnData = nil;
    NSMutableData *temMutableData = [[NSMutableData alloc] init];
    NSString *boundary = REQUEST_BOUNDARY;
    for(NSString *key in _requestParameters.allKeys)
    {
        if([[_requestParameters objectForKey:key] isKindOfClass:[NSString class]])
        {
            NSString *temStr = [NSString stringWithFormat:@"--%@\r\nContent-Disposition:form-data;name=\"%@\"\r\n\r\n%@\r\n",boundary,key,[_requestParameters objectForKey:key]];
            [temMutableData appendData:[temStr dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else
        {
            NSString *temStr = [NSString stringWithFormat:@"--%@\r\nContent-Disposition:form-data;name=\"%@\";filename=ab.mp3\r\n Content-Type:audio/mpeg\r\n\r\n",boundary,key];
            [temMutableData appendData:[temStr dataUsingEncoding:NSUTF8StringEncoding]];
            [temMutableData appendData:[_requestParameters objectForKey:key]];
            [temMutableData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    NSString *endStr = [NSString stringWithFormat:@"--%@--\r\n",boundary];
    [temMutableData appendData:[endStr dataUsingEncoding:NSUTF8StringEncoding]];
    returnData = temMutableData;
    return returnData;
}

#pragma mark- NSUrlConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //可以获取数据的长度
    //    NSLog(@"response:%@",response);
    //    NSLog(@"length:%lld",response.expectedContentLength);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receiveData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //解析json数据
    if (_receiveData != nil) {
        NSString *sourcestr = [[NSString alloc]initWithData:_receiveData encoding:NSUTF8StringEncoding];
        NSLog(@"原始：%@",sourcestr);
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:_receiveData options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments error:nil];
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            ///过滤
            NSMutableDictionary *resultDictionary = [self dealDictionary:dictionary];
            [resultDictionary setObject:_requestParameters forKey:REQUEST_PARAMETER];
            
            if (cacheType != WFRequestCacheTypeNone) {
                [self saveCache];
            }
            //返回数据
            requestHandler handler = objc_getAssociatedObject(self, &requestKey);
            handler(resultDictionary);
        }else{
            NSString *msg = WF_NET_DATAERR;
            NSDictionary *dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",NUM_NET_DATAERR,msg, nil] forKeys:[NSArray arrayWithObjects:kRequestResult,@"status",@"msg", nil]];
            requestHandler handler = objc_getAssociatedObject(self, &requestKey);
            handler(dic);
        }
    }else{
        NSString *msg = WF_NET_DATAERR;
        NSDictionary *dic=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",NUM_NET_DATAERR,msg, nil] forKeys:[NSArray arrayWithObjects:kRequestResult,@"status",@"msg", nil]];
        requestHandler handler = objc_getAssociatedObject(self, &requestKey);
        handler(dic);
    }
    
    [self closeConnect];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSString *msg = [NSString stringWithFormat:@"%@",[error localizedDescription]] ?: WF_NET_LINKERR;
    NSLog(@"connect 链接出错 msg:%@ \n方法名：%s",msg,__FUNCTION__);
    if ([msg containsString:@"超时"] || [msg containsString:@"timed out"]) {
        NSLog(@"超时信息: %@",connection);
        NSLog(@"超时错误信息: %@",error);
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",NUM_NET_CONNECT_FAIL,@"", nil] forKeys:[NSArray arrayWithObjects:kRequestResult,@"status",@"msg", nil]];
        requestHandler handler = objc_getAssociatedObject(self, &requestKey);
        handler(dic);
    }else{
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",NUM_NET_CONNECT_FAIL,msg, nil] forKeys:[NSArray arrayWithObjects:kRequestResult,@"status",@"msg", nil]];
        //返回数据
        requestHandler handler = objc_getAssociatedObject(self, &requestKey);
        handler(dic);
    }
    
    [self closeConnect];
}

@end
