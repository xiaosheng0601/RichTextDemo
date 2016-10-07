//
//  RootViewController.m
//  RichTextDemo
//
//  Created by Victor on 16/10/7.
//  Copyright © 2016年 Victor. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
@interface RootViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"富文本编辑器";
    UITableView *table = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    table.tableFooterView = [[UIView alloc]init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idenstr = @"sss";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idenstr];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:idenstr];
    }
    cell.textLabel.text = @[@"新增",@"编辑"][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ViewController *view = [[ViewController alloc]init];
    NSString *str = @"哈哈哈啊啊啊啊 <img src=\"http://pic.baikemy.net/apps/kanghubang/486/3486/iOS1475026895.jpg\"><div>哈哈哈啊啊啊啊奥等级看哈接口b</div>";
    view.inHtmlString = indexPath.row == 0?@"":str;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
