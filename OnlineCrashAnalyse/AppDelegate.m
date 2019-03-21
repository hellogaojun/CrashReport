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
    
    NSData *logData = [[NSString stringWithFormat:@"%@---%@---%@",name,reason,callStackSymbols] dataUsingEncoding:(NSUTF8StringEncoding)];
    //何时上传crash???
//    [exception raise];
    
    uploadCrashLog(logData);
}

//上传crash日志
void uploadCrashLog(NSData *logData) {
    dispatch_semaphore_t semophore = dispatch_semaphore_create(0); // 创建信号量
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://5vh6nd.natappfree.cc/book/demo"]];
    [request setHTTPMethod:@"POST"];
    request.HTTPBody = logData;
    [request setValue:@"text/plain" forHTTPHeaderField:@"content-type"];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSLog(@"response:%@",response);
                    dispatch_semaphore_signal(semophore); // 发送信号
                }] resume];
    dispatch_time_t timeout = DISPATCH_TIME_FOREVER;//设置超时时间
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


/**
 看两种上传的日志分析:
 1.友盟:
 *** -[__NSFrozenArrayM objectAtIndexedSubscript:]: index 4 beyond bounds [0 .. 3]
 (null)
 
 ((
 0 CoreFoundation 0x0000000182f12da4 <redacted> + 252
 1 libobjc.A.dylib 0x00000001820cc5ec objc_exception_throw + 56
 2 CoreFoundation 0x0000000182eab750 _CFArgv + 0
 3 CoreFoundation 0x0000000182e99ef0 <redacted> + 0
 4 PolyBoTreasure 0x0000000100242660 PolyBoTreasure + 1762912   (项目位置)
 5 UIKit 0x000000018cc8164c <redacted> + 96
 6 UIKit 0x000000018cda2870 <redacted> + 80
 7 UIKit 0x000000018cc87700 <redacted> + 440
 8 UIKit 0x000000018cdbd1a8 <redacted> + 572
 9 UIKit 0x000000018cd049e0 <redacted> + 2428
 10 UIKit 0x000000018ccf9890 <redacted> + 3160
 11 UIKit 0x000000018ccf81d0 <redacted> + 340
 12 UIKit 0x000000018d4d9d1c <redacted> + 2340
 13 UIKit 0x000000018d4dc2c8 <redacted> + 4744
 
 14 UIKit 0x000000018d4d5368 <redacted> + 152
 15 CoreFoundation 0x0000000182ebb404 <redacted> + 24
 16 CoreFoundation 0x0000000182ebac2c <redacted> + 276
 17 CoreFoundation 0x0000000182eb879c <redacted> + 1204
 18 CoreFoundation 0x0000000182dd8da8 CFRunLoopRunSpecific + 552
 19 GraphicsServices 0x0000000184dbe020 GSEventRunModal + 100
 20 UIKit 0x000000018cdf8758 UIApplicationMain + 236
 21 PolyBoTreasure 0x00000001001d1500 PolyBoTreasure + 1299712 (项目位置)
 22 libdyld.dylib 0x0000000182869fc0 <redacted> + 4
 )
 dSYM UUID: 187E63F6-6519-3E1C-9343-C123DF535AEA
 CPU Type: arm64
 Slide Address: 0x0000000100000000
 Binary Image: PolyBoTreasure
 Base Address: 0x0000000100094000
 
 
 操作命令:
 atos -o
 /Users/gaojun/Desktop/错误报告/PolyBoTreasure.app.dSYM/Contents/Resources/DWARF/PolyBoTreasure ( 这是文件地址)
 -arc arm64 (这是架构)
 -l
 0x0000000100242660(这是起始地)  0x00000001003F0CC0(这是结束地址)
 
 结束地址 = 起始地址 + 偏移量
 
 这样便可以定位到出问题的具体位置!!!
 
 2.Bugly分析比较智能(跟友盟的Crash日志不太一样):
     1.Bugly后台的crash日志可以看到UUID
     2.可通过终端命令快速查找指定 UUID 符号表文件
     3.找到符号表文件后上传至Bugly后台网站( 自动分析)
 */
@end
