//
//  GJCrashManager.h
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/21.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 管控Crash信息
 1.管理crash日志的上传
 */
@interface GJCrashManager : NSObject

/**
 监控crash
 */
+ (void)monitorCrash;

@end

NS_ASSUME_NONNULL_END
