//
//  XMPPMUCManager.m
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/28.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import "XMPPMUCManager.h"
#import "ManagerXMPP.h"

@interface XMPPMUCManager() <XMPPRoomDelegate, XMPPMUCDelegate>

/** 保存room */
@property (nonatomic, strong) NSMutableDictionary *roomDict;


@end

/** 群聊管理器 */
@implementation XMPPMUCManager

#pragma mark  单例模式
static XMPPMUCManager *instance;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [XMPPMUCManager new];
    });
    return instance;
}

#pragma mark - 懒加载属性
- (XMPPMUC *)xmppMUC
{
    if (_xmppMUC == nil){
        _xmppMUC = [[XMPPMUC alloc] initWithDispatchQueue:dispatch_get_main_queue()];
        
        // 设置代理
        [_xmppMUC addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // 激活
        [_xmppMUC activate:[ManagerXMPP shared].xmppStream];
    }
    return _xmppMUC;
}

- (XMPPRoom *)xmppRoom
{
    if (_xmppRoom == nil) {
        _xmppRoom = [[XMPPRoom alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    }
    
    return _xmppRoom;
}

/** 存放room的字典 */
- (NSMutableDictionary *)roomDict
{
    if (_roomDict == nil) {
        _roomDict = [NSMutableDictionary dictionary];
    }
    return _roomDict;
}




#pragma mark - 加入或者创建聊天室
- (void)jionOrCreateMUCRoomWithNikeName:(NSString *)nikeName andRoomJid:(NSString *)roomJid
{
    // 设置参数
    XMPPJID *jid = [XMPPJID jidWithUser:roomJid domain:@"qunliao1.local" resource:nil];
    XMPPRoomCoreDataStorage *storage = [XMPPRoomCoreDataStorage sharedInstance];
    
    // 创建房间
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:storage jid:jid dispatchQueue:dispatch_get_main_queue()];
    // 代理
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // 激活
    [room activate:[ManagerXMPP shared].xmppStream];
    
    // 存入字典
    self.roomDict[roomJid] = room;
    
    // 加入房间
    [room joinRoomUsingNickname:nikeName history:nil];
}


#pragma mark - 聊天室等代理方法
/**  如果房间不存在会先创建房间，房间存在的就直接进入 */
- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    
    NSLog(@"*****进入了房间 - %@*******", sender.roomJID.bare);
    // 邀请一个人看看
//    XMPPJID *jid = [XMPPJID jidWithUser:@"lisi" domain:@"local" resource:nil];
//    [sender inviteUser:jid withMessage:@"过来聊天啦！"];
    
    // 发送一句话让群聊显示在最近联系人界面
    XMPPMessage *msg = [XMPPMessage messageWithType:@"groupchat" to:sender.roomJID];
    [msg addBody: @"嗨！我刚刚创建了一个群聊天室！"];
    // send
    [[ManagerXMPP shared].xmppStream sendElement:msg];

}

/** 房间被创建了， 要出实话配置后才能邀请别人进来 可以使用默认的初始化 */
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"*****创建了房间 - %@*******", sender.roomJID.bare);
    // 默认配置
    [sender configureRoomUsingOptions:nil];
    // 下面的方法会输出服务器配置表单
    [sender fetchConfigurationForm];
    
}


#pragma mark - xmppmuc 代理方法



@end
