//
//  FriendsTableViewController.m
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/26.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import "FriendsTableViewController.h"
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ManagerXMPP.h"
#import "ChatViewController.h"

@interface FriendsTableViewController () <NSFetchedResultsControllerDelegate, XMPPRosterDelegate,XMPPvCardAvatarDelegate>

// 查询coreData用到的查询控制器
@property (nonatomic, strong) NSFetchedResultsController *fetchResultsController;

// 好友列表数组
@property (nonatomic, strong) NSArray *friendsArray;


@end

@implementation FriendsTableViewController


// lazy load
- (NSFetchedResultsController *)fetchResultsController
{
    if (_fetchResultsController == nil ){
        
        // 查询请求
        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        
        // 实体
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext: [XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext];
        req.entity = entity;
        
        // 谓词 必须两人互为好友
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"subscription = %@",@"both"];
        req.predicate = pred;
        
        // 排序
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];
        req.sortDescriptors = @[sort];
        
        // 实例搜索控制器
        _fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:req managedObjectContext:[XMPPRosterCoreDataStorage sharedInstance].mainThreadManagedObjectContext sectionNameKeyPath:nil cacheName:@"friends"];
        
        // 设置代理 当数据更改的时候获取
        _fetchResultsController.delegate = self;
        
    }
    
    return _fetchResultsController;
}


- (NSArray *)friendsArray
{
    if (_friendsArray == nil){
    
        _friendsArray = [NSArray array];
    }
    
    return _friendsArray;
}





- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册代理监听好友的资料修改
    [[ManagerXMPP shared].xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 好友模块注册代理
    [[ManagerXMPP shared].xmppRostor addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
   // 执行查询
    [self.fetchResultsController performFetch:nil];
    
    // 获取数据
    self.friendsArray = self.fetchResultsController.fetchedObjects;

    // 刷新表格
    [self.tableView reloadData];
    
    
}


// 查询控制器代理方法 当coredata 数据发送变化会屌用
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 获取最新数据
    self.friendsArray = self.fetchResultsController.fetchedObjects;
    // 刷新表格
    [self.tableView reloadData];
}

#pragma MARK: - 好友资料修改监听
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid
{
    [self.tableView reloadData];
}



// 添加好友
- (IBAction)addFriends:(id)sender {
    
    // 使用好友的功能模块
    [[ManagerXMPP shared].xmppRostor addUser:[XMPPJID jidWithUser:@"lisi" domain:@"local" resource:nil] withNickname:nil];
}

// 监听🏠好友返回结果
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{

    // 要同意之后才互为好友
    [[ManagerXMPP shared].xmppRostor acceptPresenceSubscriptionRequestFrom:[XMPPJID jidWithUser:@"lisi" domain:@"local" resource:nil] andAddToRoster:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.friendsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"haoyoucell" forIndexPath:indexPath];
    
    
    // 用户
    XMPPUserCoreDataStorageObject *user = self.friendsArray[indexPath.row];
    // 设置头像 昵称 等属性
    UILabel *name = [cell viewWithTag:1002];
    name.text = user.nickname;
    
    UILabel *desc = [cell viewWithTag:1003];
    desc.text = user.jidStr;
    
    UIImageView *icon = [cell viewWithTag:1001];
    NSData *imgData = [[ManagerXMPP shared].xmppvCardAvatarModule photoDataForJID: user.jid];
    icon.image = [UIImage imageWithData:imgData];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

// 删除好有
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 如果是删除style 就删除好友
    if (editingStyle == UITableViewCellEditingStyleDelete){
        // 获取好友信息
        XMPPUserCoreDataStorageObject *user = self.friendsArray[indexPath.row];
        
        // 删除
        [[ManagerXMPP shared].xmppRostor removeUser:user.jid];
    }
}



// 执行跳转的时候传递jid
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    // 数据
    XMPPUserCoreDataStorageObject *user = self.friendsArray[[self.tableView indexPathForCell:sender].row];

    // 目标控制器
    ChatViewController *chatVC = segue.destinationViewController;
    chatVC.userJbid = user.jid;
}

@end
