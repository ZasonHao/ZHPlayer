//
//  ZHPlayerHeader.h
//
//  Created by Zason Hao.
//
//  一些代理方法和枚举的声明

#ifndef ZHPlayerHeader_h
#define ZHPlayerHeader_h

@class ZHPlayer;
typedef NS_ENUM (NSInteger, ZHPlayerHandleType){
    ZHPlayerHandlePlay,             //播放
    ZHPlayerHandlePause,            //暂停
    ZHPlayerHandleStop,             //停止
    ZHPlayerHandleSeek,             //快进、快退
    ZHPlayerHandleFullScreen,       //全屏
    ZHPlayerHandleNext,             //播放下一条
    ZHPlayerHandleLast,             //播放上一条
    ZHPlayerHandleScreenShot,       //截图
    ZHPlayerHandleReloadVideo,      //重新加载
    ZHPlayerHandleReplay,           //重播
};

typedef NS_ENUM (NSInteger, ZHPlayerPlayState){
    ZHPlayerPlayStatePlaying,       //正在播放
    ZHPlayerPlayStatePlayFail,      //播放失败
    ZHPlayerPlayStateBuffering,     //正在缓冲
    ZHPlayerPlayStateStop,          //播放停止
    ZHPlayerPlayStatePlayOver,      //播放完
    ZHPlayerPlayStatePause,         //暂停中
    
};

typedef NS_ENUM(NSInteger,ZHPlayerHandleViewStatus){
    ZHPlayerHandleViewShow,            //显示中
    ZHPlayerHandleViewChanging,        //过渡中
    ZHPlayerHandleViewHide             //隐藏中
};

typedef NS_ENUM(NSInteger,ZHPlayerDragType){
    ZHPlayerDragTypeNone,          //不属于任何类型的拖动
    ZHPlayerDragTypeVolume,        //音量
    ZHPlayerDragTypeSeek,          //快进、快退
    ZHPlayerDragTypeBrightness     //屏幕亮度
};

@protocol ZHPlayerHandleViewDelegate <NSObject>

@optional
/*
 *  触发事件
 *  handle      触发的命令
 *  obj         传递的参数
 */
- (void)zhPlayerHandleViewDelegate:(ZHPlayerHandleType)handle object:(id)obj;

@end

@protocol ZHPlayerViewDelegate <NSObject>
/*
 *  回调播放状态
 *  state      播放状态
 */
- (void)zhPlayerPlayStateDidChanged:(ZHPlayerPlayState)state;
/*
 *  实时监测视频播放时间
 *  currentTime      视频播放当前时间
 *  totalTime        视频总时长
 *  seekAble         当前视频是否有seek功能
 */
- (void)observeTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime seekAble:(BOOL)seekAble;

@end

@protocol ZHPlayerDelegate <NSObject>

@optional
/*
 *  ZHPlayer回调给VC的代理
 *  playState         当前播放状态
 *  obj               有可能携带的参数
 */
- (void)zhPlayer:(ZHPlayer *)player playState:(ZHPlayerPlayState)playState obj:(id)obj;

@end

#endif /* ZHPlayerHeader_h */
