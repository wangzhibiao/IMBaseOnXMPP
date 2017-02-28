//
//  ManagerXMPP.m
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/26.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import "ManagerXMPP.h"
#import "Commom.h"

@interface ManagerXMPP() <XMPPStreamDelegate, XMPPRosterDelegate>

@end

@implementation ManagerXMPP

#pragma MARK: - 单例模式
static ManagerXMPP *shared;
+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [ManagerXMPP new];
    });
    
    return shared;
}

#pragma MARK: - 懒加载
// 通信管道
- (XMPPStream *)xmppStream
{
    if (_xmppStream == nil){
        
        // 设置xmpstream
        _xmppStream = [[XMPPStream alloc] init];
        
        // 设置属性
        _xmppStream.hostName = localhost;
        _xmppStream.hostPort = portNo.intValue;
        
        // 添加代理
       [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
    }
    
    return _xmppStream;
}

// 重新连接
- (XMPPReconnect *)xmppReconnect
{
    if (_xmppReconnect == nil){
        _xmppReconnect = [[XMPPReconnect alloc] init];
        
        _xmppReconnect.reconnectTimerInterval = 5;
    }
    return _xmppReconnect;
}

// 获取好友信息 从coredata中
- (XMPPRoster *)xmppRostor
{
    if (_xmppRostor == nil){
    
        _xmppRostor = [[XMPPRoster alloc] initWithRosterStorage:[XMPPRosterCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_global_queue(0, 0)];
        
        // 设置属性
        _xmppRostor.autoFetchRoster = YES;
        _xmppRostor.autoClearAllUsersAndResources = YES;
        _xmppRostor.autoAcceptKnownPresenceSubscriptionRequests = NO;
        
        // 设置代理
        [_xmppRostor addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return  _xmppRostor;
}

// 接收消息
- (XMPPMessageArchiving *)messageArchiving
{
    if (_messageArchiving == nil){
    
        _messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:[XMPPMessageArchivingCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_global_queue(0, 0)];
        
    }
    return  _messageArchiving;
}

/** 个人信息模块 */
- (XMPPvCardTempModule *)xmppvCardTempModule
{
    if (_xmppvCardTempModule == nil){
        _xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:[XMPPvCardCoreDataStorage sharedInstance] dispatchQueue:dispatch_get_main_queue()];
    }
    return _xmppvCardTempModule;
}

/** 其它人的信息模块 */
- (XMPPvCardAvatarModule *)xmppvCardAvatarModule
{
    if (_xmppvCardAvatarModule == nil){
    
        _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCardTempModule dispatchQueue:dispatch_get_main_queue()];
    }
    return  _xmppvCardAvatarModule;
}

// 激活所有功能
- (void)activityALL{
    
    [self.xmppReconnect activate:self.xmppStream];
    [self.xmppRostor activate:self.xmppStream];
    [self.messageArchiving activate:self.xmppStream];
    [self.xmppvCardAvatarModule activate:self.xmppStream];
    [self.xmppvCardTempModule activate:self.xmppStream];
}


#pragma MARK: - 所有方法
// 登陆方法
- (void)loginWithJID:(XMPPJID *)myJID andPwd:(NSString *)pwd
{

    // 保存密码
    self.password = pwd;
    // 设置jid
    [self.xmppStream setMyJID:myJID];
    // 链接
    [self.xmppStream connectWithTimeout:-1 error:nil];
    
    // 激活所有功能
    [self activityALL];
}

// 通过代理监听链接服务器结果
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"******* 链接成功了 *********");
    // 验证用户信息
    [self.xmppStream authenticateWithPassword:self.password error:nil];
}

- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"******* 链接失败了 *********");
}


// 通过代理获取印证的结果
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    // 这里验证成功 设置用户的出席状态 并发送给服务器
    XMPPPresence *presence = [XMPPPresence new];
    
    // 设置状态
    DDXMLNode *node = [DDXMLNode elementWithName:@"show" stringValue:@"dnd"];
    [presence addChild:node];
    // 自定义状态描述
    DDXMLNode *custom = [DDXMLNode elementWithName:@"status" stringValue:@"心情不好 谢绝打扰！"];
    [presence addChild:custom];
    
    // 发送给服务器
    [self.xmppStream sendElement:presence];
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    // 验证失败
    NSLog(@"%@", error);
}



// 监听消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    // 获取到消息 进行本地提示
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    
    [noti setAlertBody:message.body];
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:noti];
}




@end
