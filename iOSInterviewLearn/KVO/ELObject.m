//
//  ELObject.m
//  Highlevel
//
//  Created by Eleven on 2018/11/4.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "ELObject.h"

@implementation ELObject
- (instancetype)init{
    self = [super init];
    if (self) {
        _value = 0;
    }
    return self;
}

- (void)increase{
    [self willChangeValueForKey:@"value"];
    _value += 1;
    [self didChangeValueForKey:@"value"];
}
@end













