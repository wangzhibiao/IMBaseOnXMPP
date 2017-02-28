//
//  EditorTableViewController.m
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/28.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import "EditorTableViewController.h"
#import "ManagerXMPP.h"

@interface EditorTableViewController ()

// 编辑框
@property (weak, nonatomic) IBOutlet UITextField *textInput;

// 资料信息内存存储
@property (nonatomic, strong) XMPPvCardTemp *myvCardTemp;


@end

@implementation EditorTableViewController

#pragma MARK: - 懒加载
- (XMPPvCardTemp *)myvCardTemp
{
    if (_myvCardTemp == nil){
        _myvCardTemp = [ManagerXMPP shared].xmppvCardTempModule.myvCardTemp;
    }
    return _myvCardTemp;
}


#pragma MARK: - 加载页面
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma MARK: - 编辑方法
- (IBAction)didEditor:(id)sender {
    
    if ([self.textInput.text isEqualToString:@""]){
        
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请输入修改内容" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertV show];
        return;
    }
    // 更改对应内容
    if ([self.title isEqualToString:@"编辑昵称"]){
        self.myvCardTemp.nickname = self.textInput.text;
    }else {
        self.myvCardTemp.desc = self.textInput.text;
    }
    
    // 更新
    [[ManagerXMPP shared].xmppvCardTempModule updateMyvCardTemp:self.myvCardTemp];
    
    // 关闭窗口
    [self.navigationController popViewControllerAnimated:YES];
    
}

// 取消编辑
- (IBAction)cancelEditor:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}





@end
