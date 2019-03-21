//
//  AppDelegate.m
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/21.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugly/Bugly.h>
#include <execinfo.h>

@interface AppDelegate ()

@end

/**
 crash收集上报
 
 iOS Crash分为两种:
 1.是由EXC_BAD_ACCESS引起的，原因是访问了不属于本进程的内存地址，有可能是访问已被释放的内存;
 2.未被捕获的Objective-C异常（NSException),导致程序向自身发送了SIGABRT信号而崩溃.
 
 */

@implementation AppDelegate
static NSString * const appId = @"b0a1a722b0";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    BuglyConfig *config = [[BuglyConfig alloc]init];
//    config.crashAbortTimeout = 0;
//    [Bugly startWithAppId:appId config:config];
    
    [self monitorCrash];
    return YES;
}

- (void)monitorCrash {
    //1.捕获异常类型
    //未知异常的捕获,系统在发生未知异常的情况下,首先讲该异常传递该函数,执行完改函数后,App退出.
    NSSetUncaughtExceptionHandler(&crashExceptionHandler);
    
    //2.signal类型
    signal(SIGABRT, signalCrashExceptionHandler);
    signal(SIGILL,  signalCrashExceptionHandler);
    signal(SIGSEGV, signalCrashExceptionHandler);
    signal(SIGFPE,  signalCrashExceptionHandler);
    signal(SIGBUS,  signalCrashExceptionHandler);
    signal(SIGPIPE, signalCrashExceptionHandler);
}


#pragma mark - Exception
void crashExceptionHandler(NSException *exception) {
    NSString *name = exception.name;
    NSString *reason = exception.reason;
    NSDictionary *userInfo = exception.userInfo;
    NSArray<NSNumber *> *callStackReturnAddresses = exception.callStackReturnAddresses;
    NSArray<NSString *> *callStackSymbols = exception.callStackSymbols;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    
    NSLog(@"CrashTime:%@\n Name:%@\n Reason:%@\n UserInfo:%@\n callStackReturnAddresses:%@\n callStackSymbols:%@",[formatter stringFromDate:[NSDate date]],name,reason,userInfo,callStackReturnAddresses,callStackSymbols);
    
    NSData *logData = [[NSData alloc]initWithBase64EncodedString:[NSString stringWithFormat:@"%@---%@---%@",name,reason,callStackSymbols] options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
    //何时上传crash???
//    [exception raise];
    
    uploadCrashLog(logData);
}

//上传crash日志
void uploadCrashLog(NSData *logData) {
    dispatch_semaphore_t semophore = dispatch_semaphore_create(0); // 创建信号量
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.xxx"]];
    [request setHTTPMethod:@"POST"];
    request.HTTPBody = logData;
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSLog(@"response:%@",response);
                    dispatch_semaphore_signal(semophore); // 发送信号
                }] resume];
    dispatch_time_t timeout = 5;//设置超时时间
    dispatch_semaphore_wait(semophore, timeout); // 等待
   
}

#pragma mark - Signal
void signalCrashExceptionHandler(int signal) {
    void *callStack[128];
    int frames = backtrace(callStack, 128);
    char **strs = backtrace_symbols(callStack, frames);
    NSMutableArray *backtraces = [NSMutableArray arrayWithCapacity:frames];
    for (NSInteger i = 0; i< frames; i++) {
        [backtraces addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    NSString *name = @"SignalException";
    NSString *reason = [NSString stringWithFormat:@"signal %d was raised",signal];
    NSLog(@"Name:%@\n Reason:%@\n CallStack:%@\n",name,reason,backtraces);
}

@end
