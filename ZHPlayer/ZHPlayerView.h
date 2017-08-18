//
//  ZHPlayerView.h
//
//  Created by Zason Hao.
//
//  视频显示层
//  

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZHPlayerHeader.h"

@interface ZHPlayerView : UIView
/*
 *  视频url
 */
@property (nonatomic,copy) NSURL *videoUrl;
/*
 *  视频池
 */
@property (nonatomic,copy) NSArray *videoUrls;
/*
 *  视频填充模式
 */
@property (nonatomic,copy) NSString *videoGravity;
/*
 *  自动播放
 */
@property (nonatomic,assign) BOOL autoPlay;
/*
 *  视频占位图
 */
@property (nonatomic,strong) UIImage *placeHolderImage;
/*
 *  视频占位图
 */
@property (nonatomic,strong) UIImageView *placeHolderImageView;
/*
 *  视频播放状态
 */
@property (nonatomic,assign) ZHPlayerPlayState state;
/*
 *  代理，回调视频播放过程中的相关信息
 */
@property (nonatomic,weak) id<ZHPlayerViewDelegate> delegate;


#pragma mark - ZHPlayer中调用，控制视频播放
//播放
- (void)play;
//暂停
- (void)pause;
//停止
- (void)stop;
//快进、快退
- (void)seekToTime:(NSInteger)seekTime;
//重播
- (void)replay;
//重新加载
- (void)reload;
//播放下一条
- (void)next;
//播放上一条
- (void)last;
//获取视频当前帧
- (UIImage *)screenShot;

@end
