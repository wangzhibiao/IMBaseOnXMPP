//
//  ChatViewController.h
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/27.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPFramework/XMPPFramework.h>

@interface ChatViewController : UIViewController

/**
 聊天对象的id
 */
@property (nonatomic, strong) XMPPJID *userJbid;


@end
