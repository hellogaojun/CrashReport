//
//  CrashNote.h
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/25.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#ifndef CrashNote_h
#define CrashNote_h

/**
 ********************Crash文件的分析,收集上报********************
 一,Crash文件的分析
 1.crash文件导出(连上手机,Xcode->Window->Devices and Simulators->View Device Logs->Export Log)
 
 2.分析导出的.crash文件分为两种情况:
     2.1 在Build Settings中没有勾选dSYM
         2.1.1  下载符号恢复工具restore-symbol.dms(并赋予可执行权限chmod a+x restore-symbol.dms)
 
         2.1.2  用该工具恢复符号表
         ./restore-symbol.dms -o OnlineCrashAnalyse-symbol(这是恢复出的文件) OnlineCrashAnalyse(这是原始文件,可在Xcode中的Products目录下的OnlineCrashAnalyse.app中获取,Unix可执行文件)
 
         2.1.3   使用Apple 自带的命令行工具atos将崩溃地址解析成具体函数
         atos -arch arm64(指明架构) -o OnlineCrashAnalyse-symbol(上一步恢复的符号表文件) -l 0x10064c000(crash起始地址) 0x100652a00(crash结束地址)
 
         2.1.4   一个参考结果:
         -[ViewController testException] (in OnlineCrashAnalyse-symbol) (ViewController.m:33)
        
    ***这种方式因为没有dSYM文件,通过工具导出dSYM文件,所以仅仅能用来测试阶段的分析***
    ***建议还是在Debug状态下勾选dSYM文件***
 
 2.2 在Build Settings中勾选了dSYM
 在这种情况下导出的.crash文件,一般情况下标明了crash的位置所在,当然了我们也可以做反向验证(做16进制减法).这种情况下项目的dSYM文件位于Xcode中的Products目录下OnlineCrashAnalyse.app(有以下两种方式可以查看
 1.show in Finder即可查看
 2.使用指令根据UUID获取(推荐这种方式),mdfind "com_apple_xcode_dsym_uuids == 44017FA3-C24F-3B06-AAC0-90C8BD9CC23A(这是UUID)". UUID在.crash文件的Binary Images 可以查看,在该指令中按照8-4-4-4-12的格式分割,字母要求全部大写!)
 
 我们同样可以使用命令
 atos -arch arm64 -o /Users/gaojun/Desktop/OnlineCrashAnalyse.app.dSYM/Contents/Resources/DWARF/OnlineCrashAnalyse -l 0x1047B0000 0x1047b80b0 做验证,验证结果如下:
 
 -[ViewController testException] (in OnlineCrashAnalyse) (ViewController.m:33)
 
 ***本部分用到的工具及参考案例在About Crash 文件夹下***
 
 二,Crash日志收集上报
    此处仅为模拟一个日志上报,详情可查看Crash文件夹下GJCrashManager的实现.
 
 三,参考链接
 0.https://developer.apple.com/library/archive/technotes/tn2151/_index.html
 1.https://www.cnblogs.com/ciml/p/7422872.html
 2.https://bugly.qq.com/docs/user-guide/symbol-configuration-ios/?v=1553248351425
 
 3.https://blog.csdn.net/weixin_34090562/article/details/87008863
 4.http://www.cocoachina.com/ios/20180326/22765.html
 5.https://www.jianshu.com/p/cf0945f9c1f8
 
 */

#endif /* CrashNote_h */
