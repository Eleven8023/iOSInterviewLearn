//
//  ReuseablePool.h
//  Highlevel
//
//  Created by Eleven on 2018/10/31.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ReuseablePool : NSObject
// 从重用池中取出一个可重用的view
- (UIView *)dequeueReuseableView;
// 向重用池中添加一个视图
- (void)addUsingView:(UIView *)view;
// 重置方法, 将当前使用中的视图移动到可复用队列当中
- (void)reset;



@end

NS_ASSUME_NONNULL_END
