//
//  ZHPlayer.h
//
//  Created by Zason Hao.
//
//  ZHPlayer视频播放器最重要的类
//  本类作为整个播放器的manager，处理了视频显示层和视频控制层之间的逻辑，数据，参数
//  ZHPlayer分为三部分:Manager,HandleView,DisplayView
//
//  Manager:        ZHPlayer
//  HandleView:     ZHPlayerBaseHandleView
//  DisplayView:    ZHplayerView
//
//  ZHPlayer:
//  只处理ZHplayerView和ZHPlayerBaseHandleView之间的逻辑、信息传递等
//
//  ZHPlayerBaseHandleView:
//  用户对视频播放过程中的交互视图，接收命令、发出命令、处理自己UI变化
//
//  ZHplayerView:
//  只负责显示视频，接收到外部命令，针对视频做出处理
//
//  三部分各司其职，层次清晰，分工明确
//

#import <UIKit/UIKit.h>
#import "ZHPlayerHeader.h"

@class ZHPlayerView;
@class ZHBaseHandleView;

@interface ZHPlayer : NSObject

/*
 *  视频显示层
 */
@property (nonatomic,strong) ZHPlayerView *videoView;
/*
 *  视频控制层
 */
@property (nonatomic,strong) ZHBaseHandleView *handleView;
/*
 *  播放器需要依托显示的View
 */
@property (nonatomic,strong) UIView *displayView;
/*
 *  设置视频显示层和控制层在displayView上的frame
 */
@property (nonatomic) CGRect frame;
/*
 *  视频标题
 */
@property (nonatomic,copy) NSString *videoTitle;
/*
 *  视频url
 */
@property (nonatomic,copy) NSString *videoUrl;
/*
 *  视频填充模式
 *  AVLayerVideoGravityResizeAspect       自适应，根据显示层大小，自动缩放，比例不变
 *  AVLayerVideoGravityResizeAspectFill   按自身比例放大或缩小，有可能超出显示层
 *  AVLayerVideoGravityResize             充满显示层，比例有可能会被拉伸
 */
@property (nonatomic,copy) NSString *videoGravity;
/*
 *  自动播放
 */
@property (nonatomic,assign) BOOL autoPlay;
/*
 *  视频正在播放时，当前的播放时间
 */
@property (nonatomic,assign) CGFloat curTime;
/*
 *  视频总时长
 */
@property (nonatomic,assign) CGFloat totTime;
/*
 *  视频当前播放画面(帧)
 */
@property (nonatomic,strong) UIImage *screenShotImage;
/*
 *  用于VC的代理，通知VC处理事件
 */
@property (nonatomic,weak) id<ZHPlayerDelegate> delegate;

@end
