//
//  ViewController.m
//  iOSPlayerExample
//
//  Created by 彭光波 on 16/3/21.
//  Copyright © 2016年 pengguangbo. All rights reserved.
//

#import "ViewController.h"
#import "VitamioVPVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *goPlayButn = [UIButton buttonWithType:UIButtonTypeCustom];
    [goPlayButn setBackgroundColor:[UIColor greenColor]];
    goPlayButn.frame = CGRectMake(10, 100, 300, 100);

    [goPlayButn setTitle:@"播放测试视频" forState:UIControlStateNormal];
    
    [goPlayButn addTarget:self action:@selector(goPlay:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:goPlayButn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goPlay:(id)sender
{
    VitamioVPVC *playerVC = [[VitamioVPVC alloc]initWithThemeStyle:VideoPlayerGreenButtonTheme controlBarMode:VideoPlayerControlBarWithoutPreviousAndNextOperate];
    playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:playerVC animated:YES completion:^{
        NSString *randomUrl = [[self class]randomGetVideoUrl];
        NSLog(@"video url: %@", randomUrl);
        [playerVC preparePlayURL:[NSURL URLWithString:randomUrl] immediatelyPlay:YES];
    }];
}

+ (NSString *)randomGetVideoUrl
{
    // FIXME:改地址可能失效, 请替换为自己的已知可用地址
    NSArray * allUrls = @[@"http://14.17.72.86:80/play/77F91240537F07C79BCE922CDE02B11E87855675.mp4"];
    int index = arc4random() % allUrls.count;
    return allUrls[index];
}

@end
