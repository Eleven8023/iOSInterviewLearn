//
//  IndexedTableView.m
//  Highlevel
//
//  Created by Eleven on 2018/10/31.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "IndexedTableView.h"
#import "ReuseablePool.h"
@interface IndexedTableView ()
{
    UIView *containerView;
    ReuseablePool *pool;
}

@end

@implementation IndexedTableView


- (void)reloadData{
    [super reloadData];
    // 懒加载
    if (containerView == nil) {
        containerView = [[UIView alloc] initWithFrame:CGRectZero];
        containerView.backgroundColor = [UIColor whiteColor];
        // 避免索引随着table滚动
        [self.superview insertSubview:containerView aboveSubview:self];
    }

    if (pool == nil) {
        pool = [[ReuseablePool alloc] init];
    }
    // 标记所有视图为可重用的状态
    [pool reset];
    // reload字母索引条
    [self reloadIndexedBar];
}

- (void)reloadIndexedBar{
    // 获取字母索引条的显示内容
    NSArray <NSString *> *arrayTitles = nil;
    if ([self.indexedDataSource respondsToSelector:@selector(indexTitlesForIndexTableView:)]) {
        arrayTitles = [self.indexedDataSource indexTitlesForIndexTableView:self];
    }
    // 判断字母索引条是否为空
    if (!arrayTitles || arrayTitles.count <= 0) {
        [containerView setHidden:YES];
        return;
    }
    NSUInteger count = arrayTitles.count;
    CGFloat buttonWidth = 60;
    CGFloat buttonHeight = self.frame.size.height / count;

    for (int i = 0; i < arrayTitles.count; i ++) {
        NSString *title = [arrayTitles objectAtIndex:i];
        // 从重用池当中去一个button出来
        UIButton *button = (UIButton *)[pool dequeueReuseableView];
        // 如果没有可重用的button重现创建一个
        if (button == nil) {
            button = [[UIButton alloc] initWithFrame:CGRectZero];
            button.backgroundColor = [UIColor whiteColor];
            // z注册button到重用池中
            [pool addUsingView:button];
            NSLog(@"新创建一个button");
        }else{
            NSLog(@"button 重用了");
        }
        // 添加button到父视图控件
        [containerView addSubview:button];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        // 设置button的坐标
        [button setFrame:CGRectMake(0, i * buttonHeight, buttonWidth, buttonHeight)];
    }

    [containerView setHidden:NO];
    containerView.frame = CGRectMake(self.frame.origin.x + self.frame.size.width - buttonWidth, self.frame.origin.y, buttonWidth, self.frame.size.height);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
