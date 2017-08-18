//
//  ZHPlayer.m
//
//  Created by Zason Hao.
//

#import "ZHPlayer.h"
#import "ZHPlayerView.h"
#import "ZHHandleView.h"

@interface ZHPlayer ()<ZHPlayerHandleViewDelegate,ZHPlayerViewDelegate>
{
    UIInterfaceOrientation currentOrientation;
    BOOL _didEnterBackGround;
}

@end

@implementation ZHPlayer

-(void)dealloc{
    NSLog(@"dealloc");
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
}
-(instancetype)init{
    self = [super init];
    if (self) {
        [self initData];
        [self addObserve];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.frame = frame;
        
    }
    return self;
}

- (void)initData{
    _autoPlay = YES;
    _didEnterBackGround = NO;
    currentOrientation = UIInterfaceOrientationPortrait;
    
    //下面代码，使视频不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    if (!success) {
        NSLog(@"开启失败");
    }
}

//添加KVO
- (void)addObserve{
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterPlayground) name:UIApplicationDidBecomeActiveNotification object:nil];
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
    // 监测设备方向
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStatusBarOrientationChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}
//强制旋转屏幕
- (void)screenOrientation{
    if (currentOrientation == UIInterfaceOrientationLandscapeRight) {
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        currentOrientation = UIInterfaceOrientationPortrait;
    }else if (currentOrientation == UIInterfaceOrientationPortrait){
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        currentOrientation = UIInterfaceOrientationLandscapeRight;
    }
}

#pragma mark - ZHPlayerViewDelegate

-(void)zhPlayerPlayStateDidChanged:(ZHPlayerPlayState)state{
    //不同状态对应的处理
    [self.handleView setState:state];
    
    if ([_delegate respondsToSelector:@selector(zhPlayer:playState:obj:)]) {
        [_delegate zhPlayer:self playState:state obj:nil];
    }
}
//实时监测视频播放
-(void)observeTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime seekAble:(BOOL)seekAble{
    _handleView.currentTime = currentTime;
    _handleView.totalTime = totalTime;
    CGFloat sligerValue = - 1.0;
    if (seekAble) {
        sligerValue = currentTime/totalTime;
    }
    _handleView.isSeekable = seekAble;
    [_handleView setCurrentTime:currentTime totalTime:totalTime sliderValue:sligerValue];
}

#pragma mark - ZHPlayerHandleViewDelegate

-(void)zhPlayerHandleViewDelegate:(ZHPlayerHandleType)handle object:(id)obj{
    
    switch (handle) {
        case ZHPlayerHandlePlay:
            [self.videoView play];
            break;
        case ZHPlayerHandlePause:
            [self.videoView pause];
            break;
            
        case ZHPlayerHandleStop:
            [self.videoView stop];
            break;
            
        case ZHPlayerHandleSeek:
            [self.videoView seekToTime:[obj integerValue]];
            break;
            
        case ZHPlayerHandleNext:
            
            break;
        case ZHPlayerHandleLast:
            
            break;
        case ZHPlayerHandleScreenShot:
            self.handleView.screenShotImage = [self.videoView screenShot];
            break;
        case ZHPlayerHandleFullScreen:
            [self screenOrientation];
            break;
        case ZHPlayerHandleReplay:
            [self.videoView replay];
            break;
        case ZHPlayerHandleReloadVideo:
            [self.videoView reload];
            break;
        default:
            break;
    }
}

#pragma mark - KVO

//应用退到后台
- (void)appDidEnterBackground {
    _didEnterBackGround = YES;
    [self.videoView pause];
}

//应用进入前台
- (void)appDidEnterPlayground {
    if (_didEnterBackGround) {
        [self.videoView play];
    }
    _didEnterBackGround = NO;
}

//耳机插入、拔出事件
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // 耳机插入
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
        {
            // 耳机拔掉
            // 拔掉耳机继续播放
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
    }
}

#pragma mark - 屏幕旋转
//屏幕方向发生变化会调用这里
- (void)onDeviceOrientationChange {
    NSLog(@"onDeviceOrientationChange");
    [UIApplication sharedApplication].statusBarHidden = NO;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationPortrait){
        currentOrientation = UIInterfaceOrientationPortrait;
        self.videoView.frame = _frame;
        self.handleView.isFullScreen = NO;
        [self.handleView zhPlayerSetFullScreen:NO];
    }else if (orientation == UIDeviceOrientationLandscapeLeft){
        currentOrientation = UIInterfaceOrientationLandscapeRight;
        self.videoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.handleView.isFullScreen = YES;
        [self.handleView zhPlayerSetFullScreen:YES];
    }else if (orientation == UIDeviceOrientationLandscapeRight){
        currentOrientation = UIInterfaceOrientationLandscapeLeft;
        self.videoView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.handleView.isFullScreen = YES;
        [self.handleView zhPlayerSetFullScreen:YES];
    }
}
//状态条变化通知
- (void)onStatusBarOrientationChange {
    NSLog(@"onStatusBarOrientationChange");
}

#pragma mark - Setter and Getter

-(void)setFrame:(CGRect)frame{
    _frame = frame;
    _videoView.frame = _frame;
    _handleView.frame = _frame;
}

-(void)setVideoTitle:(NSString *)videoTitle{
    _videoTitle = videoTitle;
    _handleView.videoTitle = _videoTitle;
}

-(ZHPlayerView *)videoView{
    if (!_videoView) {
        ZHPlayerView *videoView = [[ZHPlayerView alloc] init];
        videoView.videoUrl = [NSURL URLWithString:_videoUrl];
        videoView.frame = _frame;
        videoView.videoGravity = _videoGravity;
        videoView.delegate = self;
        videoView.placeHolderImage = [UIImage imageNamed:@"player_loading_bgView"];
        _videoView = videoView;
    }
    return _videoView;
}

-(void)setHandleView:(ZHBaseHandleView *)handleView{
    _handleView = handleView;
    _handleView.frame = self.videoView.bounds;
    _handleView.videoTitle = _videoTitle;
    [self.videoView addSubview:_handleView];
    _handleView.delegate = self;
}

-(UIImage *)screenShotImage{
    _screenShotImage = [self.videoView screenShot];
    return _screenShotImage;
}

-(void)setDisplayView:(UIView *)displayView{
    _displayView = displayView;
    [_displayView addSubview:self.videoView];
}

@end
