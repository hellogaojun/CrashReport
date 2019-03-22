//
//  GJCrashInfo.m
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/21.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#import "GJCrashInfo.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

@interface GJCrashInfo ()

@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *appBundleId;
@property (nonatomic, copy) NSString *appSystemVersion;
@property (nonatomic, copy) NSString *appMachineType;
@property (nonatomic, copy) NSString *appArch;

@end

@implementation GJCrashInfo

+ (instancetype)crashInfoWithName:(NSString *)name
                           reason:(NSString *)reason
                             time:(NSString *)time
                     stackSymbols:(NSArray *)stackSymbols {
    GJCrashInfo *crashInfo = [[GJCrashInfo alloc]init];
    crashInfo.crashName = name;
    crashInfo.crashReason = reason;
    crashInfo.crashTime = time;
    crashInfo.crashStackSymbols = stackSymbols;
    return crashInfo;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"appName:%@ === appVersion:%@ === appBundleId:%@ === appSystemVersion:%@ === appMachineType:%@ === appArch:%@ === crashReason:%@ === crashTime:%@ === crashStackSymbols:%@",self.appName,self.appVersion,self.appBundleId,self.appSystemVersion,self.appMachineType,self.appArch,self.crashReason,self.crashTime,self.crashStackSymbols];
}

- (NSString *)appBundleId {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

- (NSString *)appName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

- (NSString *)appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)appSystemVersion {
    return [NSString stringWithFormat:@"%@%@",[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
}

- (NSString *)appMachineType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machineType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return machineType;
}

- (NSString *)appArch {
    return @"arm64";//临时写死了
}


/**
 2019-03-21 11:37:26.306003+0800 OnlineCrashAnalyse[3046:111150] +++++{
 BuildMachineOSBuild = 17G2208;
 CFBundleDevelopmentRegion = en;
 CFBundleDisplayName = crashDemo;
 CFBundleExecutable = OnlineCrashAnalyse;
 CFBundleIdentifier = "gaojun.OnlineCrashAnalyse";
 CFBundleInfoDictionaryVersion = "6.0";
 CFBundleName = OnlineCrashAnalyse;
 CFBundleNumericVersion = 16809984;
 CFBundlePackageType = APPL;
 CFBundleShortVersionString = "1.0.0";
 CFBundleSupportedPlatforms =     (
 iPhoneSimulator
 );
 CFBundleVersion = 1;
 DTCompiler = "com.apple.compilers.llvm.clang.1_0";
 DTPlatformBuild = 10B61;
 DTPlatformName = iphonesimulator;
 DTPlatformVersion = "12.1";
 DTSDKBuild = 16B91;
 DTSDKName = "iphonesimulator12.1";
 DTXcode = 1010;
 DTXcodeBuild = 10B61;
 LSRequiresIPhoneOS = 1;
 MinimumOSVersion = "9.0";
 NSAppTransportSecurity =     {
 NSAllowsArbitraryLoads = 1;
 };
 UIDeviceFamily =     (
 1
 );
 UILaunchStoryboardName = LaunchScreen;
 UIMainStoryboardFile = Main;
 UIRequiredDeviceCapabilities =     (
 armv7
 );
 UISupportedInterfaceOrientations =     (
 UIInterfaceOrientationPortrait
 );
 }
 */
@end
