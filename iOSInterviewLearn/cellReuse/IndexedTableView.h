//
//  IndexedTableView.h
//  Highlevel
//
//  Created by Eleven on 2018/10/31.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol IndexedTableViewDataSource <NSObject>
// 获取一个tableView的字母索引条数据的方法
- (NSArray <NSString *>*)indexTitlesForIndexTableView:(UITableView *)tableView;

@end

@interface IndexedTableView : UITableView
@property (nonatomic, weak) id<IndexedTableViewDataSource> indexedDataSource;
@end

NS_ASSUME_NONNULL_END
