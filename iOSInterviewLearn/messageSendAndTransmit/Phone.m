//
//  Phone.m
//  Highlevel
//
//  Created by Eleven on 2018/11/5.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "Phone.h"

@implementation Phone

- (instancetype)init{
    self = [super init];
    if (self) {
        NSLog(@"sell1 %@", NSStringFromClass([self class]));
        NSLog(@"sell2 %@", NSStringFromClass([super class]));
        // 可能会问的面试问题  两个打印结果是什么
    }
    return self;
}

@end
