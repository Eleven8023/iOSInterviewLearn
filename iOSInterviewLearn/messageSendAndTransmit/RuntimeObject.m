//
//  RuntimeObject.m
//  Highlevel
//
//  Created by Eleven on 2018/11/5.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "RuntimeObject.h"
#import <objc/runtime.h>
@implementation RuntimeObject

//+ (void)load{
//    // 获取test方法
//    Method test = class_getInstanceMethod(self, @selector(test));
//    // 获取otherTest方法
//    Method test1 = class_getInstanceMethod(self, @selector(otherTest));
//    // 交换
//    method_exchangeImplementations(test, test1);
//
//}
//
//-(void)test{
//    NSLog(@"这是方法1");
//}

-(void)otherTest{
    [self otherTest];//实际是调用test 不会产生循环引用 和死循环
    NSLog(@"这是方法2");
}

void testIMP (void){
    NSLog(@"test invoke");
}

// 消息转发第一步  可以在这一步动态添加test方法
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    // 如果是test方法 打印日志
    if (sel == @selector(test)) {
        NSLog(@"resolveInstanceMethod:");

        // 动态添加方法  此时解决实例方法的调用 此时应该返回Yes  
        class_addMethod(self, @selector(test), testIMP, "v@:");

        return false;
    }else{
        return [super resolveInstanceMethod:sel];
    }
}
// 第二步
- (id)forwardingTargetForSelector:(SEL)aSelector{
    NSLog(@"forwardingTargetForSelector:");
    return nil;
}
// 第三步
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    if (aSelector == @selector(test)) {
        NSLog(@"methodSignatureForSelector:");
        // v 代表返回值是void类型 @代表第一个参数类型是id 即self
        // : 代表第二个参数是SEL类型的 即@selector(test)
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }else{
        return [super methodSignatureForSelector:aSelector];
    }
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"forwardInvocation:");
}

@end
