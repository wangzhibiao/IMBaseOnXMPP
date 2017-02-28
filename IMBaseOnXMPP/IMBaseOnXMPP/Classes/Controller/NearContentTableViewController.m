//
//  NearContentTableViewController.m
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/28.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import "NearContentTableViewController.h"
#import <CoreData/CoreData.h>
#import "ManagerXMPP.h"
#import "ChatViewController.h"
#import "XMPPMUCManager.h"

@interface NearContentTableViewController ()<NSFetchedResultsControllerDelegate,XMPPvCardAvatarDelegate>

/** 查询控制器 */
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultController;
/** 最近联系人数组*/
@property (nonatomic, strong) NSArray *nearArray;


@end

@implementation NearContentTableViewController

#pragma MARK: - 懒加载查询控制器
- (NSFetchedResultsController *)fetchedResultController
{
    if (_fetchedResultController == nil) {
        
        // 查询请求
        NSFetchRequest *request = [NSFetchRequest new];
        // 上下文
        NSManagedObjectContext *context = [XMPPMessageArchivingCoreDataStorage sharedInstance].mainThreadManagedObjectContext;
        // 实体
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Contact_CoreDataObject" inManagedObjectContext:context];
        request.entity = entity;
        
        // 谓词
        
        // 排序
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:NO];
        request.sortDescriptors = @[sort];
        
        // 常见查询控制器
        _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:@"content"];
        
        // 设置代理
        _fetchedResultController.delegate = self;
        
        
    }
    return _fetchedResultController;
}

/** 最近联系人数组懒加载 */
- (NSArray *)nearArray
{
    if (_nearArray == nil) {
        _nearArray = [NSArray array];
    }
    return _nearArray;
}





#pragma MARK: - 界面初始化方法
- (void)viewDidLoad {
    [super viewDidLoad];
 
    // 设置代理 监听资料更改
    [[ManagerXMPP shared].xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 避免coredata的缓存太多出错
    [NSFetchedResultsController deleteCacheWithName:@"content"];
    // 请求数据
    [self.fetchedResultController performFetch:nil];
    self.nearArray = self.fetchedResultController.fetchedObjects;
    [self.tableView reloadData];
}





#pragma MARK: - 系统内存警告
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma MARK: - 查询控制器代理方法
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 接收到消息 排序 然后刷新表格
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"mostRecentMessageTimestamp" ascending:NO];
    self.nearArray = [controller.fetchedObjects sortedArrayUsingDescriptors:@[sort]];
    // 刷新数据
    [self.tableView reloadData];
}

#pragma MARK: - 监听别人的资料修改方法
- (void)xmppvCardAvatarModule:(XMPPvCardAvatarModule *)vCardTempModule didReceivePhoto:(UIImage *)photo forJID:(XMPPJID *)jid
{
    // 重写加载tableview
    [self.tableView reloadData];
}



#pragma MARK: - tableview的代理和数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.nearArray.count;
}

#pragma mark - tableview 代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 获取联系人数据
    XMPPMessageArchiving_Contact_CoreDataObject *contact = self.nearArray[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"near_cell" forIndexPath:indexPath];
    
    // 设置cell信息
    // icon
    UIImageView *icon = [cell viewWithTag:1001];
    NSData *data;
    if ([contact.bareJidStr containsString:@"@local"]){// 单聊
          data = [[ManagerXMPP shared].xmppvCardAvatarModule photoDataForJID:contact.bareJid];
            icon.image = [UIImage imageWithData:data];
    }else{
        // 群聊
        icon.image = [UIImage imageNamed:@"groupchat"];
    }

    // name
    UILabel *name = [cell viewWithTag:1002];
    name.text = contact.bareJidStr;
    // last contact
    UILabel *lastcontact = [cell viewWithTag:1003];
    lastcontact.text = contact.mostRecentMessageBody;
    
    
    
    return cell;
}

/** 行高 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - 执行跳转到聊天界面
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)sender
{
    // 获取跳转控制器
    ChatViewController *chatVC = segue.destinationViewController;
    
    // 获取数据
    XMPPMessageArchiving_Contact_CoreDataObject *contact = self.nearArray[[self.tableView indexPathForCell:sender].row];
    
    // 传递jid
    chatVC.userJbid = contact.bareJid;
}

#pragma mark - 创建群聊
- (IBAction)joinOrCreateMUCRoom:(id)sender {
    
    [[XMPPMUCManager sharedManager] jionOrCreateMUCRoomWithNikeName:@"开心聊天群" andRoomJid:@"qunliao"];
    
}



@end
