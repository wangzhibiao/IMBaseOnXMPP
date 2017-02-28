//
//  UITableView+Category.m
//  IMBaseOnXMPP
//
//  Created by 王小帅 on 2017/2/27.
//  Copyright © 2017年 王小帅. All rights reserved.
//

#import "UITableView+Category.h"

@implementation UITableView (Category)

/** 滚动到最后一个cell */
- (void)scrollsToBottom
{
    NSInteger s = [self numberOfSections];  //有多少组
    if (s<1) return;  //无数据时不执行 要不会crash
    NSInteger r = [self numberOfRowsInSection:s-1]; //最后一组有多少行
    if (r<1) return;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    
    //取最后一行数据
    [self scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO]; //滚动到最后一行
    
}

@end
