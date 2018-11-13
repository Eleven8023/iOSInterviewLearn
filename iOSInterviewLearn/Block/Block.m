//
//  Block.m
//  Highlevel
//
//  Created by Eleven on 2018/11/7.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "Block.h"

@interface Block()
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, copy) int(^blk)(int);
@end
/**
 * 什么是Block?   Block是将函数及其执行上下文封装起来的对象
 *  源码解析:  使用 clang -rewrite-objc file.m  查看编译之后的文件内容
 *  什么是block调用  本质即函数调用
 * 截获变量   1, 局部变量(基本数据类型, 对象类型)  2,  静态局部变量  3 , 全局变量  4, 静态全局变量
 对不同变量类型的截获
 1 对于基本数据类型的局部变量截获其值   2 对于对象类型的局部变量连同所有权修饰符一起截获  3 以指针形式截获局部静态变量  4 不截获全局变量, 静态全局变量
 源码解析  用 clang -rewrite-objc -fobjc-arc file.m 命令

 __block 修饰符  一般情况下, 对被截获变量进行赋值操作需要添加__block
 对变量进行赋值操作时: 需要__block修饰符  局部变量(基本数据类型, 对象;类型)
 对变量进行赋值时: 不需要__block修饰符 (静态局部变量, 全局变量, 静态全局变量)
 __block修饰的变量变成对象  栈上__forwarding指针指向__block对象
 block的内存管理
 impl.isa = &_NSConcreteStackBlock
 1, _NSConcreteGlobalBlock  2,  _NSConcreteStackBlock  栈block  3, _NSConcreteMallocBlock  堆block
 Block的copy操作?  源  栈上的block  Copy结果 堆  2, 全局上block  copy   什么也不做  3,  堆上block  增加引用计数
 栈上block的销毁,  栈上函数结束后 _block被销毁  栈上block的copy  __block变量  --copy-->  堆上 Block, __block变量
 __forwarding存在的意义

 // Block的引用循环
 // 为什么block会产生循环引用? 当前block对当前某个成员变量截获的时候, 会对当前对象有一个强引用, 当前lblock又由于当对象对其持有
 // block的自循环引用  block的闭环循环引用
 // 怎样理解Block截获变量的特性?
 */
@implementation Block

// 全局变量
int global_var = 4;
// 静态全局变量
static int static_global_var = 5;

- (void)method{
    int multiplier = 6;
    //    static int multiplier = 6;  8
//    __block int multiplier = 6;  8
    int (^Block)(int) = ^int(int num){
        return num * multiplier;
    };
    multiplier = 4;
    Block(2);
    NSLog(@"%dfaf", Block(2));
    // 笔试题 问此时控制台打印结果是什么?  答案是: 12  截获变量
}

- (void)method1{
    // 基本数据类型的局部变量
    int var = 1;
    // 对象类型的局部变量
    __unsafe_unretained id unsafe_obj = nil;
    __strong id strong_obj = nil;

    // 局部静态变量
    static int  static_var = 3;

    void(^Block)(void) = ^{
        NSLog(@"局部变量<基本数据类型> var %d", var);
        NSLog(@"局部边浪<__unsafe_unretained 对象类型> var %@", unsafe_obj);
        NSLog(@"局部边浪<__strong 对象类型> var %@", strong_obj);

        NSLog(@"静态边浪 %d", static_var);

        NSLog(@"全局n变量 %d", global_var);;
        NSLog(@"静态全局变量 %d", static_global_var);
    };
    Block();
}
// 面试的坑  此时需不需要进行__block操作  A:只有赋值操作的时候才需要调用 __block
- (void)method3{
    NSMutableArray *array = [NSMutableArray array];
    void(^Block)(void) = ^{
        [array addObject:@123];
    };
    Block();
}
// 此时需要加__block
- (void)method4{
    NSMutableArray *array = nil;
    void(^Block)(void) = ^{
//        array = [[NSMutableArray alloc] init];
    };
    Block();
}

// 面试 会产生自循环引用  对象持有block  而block又持有当前对象
// 为什么用__weak修饰能解决block循环引用问题?  答: 因为我们block截获特性, 截获对象的时候是连同所有权修饰一并截获的, __weak所有权修饰符的, block结构体中持有的成员变量也是__weak类型的
- (void)block1{
//    _array = [NSMutableArray arrayWithObject:@"block"];
//    _strBlk = ^NSString*(NSString *num){
//        return [NSString stringWithFormat:@"helloc_%@", _array[0]];
//    };
//    _strBlk(@"hello");

    // 答案
//    _array = [NSMutableArray arrayWithObject:@"block"];
//    __weak NSArray *weakArray = _array;
//    _strBlk = ^NSString*(NSString *num){
//        return [NSString stringWithFormat:@"helloc_%@", weakArray[0]];
//    };

}
// __block  以下代码   在MRC下, 不会产生循环引用  在ARC下, 会产生循环引用, 引起内存泄漏
// block在MRC和ARC下的区别:  ARC下循环引用
// ARC下的  对象 --持有-->  Block  --持有--> __block变量 --持有-->原对象  闭环循环引用
- (void)block2{
//    __block Block *blockSelf = self;
//    int(^block)(int) = ^(int num){
//        return num * blockSelf.var;
//    };
//    block(3);

    __block Block *blockSelf = self;
    _blk = ^int(int num){
        // 解决方案
//        int result = num * blockSelf.var;
//        blockSelf = nil;
//        return reslut;
        return 0;
    };
    _blk(3);

}

@end




























