//
//  ELObserve.m
//  Highlevel
//
//  Created by Eleven on 2018/11/4.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "ELObserve.h"
#import "ELObject.h"
@implementation ELObserve

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([object isKindOfClass:[ELObject class]] && [keyPath isEqualToString:@"value"]) {
        // 获取value的值
        NSNumber *valueN = [change valueForKey:NSKeyValueChangeNewKey];
        NSLog(@"value is %@", valueN);
    }
}
@end






























