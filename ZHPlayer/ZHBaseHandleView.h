//
//  ZHBaseHandleView.h
//
//  Created by Zason Hao.
//
//  播放器的视屏控制器
//  使用者只需继承本类，调用API，重写部分方法即可，大部分逻辑无需关心，内部已处理好

#import <UIKit/UIKit.h>
#import "ZHPlayerHudView.h"
#import "ZHPlayerHeader.h"

@interface ZHBaseHandleView : UIView
/*
 *  视频标题
 */
@property (nonatomic,copy) NSString *videoTitle;
/*
 *  显示状态
 *  只读，子类可根据此状态做UI上的变化
 */
@property (nonatomic,assign,readonly) ZHPlayerHandleViewStatus handleViewStatus;
/*
 *  拖动类型
 */
@property (nonatomic,assign,readonly) ZHPlayerDragType dragType;
/*
 *  视频的播放状态
 */
@property (nonatomic,assign) ZHPlayerPlayState state;
/*
 *  视图隐藏和显示的过渡时间，默认0.5s
 */
@property (nonatomic,assign) CGFloat hideDuration;
/*
 *  不触碰屏幕，显示的最长时间，默认5.0s
 */
@property (nonatomic,assign) CGFloat delayTime;
/*
 *  当前视频播放的时间
 */
@property (nonatomic,assign) CGFloat currentTime;
/*
 *  视频总时长
 */
@property (nonatomic,assign) CGFloat totalTime;
/*
 *  是否可快进、快退
 */
@property (nonatomic,assign) BOOL isSeekable;
/*
 *  是否正在快进、快退
 */
@property (nonatomic,assign) BOOL isSeeking;
/*
 *  视频当前画面(帧)
 */
@property (nonatomic,strong) UIImage *screenShotImage;
/*
 *  是否全屏状态
 */
@property (nonatomic,assign) BOOL isFullScreen;
/*
 *  是否上锁
 */
@property (nonatomic,assign) BOOL isLock;
/*
 *  代理，通知ZHPlayer做相关操作
 */
@property (nonatomic,weak) id<ZHPlayerHandleViewDelegate> delegate;

/*
 *  视频的播放状态，根据此状态做一些UI变化
 *  需要注意的是，子类可以继承并重写改方法，在自己的子类中作出相关UI处理，
 *  但一定要先调用[super setState:state];
 */
-(void)setState:(ZHPlayerPlayState)state;

#pragma mark - 下列方法为API，在自己的子类UI上，直接调用即可，不要重写下面的方法。至于调用下面的方法会如何触发视频操作的逻辑已经处理好，直接调用即可。
/*
 *  播放
 */
- (void)play;
/*
 *  暂停
 */
- (void)pause;
/*
 *  停止
 */
- (void)stop;
/*
 *  快进、快退到某一时间点
 *  seekTime        seek到的时间
 */
- (void)seekToTime:(NSInteger)seekTime;
/*
 *  全屏
 */
- (void)fullScreen;
/*
 *  截屏
 */
- (UIImage *)screenShot;
/*
 *  重新加载
 */
- (void)reloadVideo;
/*
 *  重播
 */
- (void)replay;
/*
 *  锁屏
 */
- (void)lockScreen:(BOOL)lock;
/*
 *  时间格式化
 */
- (NSString *)getFormatTime:(CGFloat)totalTime;


#pragma mark - 下面的方法需要子类自己去实现，具体每个方法什么时候触发，已经在父类做好逻辑处理，子类只需实现在触发下列方法时需要做哪些UI上的变化即可
/*
 *  显示菊花
 */
- (void)showActivity;
/*
 *  隐藏菊花
 */
- (void)hideActivity;
/*
 *  显示自身控件
 */
- (void)showHandleView;
/*
 *  隐藏自身控件
 */
- (void)hideHandleView;
/*
 *  屏幕旋转成功后的回调
 */
- (void)zhPlayerSetFullScreen:(BOOL)isFull;
/*
 *  正在调整音量
 *  volume      改变值
 */
- (void)adjustVolume:(CGFloat)volume;
/*
 *  正在调整屏幕亮度
 *  brightness      改变值
 */
- (void)adjustBrightness:(CGFloat)brightness;
/*
 *  正在拖动屏幕或slider
 *  seekToTime      拖动的进度
 *  forward         拖动的方向：快进YES or 快退NO
 */
- (void)isSeekingToTime:(CGFloat)seekToTime direction:(BOOL)forward;
/*
 *  获取视频当前播放时间
 */
- (void)setCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime sliderValue:(CGFloat)value;

@end
