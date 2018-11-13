//
//  MessageSendViewController.m
//  Highlevel
//
//  Created by Eleven on 2018/11/5.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "MessageSendViewController.h"

@interface MessageSendViewController ()

@end
/**
 *  消息传递  void objec_msgSend(void id self, SEL op, ...)
 *  [self class]   -- objc_msgSend(self, @selector(class))
 *  void objc_msgSendSuper(void (struct objc_super *super, SEL op, ....))  super 是一个编译器关键字 结构体指针
 *  struct objc_super {
    /// Specifies an instance of a class
 __unsafe_unretained id receiver;  这里receiver指的就是当前对象
 };
    [super class]  --  objc_msgSendSuper(super, @selector(class))
 传递过程:  开始  -- > 缓存是否有值  -- Invoke  --- 结束
    缓存无值  --- 当前类方法列表是否t有值
 *  消息传递流程  当一个方法触发的时候  先会去缓存中d查找如果缓存中有这个方法则直接调用, 如果缓存中没有则去当前q类的方法列表中查找如果有则调用, 没有的话去当前类的父类中z逐一查找 有则调用没有的话 则进入消息转发流程
 *
 *  消息转发
 * 实例方法:  resolveInstanceMethod: 参数 SEL  返回值 Bool  如果返回YES 则消息已经处理  如果返回NO 会调用 forwardingTargetForSelector: 二次消息转发 返回值id
 告诉系统由哪个对象来处理  如果返回nil  则调用methodSignatureForSelector: 第三次消息转发 如果返回方法签名 则调用forwardInvocation:去处理这条消息  如果返回nil 则消息无法处理 所以 程序crash 有时会报未识别选择器报错
 *  Method-Swizzling
 *  交换前  selector1  --- > IMP1 selector2 --- > IMP2  交换后  selector1 -- > IMP2  selector2 -- > IMP1
 *
 *  动态添加方法  美团面试 performSelector: 方法  (实际场景: 可能涉及到类在编译时没有这个方法, 在运行时才有这个方法)  实质a考察runtime动态添加方法的特性
 动态方法解析:  @dynamic  声明的属性在实现的时候 标记为@dynamic  实际上是get方法和set方法是在运行t时添加 而不是编译的时候添加  实际是考察编译时语言和动态运行时语言的区别
    1, 动态运行时语言将函数决议推迟到运行时   2, 编译时语言是在编译期进行函数决议的(说明编译期间就确定一个方法名称对应的函数执行体是哪个, 在运行期间无法修改)

Question
 比如 [obj foo]和objc_msgSend()函数之间有什么关系?
 a: 消息传递 在编译器处理处理过程之后就变成了 objc_msgsend()函数, 第一个s参数是obj  第二个是foo SEL 开始runtime消息传递过程
 Q:runtime如何通过Selector找到对应的IMP地址的?  a:先查找缓存 IMP  在查找当前类  在查找superClass  在查找元类
 Q: 能否向编译后的类中增加实例变量? a:不能 已经完成了实例变量 布局  class_ro_t  readOnly  只读的
 Q: 能否向动态添加的类中添加实例变量? a:能  动态添加类的过程中 调用注册类方法之前实现
 *

 * 自动释放池  今日头条: viewDidLoad: NSMutableArray *array = [NSMutableArray array];  其中array内存在什么时机释放的  a: 在当次runloop将要结束的时候调用AutoreleasePopPage::pop()
    Q AutoreleasePool实现原理是怎么样的? 以栈为节点通过双向链表形式组合而成的数据结构
 Q AutoreleasePool 为何可以嵌套使用  a: 多层嵌套就是多次插入哨兵对象

 场景: 在for循环中alloc图片数据等内存消耗较大的场景插入autoreleasePool   每一次都进行内存释放 来降低内存的峰值

 编译器 会改写@autoreleasepool{}为   void *ctx = objc_autoreleasePoolPush();  {}中的代码   objc_autoreleasePoolPop(txt)
 objc_autoreleasePoolPush  --> void *objc_autoreleasePoolPush(void)  -> void *AutoreleasePoolPage::push(void)
 objc_autoreleeasePoolPop -->  void objc_autoreleasePoolPop(void *ctxt)  -- > AutoreleasePoolPage::pop(void *ctxt)

 结构 以栈为结点通过双向链表的形式组合而成的   和线程一一对应
 双向链表:   <---ParentPtr    -->ChildPtr    NULL<--Node <--> Node <--> Node --> NULL
 栈: 向下增长的  下面是高地址  上面是低地址
 AutoreleasePoolPage  成员变量 id *next  AutoreleaePoolPage *const parent  AutoreleasePoolPage *child  pthread_t const thread;
 [obj autorelease]  开始 --> next == 栈顶 ?  是 -- > 增加一个栈结点到链表上  否 -- > add(obj)  结束
 */
@implementation MessageSendViewController

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
