//
//  RunLoop.m
//  Highlevel
//
//  Created by Eleven on 2018/11/11.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "RunLoop.h"

/*
 RunLoop  概念  数据结构  事件循环机制  RunLoop与NSTimer  RunLoop与多线程
 * 什么是RunLoop?  runloop是通过内部维护的事件循环来对事件/消息进行管理的一个对象;  事件循环:  没有消息需要处理时, 休眠以避免资源占用, 有消息需要处理时, 立刻被唤醒.
 Event Loop  没有消息需要处理时, 休眠以避免资源占用;  用户态 -- >  内核态;  有消息需要处理时, 立刻被唤醒; 内核态-->用户态
main函数为什么保证不退出?
 程序 int main() { 执行体 }, 其实是一个runloop  可以不断的接收消息, 对事件处理, 处理完后后进入等待状态, 完成内核态和用户态的相互切换;
 总结: 在main函数中调用的UIApplicationMain会启动主线程的Runloop, 而是对事件循环的一种机制, 有事情的时候去做事, 没事的时候完成用户态到内核态的切换, 休眠以避免资源占用, 当前线程处于休眠状态;
 *RunLoop的数据结构
 NSRunLoop  CFRunLoop  NSRunLoop是对CFRunLoop的封装, 提供了面向对象的API
   1, CFRunLoop  (pthread, currentMode, modes<NSMutableSet>CFRunLoopMode, commonModes<NSMutableSet>NSString, commonModeItems<NSMutableSet>Observe, Timer, Source)
   2, CFRunLoopMode(name <NSDefaultRunLoopMode>, sources0 <NSMutableSet>, sources1, observers<NSMutableArray>, timers)
    3,Source/Timer/Observer

 CFRunLoopSource(source0(需要手动唤醒线程, 从内核态切入到用户态), source1(具备唤醒线程的能力))
 CFRunLoopTimer: 基于事件的定时器, 和NSTimer是toll-free bridge的
 CFRunLoopObserver: 观测时间点, 可以监测那些时间点,  1, kCFRunLoopEntry  2, kCFRunLoopBeforeTimers  3, kCFRunLoopBeforSource  4, kCFRunLoopBeforeWaiting(进入休眠)  5,kCFRunLoopAfterWaiting  6, KCFRunLoopExit
 各个数据结构之间的关系: 线程和RunLoop之间是一一对应的,  RunLoop和Model之间是一对多的关系, Mode和source, timer, observer之间也是一对多的
 RunLoop的Mode

 CommonMode的特殊性, NSRunLoopCommonModes, 1, CommonMode不是实际存在的一种Mode  2, 是同步Source/Timer/Observer到多个mode中的一种技术方案

 RunLoop事件循环的实现机制
 void  CFRunLoopRun()    即将进入RunLoop-> 通知Observer--> 将要处理timer/source0事件--> 处理source0事件-->如果有source1要处理(没有休眠, 休眠等待唤醒(唤醒条件, 1, source1, timer, 外部手动))-->处理唤醒时收到的消息->RunLoop退出

 RunLoop的核心  main(){  -> mash_msg() 用户态 -系统调用mash_msg() 核心态-> 用户态}

 RunLoop与NSTimer
 滑动TableView的时候我们的定时器还会生效吗?  正常RunLoop是在kCFRunLoopDefaultMode模式下  在TableView滑动的时候会发生Mode的切换  切换到UITrackingRunLoopMode模式下, 这时候Timer就不会生效了,  可以通过void CFRunLoopAddTimer(runLoop, timer, commonMode)方式解决, 可以将source源 timer同步添加到多个mode上
 * RunLoop与多线程
 线程是和RunLoop一一对应的,  线程中所对应的RunLoop默认是没有创建的
 怎样实现一个常驻线程?
 1, 为当前线程开启一个RunLoop (CFRunLoopGetCurrent()) 2, 向该RunLoop中添加一个Port/Source等维持RunLoop的事件循环 () 3, 启动RunLoop
 *
 *总结: 什么是RunLoop , 怎样做到有事做事没事休息的? 一个事件循环处理事件和消息, 以及对其的管理; 调用CFRunloopRun相关方法后会调用系统函数mash_msg, 用户态h向核心态状态切换, 当前线程处于休眠状态;
 RunLoop与线程的关系?  runloop和线程是一一对应, 一个线程默认是没有RunLoop的我们要手动创建
 如何实现一个常驻线程?  创建RunLoop, 添加事件源, 调用run方法(注意:运行的模式和资源添加的模式必须是同一个模式, 否则内部实现while循环会产生死循环)
 怎样保证子线程数据回来更新UI的时候不打断用户的滑动操作? 把子线程抛回给主线程更新UI的时候, 提交到主线程的Default模式下, 抛回来的任务, 当前UITraitingmode下不会触发, 当滑动停止滑动之后切换到defalut模式下, 将子线程的任务提交到主线程, 不会打断主线程的滑动操作;
 *
 */

// 常驻线程实现
@interface RunLoop ()

@end

@implementation RunLoop
static NSThread *thread = nil;
//标记是否要继续事件循环
static BOOL runAlways = YES;

+(NSThread *)threadForDispatch{
    if (thread == nil) {
        @synchronized (self) {
            if (thread == nil) {
                // 线程创建
                thread = [[NSThread alloc] initWithTarget:self selector:@selector(runRequest) object:nil];
                [thread setName:@"mythread"];
                // 线程启动
                [thread start];
            }
        }
    }
    return thread;
}

+ (void )runRequest{
    // 创建一个source
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    // 创建RunLoop, 同时向RunLoop的DefaultMode下面添加source
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    // 如果可以运行
    while (runAlways) {
        @autoreleasepool {
            // 命令当前RunLoop运行在DefaultMode下面
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, true);
        }
    }

    // 某一时机, 静态变量runAlways = No 时, 可以保证跳出RunLoop, 线程退出
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
}

@end
