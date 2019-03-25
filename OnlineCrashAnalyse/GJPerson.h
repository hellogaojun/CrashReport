//
//  GJPerson.h
//  OnlineCrashAnalyse
//
//  Created by gaojun on 2019/3/25.
//  Copyright © 2019年 gaojun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GJPerson : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *hobbies;
@property (nonatomic, assign) NSInteger age;

@end

NS_ASSUME_NONNULL_END
