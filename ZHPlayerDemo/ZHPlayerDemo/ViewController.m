//
//  ViewController.m
//  ZHPlayerDemo
//
//  Created by Zason_Hao on 2017/8/17.
//  Copyright © 2017年 Zason_Hao. All rights reserved.
//

#import "ViewController.h"
#import "ZHPlayer.h"
#import "ZHHandleView.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<ZHPlayerDelegate>

@property(nonatomic,strong)ZHPlayer *zhplayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSString *url = @"http://ipad.akamai.com/Video_Content/npr/cherryblossoms_hdv_bug/all.m3u8";
    NSString *url = @"http://baobab.cdn.wandoujia.com/14463059939521445330477778425364388_x264.mp4";
    ZHHandleView *handle = [[ZHHandleView alloc] init];
    
    _zhplayer = [[ZHPlayer alloc] init];
    _zhplayer.delegate = self;
    _zhplayer.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.frame), 200);
    _zhplayer.videoUrl = url;
    _zhplayer.videoGravity = AVLayerVideoGravityResize;
    _zhplayer.handleView = handle;
    _zhplayer.videoTitle = @"这是视频标题";
    
    [_zhplayer setDisplayView:self.view];
}

#pragma mark - ZHPlayerDelegate
- (void)zhPlayer:(ZHPlayer *)player handleType:(ZHPlayerHandleType)handleType obj:(id)obj{
    switch (handleType) {
        case ZHPlayerHandlePlay:
            
            break;
        case ZHPlayerHandlePause:
            
            break;
        case ZHPlayerHandleStop:
            
            break;
        case ZHPlayerHandleSeek:
            
            break;
        case ZHPlayerHandleFullScreen:
            
            break;
        case ZHPlayerHandleNext:
            
            break;
        case ZHPlayerHandleLast:
            
            break;
        case ZHPlayerHandleScreenShot:
            
            break;
            
        default:
            break;
    }
}

#pragma mark - 屏幕旋转
-(BOOL)shouldAutorotate{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
