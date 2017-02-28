//
//  ManagerXMPP.h
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/26.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>

@interface ManagerXMPP : NSObject


// STREAM
@property (nonatomic, strong) XMPPStream *xmppStream;
// password
@property (nonatomic, copy) NSString *password;
// auto reconnect
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
// 获取好友信息
@property (nonatomic, strong) XMPPRoster *xmppRostor;
// 消息
@property (nonatomic, strong) XMPPMessageArchiving *messageArchiving;
// 个人信息模块
@property (nonatomic, strong) XMPPvCardTempModule *xmppvCardTempModule;
// 其它人信息管理模块
@property (nonatomic, strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;






// 单例方法
+ (instancetype)shared;


// 登陆犯法
- (void)loginWithJID:(XMPPJID *)myJID andPwd:(NSString *)pwd;

@end
