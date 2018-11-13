//
//  ELObject.h
//  Highlevel
//
//  Created by Eleven on 2018/11/4.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELObject : NSObject
@property (nonatomic, assign) int value;

- (void)increase;
@end

NS_ASSUME_NONNULL_END
