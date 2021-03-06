//
//  GJCrashManager.m
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/21.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#import "GJCrashManager.h"
#include <execinfo.h>
#import "GJCrashInfo.h"

static NSURLSession *_urlSession = nil;
static NSDateFormatter *_formatter = nil;

static NSString * const _appCrashHost = @"http://2j4qp2.natappfree.cc/book/demo";

@implementation GJCrashManager

+ (void)monitorCrash {
    
    //1.捕获异常类型
    //未知异常的捕获,系统在发生未知异常的情况下,首先讲该异常传递该函数,执行完改函数后,App退出.
    //typedef void NSUncaughtExceptionHandler(NSException *exception);
    NSSetUncaughtExceptionHandler(&crashExceptionHandler);
    
    //2.signal类型
    //abort()函数调用
    signal(SIGABRT, signalCrashExceptionHandler);
    //非法指令
    signal(SIGILL,  signalCrashExceptionHandler);
    //无效内存的引用
    signal(SIGSEGV, signalCrashExceptionHandler);
    //浮点数异常
    signal(SIGFPE,  signalCrashExceptionHandler);
    //内存地址未对齐
    signal(SIGBUS,  signalCrashExceptionHandler);
    //端口发送消息失败
    signal(SIGPIPE, signalCrashExceptionHandler);
    
    signal(SIGHUP, signalCrashExceptionHandler);
    signal(SIGINT, signalCrashExceptionHandler);
    signal(SIGQUIT, signalCrashExceptionHandler);
    
}

#pragma mark - Exception

void crashExceptionHandler(NSException *exception) {
    NSString *name = exception.name;
    NSString *reason = exception.reason;
    NSDictionary *userInfo = exception.userInfo;
    NSArray<NSNumber *> *callStackReturnAddresses = exception.callStackReturnAddresses;
    NSArray<NSString *> *callStackSymbols = exception.callStackSymbols;
    
    if (!_formatter) {
         _formatter = [[NSDateFormatter alloc]init];
    }
    _formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    _formatter.timeZone = timeZone;
    
    NSLog(@"CrashTime:%@\n Name:%@\n Reason:%@\n UserInfo:%@\n callStackReturnAddresses:%@\n callStackSymbols:%@",[_formatter stringFromDate:[NSDate date]],name,reason,userInfo,callStackReturnAddresses,callStackSymbols);
    
    GJCrashInfo *crashInfo = [GJCrashInfo crashInfoWithName:name reason:reason time:[_formatter stringFromDate:[NSDate date]] stackSymbols:callStackSymbols];
    NSData *logData = [crashInfo.description dataUsingEncoding:(NSUTF8StringEncoding)];
    //何时上传crash???
    //    [exception raise];
    
    uploadCrashLog(logData);
}

#pragma mark - Signal
//捕获异常信号
void signalCrashExceptionHandler(int signal) {
    void *callStack[128];
    int frames = backtrace(callStack, 128);
    //获取当前的堆栈信息
    char **strs = backtrace_symbols(callStack, frames);
    NSMutableArray *backtraces = [NSMutableArray arrayWithCapacity:frames];
    for (NSInteger i = 0; i< frames; i++) {
        [backtraces addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    NSString *name = @"SignalException";
    NSString *reason = [NSString stringWithFormat:@"signal %d was raised",signal];
    NSLog(@"Name:%@\n Reason:%@\n CallStack:%@\n",name,reason,backtraces);
    
    //获取crash发生时间
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc]init];
    }
    _formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    _formatter.timeZone = timeZone;
    
    //upload
    GJCrashInfo *crashInfo = [GJCrashInfo crashInfoWithName:name reason:reason time:[_formatter stringFromDate:[NSDate date]] stackSymbols:backtraces];
    NSData *logData = [crashInfo.description dataUsingEncoding:(NSUTF8StringEncoding)];
    uploadCrashLog(logData);
}

#pragma mark - Upload
//上传crash日志
//上传crash的时机,一种观点认为先将有关crash的堆栈信息保存在本地,app下次启动时再上传至服务器.
//这是因为，在保存完这些堆栈信息以后，App 就崩溃了，崩溃后内存里的数据也就都没有了。而将数据保存在本地磁盘中，就可以在 App 下次启动时能够很方便地读取到这些信息。
void uploadCrashLog(NSData *logData) {
    dispatch_semaphore_t semophore = dispatch_semaphore_create(0); // 创建信号量
    _urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_appCrashHost]];
    [request setHTTPMethod:@"POST"];
    request.HTTPBody = logData;
    [request setValue:@"text/plain" forHTTPHeaderField:@"content-type"];
    
    //设置crash发生后最大等待时间
    int64_t crashMaxTimeout = 5;
    NSDate *nowDate = [NSDate date];
    NSDate *timeoutDate = [nowDate dateByAddingTimeInterval:crashMaxTimeout];
    
    //如果本次没有上传成功,考虑在下次启动时重新上传!!!
    [[_urlSession dataTaskWithRequest:request
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        //如果最大等待时间内上传日志请求还没响应的话,就不再继续等待了
                        if ([[NSDate date] compare:timeoutDate] == kCFCompareGreaterThan) {
                            dispatch_semaphore_signal(semophore);
                            return;
                        }
                        NSLog(@"response:%@",response);
                        dispatch_semaphore_signal(semophore); // 发送信号
                    }] resume];
    dispatch_time_t timeout = DISPATCH_TIME_FOREVER;//设置超时时间
    dispatch_semaphore_wait(semophore, timeout); // 等待
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(crashMaxTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_semaphore_signal(semophore);
    });
}


@end
