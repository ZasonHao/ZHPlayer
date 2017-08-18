//
//  ZHHandleView.m
//
//  Created by Zason Hao.
//

#import "ZHHandleView.h"
#import "UIView+ZHPlayer.h"

@interface ZHHandleView ()
{
    
    
}

@property (nonatomic,strong) UIButton *backBtn;

@property (nonatomic,strong) UIView *titleView;

@property (nonatomic,strong) UIView *bottomView;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) UIButton *playBtn;

@property (nonatomic,strong) UISlider *slider;

@property (nonatomic,strong) UIButton *fullScreenBtn;

@property (nonatomic,strong) UIButton *screenShotBtn;

@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong) UIButton *lockBtn;

@property (nonatomic,strong) UIActivityIndicatorView *activity;

@property (nonatomic,strong) UIButton *failBtn;

@property (nonatomic,strong) UIButton *replayBtn;

@end

@implementation ZHHandleView
{
    BOOL _isSeekable;     //是否可拖动
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setUpUI{
    [self addSubview:self.titleView];
    [self addSubview:self.bottomView];
    
    [self.titleView addSubview:self.titleLabel];
    
    [self.bottomView addSubview:self.playBtn];
    [self.bottomView addSubview:self.timeLabel];
    [self.bottomView addSubview:self.fullScreenBtn];
    [self.bottomView addSubview:self.slider];
    
    [self addSubview:self.backBtn];
    [self addSubview:self.lockBtn];
    [self addSubview:self.screenShotBtn];
    
    [self addSubview:self.activity];
    [self addSubview:self.failBtn];
    [self addSubview:self.replayBtn];
    
}

-(void)play:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self pause];
    }else{
        [self play];
    }
}

- (void)lock:(UIButton *)sender{
    sender.selected = !sender.selected;
    self.isLock = sender.selected;
    [self lockScreen:sender.selected];
}

- (void)back:(UIButton *)sender{
    if (self.isFullScreen) {
        self.fullScreenBtn.selected = NO;
        [self fullScreen];
        return;
    }
    if ([[self ViewController] respondsToSelector:@selector(popoverPresentationController)]) {
        [[self ViewController] popoverPresentationController];
    }
    if ([[self ViewController] respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [[self ViewController] dismissViewControllerAnimated:YES completion:^{
        }];
    }
}

- (void)fullScreen:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self fullScreen];
}

-(UIViewController *)ViewController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

-(void)playFail{
    _failBtn.hidden = YES;
    [self reloadVideo];
}

-(void)replayVideo{
    _replayBtn.hidden = YES;
    [self replay];
}

#pragma mark - 继承并重写父类方法

-(void)showHandleView{
    self.titleView.alpha = 1.0;
    self.bottomView.alpha = 1.0;
    self.lockBtn.alpha = 1.0;
    self.screenShotBtn.alpha = 1.0;
}

-(void)hideHandleView{
    self.titleView.alpha = 0.0;
    self.bottomView.alpha = 0.0;
    if (!self.isLock) {
        self.lockBtn.alpha = 0.0;
    }
    self.screenShotBtn.alpha = 0.0;
}

-(void)zhPlayerSetFullScreen:(BOOL)isFull{
    _fullScreenBtn.selected = isFull;
}

-(void)setCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime sliderValue:(CGFloat)value{
    //正在拖动，do nothing
    if (self.isSeeking) return;
    //可拖动
    if (value >= 0.0) {
        _isSeekable = YES;
        _slider.maximumValue = 1;
        self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self getFormatTime:currentTime],[self getFormatTime:totalTime]];
        _slider.value = value;
    }
    //不可拖动时，意味着当前播放的是直播，则无需改变时间和slider
    else{
        self.timeLabel.text = @"--:--/--:--";
    }
}

- (void)isSeekingToTime:(CGFloat)seekToTime direction:(BOOL)forward{
    [self hideActivity];
    _slider.value = seekToTime/self.totalTime;
    NSString *time = [NSString stringWithFormat:@"%@/%@",[self getFormatTime:seekToTime],[self getFormatTime:self.totalTime]];
    self.timeLabel.text = time;
    [[ZHPlayerHudView shareInstance] setSpeed:time direction:forward];
    
}

-(void)showActivity{
    [self.activity startAnimating];
}

-(void)hideActivity{
    [self.activity stopAnimating];
}

#pragma mark - UISlider - play seek

-(void)onSeekBegin:(UISlider *)slider{
    self.isSeeking = YES;
}

-(void)onDrag:(UISlider *)slider {
    float progress = slider.value;
    CGFloat seekTime = self.totalTime*progress;
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self getFormatTime:seekTime],[self getFormatTime:self.totalTime]];
}

-(void)onSeek:(UISlider *)slider{
    float progress = slider.value;
    CGFloat seekTime = self.totalTime*progress;
    [self seekToTime:(NSInteger)seekTime];
    self.isSeeking = NO;
}


#pragma mark - layoutSubviews
-(void)layoutSubviews{
    [super layoutSubviews];
    [self setUpUI];
    self.lockBtn.hidden = !self.isFullScreen;
}

#pragma mark - Setter and Getter

-(void)setState:(ZHPlayerPlayState)state{
    [super setState:state];
    if (self.activity.isAnimating && state == ZHPlayerPlayStateBuffering) {
        [self hideActivity];
    }
    if (state == ZHPlayerPlayStateBuffering) {
        //缓冲中，显示菊花
        [self showActivity];
        self.playBtn.selected = YES;
        [self lockScreen:NO];
    }else if (state == ZHPlayerPlayStatePlaying){
        //隐藏菊花
        self.playBtn.selected = NO;
        [self hideActivity];
        [self lockScreen:NO];
    }else if (state == ZHPlayerPlayStatePlayFail){
        //显示播放失败，点击重新播放
        self.failBtn.hidden = NO;
        self.playBtn.selected = YES;
        [self lockScreen:YES];
    }else if (state == ZHPlayerPlayStateStop){
        self.playBtn.selected = YES;
        [self lockScreen:NO];
    }else if (state == ZHPlayerPlayStatePlayOver){
        self.replayBtn.hidden = NO;
        self.playBtn.selected = YES;
        [self lockScreen:YES];
    }else if (state == ZHPlayerPlayStatePause){
        //暂停
        self.playBtn.selected = YES;
        [self lockScreen:NO];
    }
}

-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        _backBtn.frame = CGRectMake(10, 5, 30, 30);
        [_backBtn setImage:[UIImage imageNamed:@"player_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _backBtn;
}

-(UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
        _titleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 40);
        [_titleView setLineGradientBackgroundColorWithColor:[UIColor blackColor] from:CGPointMake(0, 0) to:CGPointMake(0, 1.0)];
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }else{
        [_titleView setLineGradientBackgroundColorWithColor:[UIColor blackColor] from:CGPointMake(0, 0) to:CGPointMake(0, 1.0)];
    }
    return _titleView;
}

-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-40, CGRectGetWidth(self.frame), 40);
        [_bottomView setLineGradientBackgroundColorWithColor:[UIColor blackColor] from:CGPointMake(0, 1.0) to:CGPointMake(0, 0)];
        _bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }else{
        [_bottomView setLineGradientBackgroundColorWithColor:[UIColor blackColor] from:CGPointMake(0, 1.0) to:CGPointMake(0, 0)];
    }
    return _bottomView;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(40, 5, CGRectGetWidth(_titleView.frame) - 40*2, 30);
        _titleLabel.text = self.videoTitle;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _titleLabel;
}

-(UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        _playBtn.frame = CGRectMake(5, 5, 30, 30);
        [_playBtn setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return _playBtn;
}

-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.frame = CGRectMake(CGRectGetMaxX(_playBtn.frame) + 5, CGRectGetMinY(_playBtn.frame), 60, 30);
        _timeLabel.text = @"--:--/--:--";
//        _timeLabel.adjustsFontSizeToFitWidth = YES;
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return _timeLabel;
}

-(UIButton *)fullScreenBtn{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [[UIButton alloc] init];
        _fullScreenBtn.frame = CGRectMake(CGRectGetWidth(_bottomView.frame) - 5 - 30, 5, 30, 30);
        [_fullScreenBtn setImage:[UIImage imageNamed:@"player_fullscreen"] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"player_shrinkscreen"] forState:UIControlStateSelected];
        [_fullScreenBtn addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
        _fullScreenBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        
    }
    return _fullScreenBtn;
}

-(UIButton *)screenShotBtn{
    if (!_screenShotBtn) {
        _screenShotBtn = [[UIButton alloc] init];
        _screenShotBtn.frame = CGRectMake(0, 0, 30, 30);
        _screenShotBtn.center = CGPointMake(CGRectGetWidth(self.frame) - 25, CGRectGetHeight(self.frame)/2);
        [_screenShotBtn setImage:[UIImage imageNamed:@"player_screenshot"] forState:UIControlStateNormal];
        [_screenShotBtn addTarget:self action:@selector(screenShot) forControlEvents:UIControlEventTouchUpInside];
        _screenShotBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return _screenShotBtn;
}
-(UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_timeLabel.frame) + 5, 5, CGRectGetMinX(_fullScreenBtn.frame) - CGRectGetMaxX(_timeLabel.frame) - 10, 30)];
        _slider.maximumValue = 0;
        _slider.minimumValue = 0;
        _slider.value = 0;
        _slider.continuous = NO;
        [_slider setThumbImage:[UIImage imageNamed:@"player_slider"] forState:UIControlStateNormal];
        _slider.minimumTrackTintColor = [UIColor colorWithRed:0.0/255.0f green:124.0/255.0f blue:67.0/255.0f alpha:1];
        _slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [_slider addTarget:self action:@selector(onSeek:) forControlEvents:(UIControlEventValueChanged)];
        [_slider addTarget:self action:@selector(onSeekBegin:) forControlEvents:(UIControlEventTouchDown)];
        [_slider addTarget:self action:@selector(onDrag:) forControlEvents:UIControlEventTouchDragInside];
    }
    return _slider;
}

-(UIButton *)lockBtn{
    if (!_lockBtn) {
        _lockBtn = [[UIButton alloc] init];
        _lockBtn.frame = CGRectMake(0, 0, 30, 30);
        _lockBtn.center = CGPointMake(25, CGRectGetHeight(self.frame)/2);
        [_lockBtn setImage:[UIImage imageNamed:@"player_unlock"] forState:UIControlStateNormal];
        [_lockBtn setImage:[UIImage imageNamed:@"player_lock"] forState:UIControlStateSelected];
        [_lockBtn addTarget:self action:@selector(lock:) forControlEvents:UIControlEventTouchUpInside];
        _lockBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    }
    return _lockBtn;
}

-(UIActivityIndicatorView *)activity{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.center = self.center;
        _activity.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _activity;
}

-(UIButton *)failBtn{
    if (!_failBtn) {
        _failBtn = [[UIButton alloc] init];
        _failBtn.frame = CGRectMake(0, 0, 130, 30);
        _failBtn.center = self.center;
        [_failBtn setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _failBtn.backgroundColor = [UIColor blackColor];
        _failBtn.alpha = 0.7;
        [_failBtn addTarget:self action:@selector(playFail) forControlEvents:UIControlEventTouchUpInside];
        _failBtn.hidden = YES;
        _failBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _failBtn;
}

-(UIButton *)replayBtn{
    if (!_replayBtn) {
        _replayBtn = [[UIButton alloc] init];
        _replayBtn.frame = CGRectMake(0, 0, 70, 30);
        _replayBtn.center = self.center;
        [_replayBtn setTitle:@"重播" forState:UIControlStateNormal];
        [_replayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _replayBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _replayBtn.backgroundColor = [UIColor blackColor];
        _replayBtn.alpha = 0.7;
        [_replayBtn addTarget:self action:@selector(replayVideo) forControlEvents:UIControlEventTouchUpInside];
        _replayBtn.hidden = YES;
        _replayBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _replayBtn;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
