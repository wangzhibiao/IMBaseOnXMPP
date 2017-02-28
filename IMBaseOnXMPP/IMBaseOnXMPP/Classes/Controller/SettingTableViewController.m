//
//  SettingTableViewController.m
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/28.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import "SettingTableViewController.h"
#import "ManagerXMPP.h"
#import "EditorTableViewController.h"

/** 个人信息设置界面 */
@interface SettingTableViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate,XMPPvCardTempModuleDelegate>

/** 头像 */
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
/**
 昵称
 */
@property (weak, nonatomic) IBOutlet UILabel *nikeName;
/**
 个性签名
 */
@property (weak, nonatomic) IBOutlet UILabel *descLable;
/**
 用户账户
 */
@property (weak, nonatomic) IBOutlet UILabel *userJid;


/**
 存储着用户的信息
 */
@property (nonatomic, strong) XMPPvCardTemp *myvCardTemp;


@end

@implementation SettingTableViewController

#pragma MARK: - 懒加载
- (XMPPvCardTemp *)myvCardTemp
{
    if (_myvCardTemp == nil){
    
        // 首次加载 去工具类获取
        _myvCardTemp = [ManagerXMPP shared].xmppvCardTempModule.myvCardTemp;
    }
    return _myvCardTemp;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置代理 监听资料更改
    [[ManagerXMPP shared].xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
 
    // 获取个人信息
    [self loadData];
}



/** 获取个人信息 */
- (void)loadData
{
    // 头像
    NSData *imgData = self.myvCardTemp.photo;
    self.iconImage.image = [UIImage imageWithData:imgData];
    
    // 昵称
    self.nikeName.text = self.myvCardTemp.nickname ? self.myvCardTemp.nickname : @"未设置昵称";
    
    // 签名
    self.descLable.text = self.myvCardTemp.desc ?  self.myvCardTemp.desc :  @"未设置签名";
    
    // 账号
    self.userJid.text = [ManagerXMPP shared].xmppStream.myJID.bare;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma MARK: - 点击cell 进入设置方法
/** 点击用户头像去相册选择照片 */
- (IBAction)clickToPickerImage:(id)sender {
    
    // 打开相册
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    // 设置可以编辑
    imagePicker.allowsEditing = YES;
    
    // 设置代理
    imagePicker.delegate = self;
    // 弹出窗口
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    
    
}

/** 选择照片代理方法 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{

    //获取用户选择的图片
    // UIImagePickerControllerEditedImage 苏略图
    // UIImagePickerControllerOriginalImage 原图
    NSLog(@"info : %@",info);
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    // 获取data
    NSData *imgData = UIImageJPEGRepresentation(image, 0.2);
    
    // 更新头像
    self.myvCardTemp.photo = imgData;
    [[ManagerXMPP shared].xmppvCardTempModule updateMyvCardTemp:self.myvCardTemp];
    
    // 关闭窗口
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

/** 取消选择照片代理方法 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // 关闭控制器
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma MARK: - 资料更改代理方法
- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    // clearn orgin
    self.myvCardTemp = nil;
    // 重写加载
    [self loadData];
}

#pragma MARK: - 跳转传参 区分昵称和签名
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // 获取控制器
    EditorTableViewController *editorVC = segue.destinationViewController;
    
    // 根据id区分
    if ([segue.identifier isEqualToString:@"desc"]){
    
            editorVC.title = @"编辑签名";
            
    }else {// 昵称
    
            editorVC.title = @"编辑昵称";
    }
}


@end
