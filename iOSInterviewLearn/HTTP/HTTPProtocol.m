//
//  HTTPProtocol.m
//  Highlevel
//
//  Created by Eleven on 2018/11/12.
//  Copyright © 2018 Eleven. All rights reserved.
//

#import "HTTPProtocol.h"
/*
 * HTTP协议,  HTTPS与网络安全, TCP/UDP  DNS解析  Session / Cookie
 * HTTP:  超文本传输协议  1, 请求.响应报文,  2, 链接建立流程 3, 特点
 请求报文: 格式: 方法  URL  协议版本  CRLF   头部字段, 首部字段名: 值  CRLF ,  实体主体
 响应报文: 版本 状态码 短语 CRLF   首部字段名:值  CRLF  实体主体
 http的请求方式都有哪些?  GET POST  HEAD  PUT DELETE OPTIONS
 GET POST的方式区别?  1,get请求参数以?分割拼接到URL后面, POST请求参数在Body里面 2, get参数长度限制2048个字符, post一般没有该限制 3, get请求不安全, post请求比较安全;
 标注答案 --- >  从语义的角度来回答   GET: 获取资源  要遵循  安全的 幂等的  可缓存的;  POST: 处理资源  不安全的 不幂等的  不可缓存的;
 安全性: 不引起server端的任何状态变化  GET HEAD OPTIONS
 幂等性: 用一个请求方法执行多次和执行一次的效果完全相同  PUT DELETE
 可缓存性: 请求是否可以被缓存  GET HEAD
 状态码:  都了解哪些状态码? 其含义? 1xx  2xx  3xx(重定向)  4xx(客户端请求本身存在问题)  5xx(server端有异常)
 连接建立流程: TCP三次握手   Client   --同步报文-> Server  --返回TCP报文> Client --> server   开始请求   四次挥手

 HTTP的特点:  1, 无连接, HTTP的持久连接  2, 无状态, Cookie/Session
 持久连接: 提升网络响应的效率提供的方案;  持久连接的头部字段:Connection: keep-alive  time:20 (持续有效时间)  max:10(最多可以发生http请求响应对)
 怎样判断一个请求是否结束? 1, Content-length: 1024(字节数)  2, chunked, 最后会有一个空的chunked
 Charles抓包原理是怎样的?  (中间人攻击漏洞实现的)  Client  <---->  Server  代理服务器  当客户端发送请求的时候, 代理服务器拦截然后假冒客户端去Server端请求, server反应数据给代理服务器
 *HTTPS与网络安全
 HTTPS和HTTP有怎样的区别?  https = http + ssl/tls   https是在原有的应用层http,  在应用层和传输层之间插入SSL/TLS这样的协议中间层, 实现安全的网络机制
 HTTPS连接建立流程是怎样的?

 会话秘钥 = random S + random C + 预主秘钥
 HTTPS都使用了那些加密手段?  为什么?   1, 连接建立过程使用的是非对称加密, 非对称加密很耗时的(公钥私钥) 2, 数据通信传输过程使用对称加密
 非对称加密: 加密和解密使用秘钥是不同的, 加密和解密的方式是不同的
 对称加密: 加密和解密的秘钥是相同的(缺点需要TCP连接, 会产生中间人劫持)
 *TCP/UDP
 传输层协议:1, TCP 传输控制协议 2, UDP 用户数据报协议
 UDP(用户数据报协议): 特点: 无连接(不需要事先建立好连接),  尽最大努力交付,  面向报文(既不合并, 也不拆分)
 功能: 复用 分用   差错检测
 复用 分用:
 差错检测:
 面向报文:

 TCP传输控制协议:  特点:  1 面向连接   2 可靠传输   3 面向字节流  4 流量控制  5 拥塞控制
 面向连接:  数据传输开始之前, 需要建立连接,  数据传输结束之后, 需要释放连接;
 为什么要发生三次握手?  实际解决同步请求连接建立的报文超时场景
 可靠传输: 无差错  不丢失  不重复  按序到达
 停止等待协议: 1 无差错情况  2, 超时重传  3, 确认丢失 4,  确认迟到
 面向字节流:
 流量控制:  滑动窗口协议(发送方发送数据可能由于接收方的接收窗口很小, 发送方窗口很大, 发的速率很快, 此时接收方向发送方TCP报文首部字段中添加协议修改发送方的窗口值, 调整发送端的发送速率)
 拥塞控制:  1,慢开始, 拥塞避免  2 快恢复, 快重传
 *DNS: 了解DNS解析吗? 怎样的过程?
 域名到IP地址的映射, DNS解析请求采用UDP数据报, 且明文
 DNS解析查询方式: 1, 递归查询  (我去给你问一下)2, 迭代查询  (我告诉你谁可能知道)
 DNS解析存在哪些常见问题?  1, DNS劫持问题  2,  DNS解析转发问题
 DNS劫持?
 DNS劫持与HTTP的关系是怎样的? 完全没有关系  因为DNS解析发生在HTTP建立连接之前   DNS解析请求使用UDP数据报  端口号53
 DNS解析转发?
 怎样解决DNS劫持
 1,  httpDNS   2, 长连接
 httpDNS:  正常是使用DNS协议向DNS服务器的53端口进行请求,  使用httpDNS是使用HTTP协议向DNS服务器的80端口进行请求
 长连接:
 Session  / Cookie
 HTTP协议无状态特点的补偿
 Cookie主要是用来记录用户状态, 区分用户; 状态保存在客户端;
 客户端发送的cookie在http请求报文的Cookie首部字段中
 服务器端设置http响应报文的Set-Cookie首部字段
 怎样修改Cookie?  1, 新的cookie覆盖旧cookie 2, 覆盖规则: name, path, domain等需要与原cookie一致
 怎样删除Cookie?  1, 新的cookie覆盖旧cookie 2, 覆盖规则: name, path, domain等需要与原cookie一致 3, 设置cookie的expires=过去的一个时间点, 或者maxAge=0
 怎样保证Cookie的安全? 1, 对cookie进行加密处理  2, 只在https上携带Cookie  3, 设置cookie为httpOnly, 防止跨站脚本攻击

 Session: 也是记录用来记录用户状态的, 区分用户的; 状态存放在服务器端
 session和cookie的联系?  seesion需要依赖cookie机制实现
 session工作流程
 *
 总结:  1, http中的GET和POST有什么区别?
 2,  HTTPS链接建立流程是怎样的?   客户端会给服务端发送支持的加密列表, TLS版本号,  服务端回给客户端证书, 商定的加密算法, 首先通过非对称加密进行对称秘钥的传输, 之后http网络请求通过被非对称加密保护的对称秘钥网络访问
 3, TCP和UDP有什么区别?  TCP是面向连接的  支持可靠传输, 面向字节流, 提供流量控制和拥塞控制; UDP提供了简单复用分用差错检测的基本传输层功能, UDP是无连接的
 4, 请简述TCP的慢开始过程? 慢开始拥塞算法的角度
 5, 客户端怎样避免DNS劫持?  httpDNS 长连接 
 *
 */
@implementation HTTPProtocol

@end
