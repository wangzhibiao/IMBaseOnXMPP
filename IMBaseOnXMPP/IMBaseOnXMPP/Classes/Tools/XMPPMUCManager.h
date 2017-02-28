//
//  XMPPMUCManager.h
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/28.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>

@interface XMPPMUCManager : NSObject

/** 群聊功能*/
@property (nonatomic, strong) XMPPMUC *xmppMUC;
/** 群聊房间 */
@property (nonatomic, strong) XMPPRoom *xmppRoom;




/** 单例模式 */
+ (instancetype)sharedManager;

/** 加入|创建聊天室 */
- (void)jionOrCreateMUCRoomWithNikeName:(NSString *)nikeName andRoomJid:(NSString *)roomJid;

@end
