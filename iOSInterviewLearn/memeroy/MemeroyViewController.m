//
//  MemeroyViewController.m
//  Highlevel
//
//  Created by Eleven on 2018/11/6.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "MemeroyViewController.h"

@interface MemeroyViewController ()

@end
/*
 *  内存管理 : 1, 内存布局  2, 内存管理g方案  3, 数据结构  4, ARC & MRC 5, 引用计数  6, 弱引用  7,  自动释放池  8 , 循环引用
 *  内存布局 :  内核区 栈 stack -- 堆 heap --- 未初始化数据.bss -- 已初始化数据 .data -- 代码段 .text----- 保留
 *  stack: 方法调用
 * heap: 堆区: 通过allcoc等分配的对象
 .bss  未初始化的全局变量
 .data 已初始化的全局变量等
 .text: 程序代码
 **
 内存管理方案  (要根据不同场景)
 1,小对象:(nsnumber)  用TaggedPointer   2,64位架构下: 用NONPOINTER_ISA 内存管理方案  3, 散列表(复杂数据结构, 其中包含弱引用表和引用计数表)
 objc_runtime-680版本
 NONPOINTER_ISA 非指针型 arm64架构
 散列表 SideTables()结构  SideTables中包含很多sideTable表  是一个hash表  儿sidetable中又包含  spinlock_t 自旋锁   refocountmap  引用计数表  weak_table_t  弱引用表
 为什么不是一个SideTable  存在效率问题  如果这个表下有很多个对象, 当一个对象在操作这张表的时候 会上锁, 而下一个对象要等待上一个对象操作完成后再继续操作 所以存在效率问题;  系统为了解决这一问题, 引入了 分离锁的技术方案,  把内存对象对应的引用计数表分成对个,  比如64位的表 分为8个, 分别加锁 可以并发操作, 提高访问效率

 ** 怎样实现快速分流?  (通过一个对象的指针如何快速定位属于哪个SideTable的表中)  sidetables的本质是一张Hash表,  对象指针(key)---hash函数-->sidetable(value),  hash查找过程:  通过对象内存地址和sidetable的个数 进行取余运算来算出在那个表中
 *
 数据结构: Spinlok_t  自旋锁   忙等的锁  如果当前锁已被其他线程获取,当前线程会不断的试探当前锁有没有被释放, 如果释放掉, 自己第一时间去获取锁,  获取不到的时候, 进行阻塞休眠, r当其他线程释放的时候, 第一时间去获取; 适用于轻量访问,
 *
 RefcountMap  引用计数表  通过hash表实现的 提高查找效率  因为其插入和提取都是通过一个hash函数实现的额
 weak_table_t  弱引用表   对象指针(key)---Hash函数---->  weeak_entry_t(value)
 *
 MRC 手动引用计数  MRC下特有方法  retain  release  retaincount  aurorelease
 ARC 自动引用计数  是LLVM(编译器)和Runtimer协作的结果 (weak变量为何在对象释放的时候指为nil)
 *
 引用计数管理
 实现原理分析: alloc(通过一系列封装调用, 最终调用了c函数calloc, 此时没有设置引用计数为1)  retain(经历了两次hash查找 size_t类型值  在对引用计数+1操作)  release(通过当前对象经过hash算法 找到sideTable 对引用计数值-1操作)  retaincount()  deallo(start -- _objc_rootDealloc() -- rootDealloc-是否可以释放(if  nonpointer_isa  weakly_referenced  has_assoc  has_cxx_dtor   has_sidetable_rc)--判断当前对象既不是非指针型的isa指针, 也没有弱引用, 也没有关联对象, 也没有c++相关内容, 也没有ARC) 否则调用object_dispose()清楚, 否则调用c函数的free  具体内部实现

    object_dispose()实现   开始 --> objc_destructInstance() -- c free
 objc_destructInstance  开始 -- > hasCxxDtor   在系统内部调用dealloc的时候  会自动判断当前类是否有关联对象  如果有系统则会自动移除相关的关联对象
 clearDeallocating()   开始 -> sidetable_clearDeallocating()  -> weak_clear_no_lock()(将指向该对象的弱引用指针置为nil) --> table.refcnts.erase()

 弱引用  weak变量如何添加到弱引用表中    添加weak变量  可以通过弱引用对象通过hash算法的计算添加位置  objc_initWeak() -- > storeWeak() -- > weak_register_no_lock()

 清楚weak变量, 同时设置为nil   dealloc() -- >  .... --> weak_clear_no_lock()   当一个对象被dealloc之后, 内部实现会调用弱引用清除的相关函数, 在其内部实现会根据当前对象指针查找弱引用表, 把当前弱引用拿出来, 遍历并且置为nil
 *
 *  循环引用 :   类型 1, 自循环引用  2, 相互循环引用  3 ,  多循环引用
 *  自循环引用,  比如: 有一个对象有个一个obj的成员变量(id_strong obj) 强持有成员变量  如果此时将成员变量obj赋值h给该对象
 *  相互循环引用:  对象A 成员变量 id_strong  obj  对象B 成员变量 id_strong obj  如果对象A中的obj指向对象B  对象B中的obj指向A
 多循环引用:  多个对象 中的id__strong obj相互指向一次指向下个对象 最后一个对象又指向第一个对象 形成了 多循环引用

 * 考点:  1, 代理  2, block  3, NSTimer  4, 大环多循环
 * 如何破除循环引用?  避免产生循环引用   合适的时机手动断环
 *  具体方案有哪些?  1, __weak  2,  __block  3, __unsafe_unretained
 __weak  对象A(id __weak obj)   对象B(id_strong obj) 此时相互引用 对象B强持有A的成员变量 obj  对象A弱引用对象B
 __block  MRC下, __block修饰对象不会增加其引用计数, 避免了循环引用   ARC下 __block修饰对象会被强引用, 无法避免循环引用, 需要手动解环
 --unsafe_unretained  修饰对象不会增加其引用计数, 避免了循环引用  但是如果在被修饰对象在某一时机被释放, 会产生悬垂指针  所以一般不建议使用
 循环引用示例,  NSTimer  (重复计时器和非重复计时器)
 Runloop  --->  NSTimer <--> 对象 <--- VC (d对象持有timer, timer通过target调用又持有该对象)  非重复定时器时在回调方法中调用 invalid 方法 并将计时器 置位nil  若是重复计时器 则可以添加一个中间对象 让中间对象对 timer和对象分别持有弱引用

 ** 内存管理的总结:  1, 什么是ARC?  LLVM和Runtimer  2, 为什么weak指针指向的对象在肥沃之后会自动置位nil  3, 如何实现AutoreleaseePool的?  4, 什么是循环引用? 遇到过哪些? 是怎么解决的?
 */
@implementation MemeroyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
