//
//  AppDelegate.m
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/21.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugly/Bugly.h>

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
 Reference:
 1.https://www.cnblogs.com/ciml/p/7422872.html
 2.https://bugly.qq.com/docs/user-guide/symbol-configuration-ios/?v=1553248351425
 
 
 没有dSYM文件的分析仅能用作测试阶段的分析.
 
 .crash文件的分析:
 1.文件导出(连上手机,Xcode->Window->Devices and Simulators->View Device Logs->Export Log)
 2.分析导出的.crash文件分为两种情况:
    2.1 在Build Settings中没有勾选dSYM
        2.1.1  下载符号恢复工具restore-symbol.dms(并赋予可执行权限chmod a+x restore-symbol.dms)
 
        2.1.2  用该工具恢复符号表
                ./restore-symbol.dms -o OnlineCrashAnalyse-symbol(这是恢复出的文件) OnlineCrashAnalyse(这是原始文件,可在Xcode中的Products目录下的OnlineCrashAnalyse.app中获取,Unix可执行文件)
 
        2.1.3   使用Apple 自带的命令行工具atos将崩溃地址解析成具体函数
                atos -arch arm64(指明架构) -o OnlineCrashAnalyse-symbol(上一步恢复的符号表文件) -l 0x10064c000(crash起始地址) 0x100652a00(crash结束地址)
 
        2.1.4   一个参考结果:
                -[ViewController testException] (in OnlineCrashAnalyse-symbol) (ViewController.m:33)
 
 
    2.2 在Build Settings中勾选了dSYM
    在这种情况下导出的.crash文件,一般情况下标明了crash的位置所在,当然了我们也可以做反向验证(做16进制减法).这种情况下项目的dSYM文件位于Xcode中的Products目录下OnlineCrashAnalyse.app(show in Finder即可查看)
    我们同样可以使用命令
    atos -arch arm64 -o /Users/gaojun/Desktop/OnlineCrashAnalyse.app.dSYM/Contents/Resources/DWARF/OnlineCrashAnalyse -l 0x1047B0000 0x1047b80b0 做验证,验证结果如下:
 
    -[ViewController testException] (in OnlineCrashAnalyse) (ViewController.m:33)
 
 ********强烈建议在每次版本发布时,都保留当次版本的dSYM文件以供线上crash问题的分析********
 Xcode默认情况下,Debug不勾选dSYM,Release勾选DSYM
 
 */


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
