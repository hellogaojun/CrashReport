//
//  GJCrashInfo.h
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/21.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 基本crash信息
 1.应用的基本信息
 2.crash携带的信息
 */
@interface GJCrashInfo : NSObject

@property (nonatomic, copy) NSString *crashName;
@property (nonatomic, copy) NSString *crashReason;
@property (nonatomic, copy) NSString *crashTime;
@property (nonatomic, copy) NSArray  *crashStackSymbols;

+ (instancetype)crashInfoWithName:(NSString *)name
                           reason:(NSString *)reason
                               time:(NSString *)time
                       stackSymbols:(NSArray *)stackSymbols;

@end

NS_ASSUME_NONNULL_END
