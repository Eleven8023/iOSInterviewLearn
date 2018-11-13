//
//  Thread.m
//  Highlevel
//
//  Created by Eleven on 2018/11/11.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "Thread.h"

/* 多线程:  GCD  NSOperation   NSThread   多线程与锁
 * GCD:  1, 同步/异步 和 串行/并发   2,dispatch_barrier_async   (异步栅栏调用, 解决多读单写的技术方案)   3dispatch_group
 *
 *同步/异步 和 串行/并发  1, dispatch_sync (serial_queue, ^{//任务})  同步串行  2, dispatch_async(serial_queue,^{//任务}) 异步串行 3, dispatch_sync(concurrent_queue,^{//任务}) 同步并发 4, dispatch_async(concurrent_queue,^{//任务})  异步并发
 同步串行:  会产生死锁 (死锁原因: 队列引起的循环等待)
 - (void)viewDidLoad{
     dispatch_sync(dispatch_get_main_queue(), ^{
        [self doSomething];
     });
 }
 // 同步到自定义的串行队列  没有问题
 - ((void)viewDidLoad{
     dispatch_sync(seerialQueue, ^{
     [self doSomething];
     })
 }
 * 同步并发  12345
 -(void)viewDidLoad{
     NSLog(@"1");
     dispatch_sync(global_queue, ^{
        NSLog(@"2");
        dispatch_sync(global_queue,^{
            NSLog(@"3");
        })
        NSLog(@"4");
     })
     NSLog(@"5");
 }
 * 异步串行
 -(void)viewDidLoad{
     dispatch_async(dispatch_get_main_queue(),^{
     [self doSomething];
 });
 }
 * 异步并发  13  2不打印   分析: 异步分派到全局队列, block在GCD底层维护的线程池上去做处理, 而在底层线程池上创建的该线程默认的RunLoop默认是不开启的, 所以performSelector是失效的
 -(void)viewDidLoad{
     dispatch_async(global_queue,^{
     NSLog(@"1");
     [self performSelector:@selctor(printLog)
     withObject:nil
     afterDelay:0]
     NSLog(@"3");
 });
 }
 - (void)printLog{
    NSLog(@"2");
 }
 * dispatch_barrier_async()
 怎样实现多读单写的模型?
 dispatch_barrier_async(concurrent_queue,^{// 写操作});  通过栅栏异步调用方式将写操作放入并发队列中
 *
 *dispatch_group_async()
 使用GCD实现需求: A,B,C三个任务并发完成后执行任务D?

 *NSOperation  需要和NSOperationQueue配合使用来实现多线程方案
 好处特点:1 添加任务依赖  2, 任务执行状态控制  3, 最大并发量
 任务执行状态控制: 1,isReady  2, isExecuting  3, isFinished 4, isCancelled
 状态控制: 如果只重写了main方法, 底层控制变更任务执行完成状态, 以及任务退出;  如果重写start方法, 自行控制任务状态
 系统是怎样移除一个isFinished=YES的NSOperation的?
 a答: 通过KVO方式
 *NSTread
 *启动流程: 创建后 -> strat()  -> 创建pthread -> main() -> [target performSelector:selector] (RunLoop) -> exit()
 *(如何实现一个常驻线程)
 *Start方法  NSThread 的原理, 通过内部创建Pthread线程, main函数执行之后, 系统会进行线程退出管理操作.
 *
 * 锁
 ios当中都有哪些锁?
 1, @synchronized  2, atomic 3, OSSpinLock  4,NSRecursiveLock  5, NSLock  6, dispatch_semaphore_t

 @synchronized: 一般在创建单例对象的时候使用, 保证在多线程环境下创建的对象是唯一的
 atomic: 修饰属性的关键字, 对被修饰对象进行原子操作(不负责使用).  例: @property(atomic)NSMutableArray *array; self.array = [NSMutableArray array]; 正确  [self.array addObject:obj]; 错误使用的时候不保证线程安全
 OSSpinLock: 自旋锁  循环等待询问, 不释放当前资源,   用于一些轻量级数据访问, 简单的int值 +1/-1操作
 NSLock: 解决线程同步问题, 保证线程互斥进入自己的临界区   -(void)methodA{[lock lock]; [self methodB]; [lock unlock]}
 -(void)methodB{[lock lock]; // 操作逻辑  [lock unlock];}  导致死锁: 冲入加锁的额原因 导致的死锁   (通过递归锁的实现)
 NSRecursiveLock: (重入特性)  解决NSLock的问题  -(void)methodA{[recursiveLock lock];[self methodB];[recursiveLock unllock];}  -(void)methodB{[recursiveLock lock]; // 操作逻辑  [recursiveLock unlock]};
 dispatch_semaphore_t:(线程同步共享资源访问的信号量): dispatch_semaphore_create(1); dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER); dispatch_semaphore_signal(semaphore);
 dispatch_semaphore_create()
 */

/*
 *  总结: 1, 怎样用GCD实现多读单写?  2, ios系统为我们提供的几种多线程技术各自的特尔是什么?  1,GCD(简单的线程同步, 子线程的分派, 多读单写) 2, NSOperationQueue (网络 第三方图片框架, 特点可以方便对任务的状态可以控制, 添加依赖) 3, NSThread  (添加常驻线程) 3,NSOperation对象在finished之后是怎样从queue当中移除掉的? KVO 通知operationQueue进行移除  4, 你都用过哪些锁? 结合实际谈谈你是怎样使用的?
 *
 */

@interface Thread (){
    // 定义一个并发队列
    dispatch_queue_t concurrent_queue;
    // 用户数据中心, 可能多个线程需要数据访问
    NSMutableDictionary *userCenterDic;

    dispatch_queue_t concurrent_queue1;
    NSMutableArray <NSURL *> *arrayURLs;
}

@end
// 多读单写模型
@implementation Thread

- (instancetype)init{
    self = [super init];
    if (self) {
        // 通过宏定义 DISPATCH_QUEUE_CONCURRENT 创建一个并发队列
        concurrent_queue = dispatch_queue_create("read_write_queue", DISPATCH_QUEUE_CONCURRENT);
        // 创建数据容器
        userCenterDic = [NSMutableDictionary dictionary];

        concurrent_queue1 = dispatch_queue_create("concurrent_queue", DISPATCH_QUEUE_CONCURRENT);
        arrayURLs = [NSMutableArray array];
    }
    return self;
}

- (void)handle{
    // 创建一个group
    dispatch_group_t group = dispatch_group_create();
    // for 循环遍历各个元素执行操作
    for (NSURL *url in arrayURLs) {
        // 异步组分派到并发队列当中
        dispatch_group_async(group, concurrent_queue1, ^{
            // 根据url去下载图片
            NSLog(@"url is %@", url);
        });
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 当添加到数组中的所有任务执行完成之后会调用该Block
        NSLog(@"所有图片已经全部下载完成");
    });
}

// 读
- (id)objectForKey:(NSString *)key{
    __block id obj;
    // 同步读取指定数据
    dispatch_sync(concurrent_queue, ^{
        obj = [userCenterDic objectForKey:key];
    });
    return obj;
}
// 写
- (void)setObject:(id)obj forKey:(NSString *)key{
    // 异步栅栏调用设置数据
    dispatch_barrier_async(concurrent_queue, ^{
        [self->userCenterDic setObject:obj forKey:key];
    });
}

@end
