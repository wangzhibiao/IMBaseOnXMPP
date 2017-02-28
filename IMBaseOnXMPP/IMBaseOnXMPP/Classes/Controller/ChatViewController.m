//
//  ChatViewController.m
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/27.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import "ChatViewController.h"
#import <CoreData/CoreData.h>
#import "ManagerXMPP.h"
#import "UITableView+Category.h"

@interface ChatViewController ()<NSFetchedResultsControllerDelegate, UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate,XMPPvCardAvatarDelegate>


/**
 聊天的列表
 */
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

/**
 输入消息的文本框
 */
@property (weak, nonatomic) IBOutlet UITextField *messageText;

/** 聊天消息数组 */
@property (nonatomic, strong) NSArray *chatArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomConst;

/** 获取消息控制器 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultController;


@end

@implementation ChatViewController

/** 懒加载 */
//- (XMPPJID *)userJbid
//{
//    if (_userJbid == nil){
//        _userJbid = [XMPPJID new];
//    }
//    return _userJbid;
//}

- (NSArray *)chatArray
{
    if (_chatArray == nil){
        _chatArray = [NSArray array];
    }
    return _chatArray;
}

- (NSFetchedResultsController *)fetchedResultController
{
    if (_fetchedResultController == nil) {
        
        // 请求
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        // 参数设置
        NSManagedObjectContext *context = [XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext;
        
        // 实体
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
        request.entity = entity;
        
        // 谓词
        request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr=%@", self.userJbid.bare];
        
        // 排序 根据时间生序
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
        request.sortDescriptors = @[sort];
        
        
        // 获取消息控制器
        _fetchedResultController = [[NSFetchedResultsController alloc]
                                                            initWithFetchRequest:request
                                                                                                  managedObjectContext:context sectionNameKeyPath:nil cacheName:@"messages"];
        // 获取结果监听
        _fetchedResultController.delegate = self;
        
    }
    return _fetchedResultController;
}


#pragma MARK: - 页面加载进来 加载数据
- (void)viewDidLoad {
    [super viewDidLoad];

    // 标题
    self.title = self.userJbid.bare;
    
    // 监听好友的资料更改
    [[ManagerXMPP shared].xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 清楚缓存
    [NSFetchedResultsController deleteCacheWithName:@"messages"];
    
    [self.fetchedResultController performFetch:nil];
    self.chatArray = self.fetchedResultController.fetchedObjects;
    [self.chatTableView reloadData];

    // 这里不知道为什么，貌似屌用滚动方法等时候，tableview还没有加载完数据所以要延时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 滚动到底部
        [self.chatTableView scrollsToBottom];
    });
   
    
}


#pragma MARK: - 好友资料更改方法
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid
{
    [self.chatTableView reloadData];
}



#pragma MARK: - 查询控制器查询结果
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    // 获取数据
    self.chatArray = self.fetchedResultController.fetchedObjects;
    // 刷新列表
    [self.chatTableView reloadData];
    
    // 滚动到底部
    [self.chatTableView scrollsToBottom];
    
}


#pragma MARK: - 内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma MARK: - tableview的代理和数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.chatArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 根据信息的id 来判断是自己发的还是别人发的
    XMPPMessageArchiving_Message_CoreDataObject *msg = self.chatArray[indexPath.row];
    NSString *ID = msg.isOutgoing ? @"right_cell" : @"left_cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    // 设置cell
    UILabel *text = [cell viewWithTag:1002];
    text.text = msg.body;
    
    // 设置名字合头像
    UILabel *name = [cell viewWithTag:1003];
    UIImageView *icon = [cell viewWithTag:1001];
    if (msg.isOutgoing){
        // 好友
        name.text = msg.bareJidStr;
        NSData *data = [[ManagerXMPP shared].xmppvCardAvatarModule photoDataForJID:msg.bareJid];
        icon.image = [UIImage imageWithData:data];
        
    }else { // 自己
    
        XMPPJID *jid = [ManagerXMPP shared].xmppStream.myJID;
        name.text = jid.bare;
        NSData *data = [[ManagerXMPP shared].xmppvCardAvatarModule photoDataForJID:jid];
        icon.image = [UIImage imageWithData:data];

    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}




#pragma MARK: - 键盘处理
// 滚动表格 隐藏键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.messageText endEditing:YES];
}

#pragma MARK: - 发送消息
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 发送消息
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.userJbid];
    [msg addBody:textField.text];
    [[ManagerXMPP shared].xmppStream sendElement:msg];
    
    self.messageText.text = @"";
    [self.messageText endEditing:YES];
    
    [self.chatTableView reloadData];
    
    return YES;
}







@end
