//
//  ZHBaseHandleView.m
//
//  Created by Zason Hao.
//

#import "ZHBaseHandleView.h"
#import "ZHPlayerSystem.h"

@implementation ZHBaseHandleView
{
    CGPoint beginPoint;
    CGFloat beginSeekTime;
    CGFloat beginBrightness;
    CGFloat beginVolume;
    
}
-(instancetype)init{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData{
    _handleViewStatus = ZHPlayerHandleViewShow;
    
    self.hideDuration = 0.5;
    self.delayTime = 5.0;
    
    _isSeeking = NO;
    _isLock = NO;
    _isFullScreen = NO;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self setAutoHideHandleView];
}
-(NSString *)getFormatTime:(CGFloat)totalTime{
    
    NSInteger total = (NSInteger)totalTime;
    //计算时间
    //秒
    NSInteger second = total % 60;
    //分钟
    NSInteger minute = (total / 60) % 60;
    //小时
    NSInteger hour = total / 3600;
    
    NSString *formatTime = [NSString stringWithFormat:@"%@%@%@",hour == 0 ? @"" : [NSString stringWithFormat:@"%ld:",(long)hour],[NSString stringWithFormat:@"%02ld:",(long)minute],[NSString stringWithFormat:@"%02ld",(long)second]];
    return formatTime;
}

#pragma mark - Handle Button Actions

- (void)play{
    [self responseDelegate:ZHPlayerHandlePlay object:nil];
}

- (void)pause{
    [self responseDelegate:ZHPlayerHandlePause object:nil];
}

- (void)stop{
    [self responseDelegate:ZHPlayerHandleStop object:nil];
}

- (void)seekToTime:(NSInteger)seekTime{
    
    [self responseDelegate:ZHPlayerHandleSeek object:@(seekTime)];
}

- (void)fullScreen{
    [self responseDelegate:ZHPlayerHandleFullScreen object:nil];
}

- (UIImage *)screenShot{
    [self responseDelegate:ZHPlayerHandleScreenShot object:nil];
    UIImageWriteToSavedPhotosAlbum(self.screenShotImage, self, nil, nil);
    return _screenShotImage;
}

- (void)reloadVideo{
    [self responseDelegate:ZHPlayerHandleReloadVideo object:nil];
}

- (void)replay{
    [self responseDelegate:ZHPlayerHandleReplay object:nil];
}

- (void)responseDelegate:(ZHPlayerHandleType)handle object:(id)obj{
    if ([_delegate respondsToSelector:@selector(zhPlayerHandleViewDelegate:object:)]) {
        [_delegate zhPlayerHandleViewDelegate:handle object:obj];
    }
}

- (void)lockScreen:(BOOL)lock{
    self.isLock = lock;
    if (lock) {
        [self hide];
    }else{
        [self show];
    }
}

#pragma mark - 下列方法根据自己需要子类重写即可
//由ZHPLayer传递回来的方法,handleview需要在这里处理一些ui上的变化
- (void)zhPlayerSetFullScreen:(BOOL)isFull{
    
}

- (void)setCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime sliderValue:(CGFloat)value{
}

-(void)showHandleView{
    
}

-(void)hideHandleView{
    
}

- (void)isSeekingToTime:(CGFloat)seekToTime direction:(BOOL)forward{
    
}

- (void)adjustVolume:(CGFloat)volume{
    
}

- (void)adjustBrightness:(CGFloat)brightness{
    
}

- (void)showActivity{
    
}

- (void)hideActivity{
    
}

#pragma mark - Setter and Getter

-(void)setState:(ZHPlayerPlayState)state{
    _state = state;
}
#pragma mark - Private method

-(void)show{
    [UIView animateWithDuration:self.hideDuration animations:^{
        _handleViewStatus = ZHPlayerHandleViewChanging;
        if (_isFullScreen) {
            [UIApplication sharedApplication].statusBarHidden = NO;
        }
        [self showHandleView];
    } completion:^(BOOL finished) {
        _handleViewStatus = ZHPlayerHandleViewShow;
        [self setAutoHideHandleView];
    }];
}

-(void)hide{
    [UIView animateWithDuration:self.hideDuration animations:^{
        _handleViewStatus = ZHPlayerHandleViewChanging;
        [self hideHandleView];
    } completion:^(BOOL finished) {
        _handleViewStatus = ZHPlayerHandleViewHide;
        if (_isFullScreen) {
            [UIApplication sharedApplication].statusBarHidden = YES;
        }
        [self cancelAutoHideHandleView];
    }];
}


- (void)showOrHide{
    switch (_handleViewStatus) {
        case ZHPlayerHandleViewChanging:
            // Do Nothing
            break;
        case ZHPlayerHandleViewShow:
            [self hide];
            break;
        case ZHPlayerHandleViewHide:
            [self show];
            break;
            
        default:
            break;
    }
}

- (void)setAutoHideHandleView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self performSelector:@selector(hide) withObject:nil afterDelay:self.delayTime];
}

- (void)cancelAutoHideHandleView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
}

#pragma mark - 手势
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    if (_isLock) return;
    beginPoint = [[touches anyObject] locationInView:self];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_isLock) return;
    CGPoint curPoint = [[touches anyObject] locationInView:self];
    CGPoint prePoint = [[touches anyObject] previousLocationInView:self];
    
    CGFloat curX = curPoint.x;
    CGFloat curY = curPoint.y;
    
    //X轴位移量
    CGFloat displacementX = fabs(curX - beginPoint.x);
    //Y轴位移量
    CGFloat displacementY = fabs(curY - beginPoint.y);
    
    if (displacementX <= 30 && displacementY <=30) {
        return;
    }
    //拖动类型未确定
    if (_dragType == ZHPlayerDragTypeNone) {
        if (displacementX > displacementY) {
            _dragType = ZHPlayerDragTypeSeek;
            _isSeeking = YES;
            beginSeekTime = _currentTime;
        }else if (displacementX < displacementY) {
            if (beginPoint.x < CGRectGetWidth(self.frame)/2) {
                _dragType = ZHPlayerDragTypeBrightness;
                beginBrightness = [ZHPlayerSystem sharedInstance].brightness;
            }else{
                _dragType = ZHPlayerDragTypeVolume;
                beginVolume = [ZHPlayerSystem sharedInstance].volume;
            }
        }else{
            _dragType = ZHPlayerDragTypeNone;
        }
    }
    //拖动类型已确定
    else{
        if (_dragType == ZHPlayerDragTypeSeek) {
            if (!_isSeekable) return;
            CGFloat seekToTime = beginSeekTime + (curX - beginPoint.x)/5.00;
            if (seekToTime >= _totalTime) {
                seekToTime = _totalTime;
            }
            if (seekToTime <= 0) {
                seekToTime = 0.0;
            }
            BOOL isForward = YES;
            if (curX < prePoint.x) {
                isForward = NO;
            }
            [[ZHPlayerHudView shareInstance] showOnTheView:self hudType:ZHPlayerHudViewTypeSpeed];
            [self isSeekingToTime:seekToTime direction:isForward];
        }else if (_dragType == ZHPlayerDragTypeVolume){
            CGFloat a = (curY - beginPoint.y)/500.00;
            [[ZHPlayerSystem sharedInstance] setVolume:beginVolume-a];
        }else{
            CGFloat a = (curY - beginPoint.y)/500.00;
            [[ZHPlayerSystem sharedInstance] setBrightness:beginBrightness-a];
            [self adjustVolume:beginBrightness-a];
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_isLock) return;
    CGPoint endPoint = [[touches anyObject] locationInView:self];
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 0) {
        if (_dragType == ZHPlayerDragTypeSeek) {
            if (!_isSeekable) {
                _dragType = ZHPlayerDragTypeNone;
                return;
            }
            CGFloat seekToTime = beginSeekTime + (endPoint.x - beginPoint.x)/5.00;
            [self seekToTime:(NSInteger)seekToTime];
            [[ZHPlayerHudView shareInstance] hide];
        }
    }else if (touch.tapCount == 1) {
        [self showOrHide];
    }else if (touch.tapCount == 2){
    }else{
    }
    beginPoint = CGPointMake(-1, -1);
    _isSeeking = NO;
    _dragType = ZHPlayerDragTypeNone;
    beginSeekTime = 0.0;}

-(void)layoutSubviews{
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
