//
//  AppDelegate.m
//  iOSInterviewLearn
//
//  Created by 李赐岩 on 2018/11/13.
//  Copyright © 2018 李赐岩. All rights reserved.
//

#import "AppDelegate.h"
#import "ELObject.h"
#import "ELObserve.h"
#import "RuntimeObject.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    ELObject *obj = [[ELObject alloc] init];
    ELObserve *obs = [[ELObserve alloc] init];
    
    // 调用kvo监听
    [obj addObserver:obs forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:NULL];
    // 修改value的值
    obj.value = 1;
    // 1. 通过kvc设置value能否生效
    [obj setValue:@2 forKey:@"value"];
    // 2. 通过成员变量直接赋值value能否生效
    [obj increase];  // 无法生效  可以通过手动触发KVO方式x实现
    
    RuntimeObject *obj1 = [[RuntimeObject alloc] init];
    // 调用test 方法 只有声明 没有实现
    [obj1 test];
    // x总结  kvo生效的方式  1, 使用setter方法改变值  2, 使用setvalue:forKey;   使用成员变量修改不会生效, 可以手动触发KVO
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
