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

#import "GJCrashManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
static NSString * const appId = @"b0a1a722b0";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [Bugly startWithAppId:appId];
    
    [GJCrashManager monitorCrash];
    
    return YES;
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
