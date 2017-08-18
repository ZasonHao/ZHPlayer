//
//  ZHPlayerView.m
//
//  Created by Zason Hao.
//

#import "ZHPlayerView.h"
#import "ZHPlayerResouceLoader.h"

@interface ZHPlayerView () {
    //视频池的index
    NSInteger _index;
}
#pragma mark - 私有属性

@property (nonatomic,strong) AVPlayer *player;

@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@property (nonatomic,strong) AVPlayerItem *playerItem;

@property (nonatomic,strong) AVURLAsset *urlAsset;
//播放器的观察者，实时观测播放进度
@property (nonatomic,strong) id playerObserve;
//视频缓冲器(暂时不用)
@property (nonatomic,strong) ZHPlayerResouceLoader *resouceLoader;

@end


@implementation ZHPlayerView

-(instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self initData];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)initData{
    _index = 0;
    self.autoPlay = YES;
}

#pragma mark - Public Method
//播放
- (void)play{
    self.state = ZHPlayerPlayStatePlaying;
}
//暂停
- (void)pause{
    self.state = ZHPlayerPlayStatePause;
}
//停止
- (void)stop{
    self.state = ZHPlayerPlayStateStop;
}
//播放下一个
- (void)next{
    self.state = ZHPlayerPlayStateStop;
    [self setNilPlayer];
    if (_index != 0 && _index != self.videoUrls.count-1) {
        _index ++;
    }
    [self configPlayer];
}
//播放上一个
- (void)last{
    self.state = ZHPlayerPlayStateStop;
    [self setNilPlayer];
    if (_index != 0 && _index != self.videoUrls.count-1) {
        _index --;
    }
    self.videoUrl = [NSURL URLWithString:self.videoUrls[_index]];
    [self configPlayer];
}

//截取当前视频帧,并保存在相册
-(UIImage *)screenShot{
    
    AVAssetImageGenerator *imgGenerator = [[AVAssetImageGenerator alloc]initWithAsset:self.playerItem.asset];
    imgGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imgGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    CGImageRef imgRef = [imgGenerator copyCGImageAtTime:self.player.currentTime actualTime:NULL error:nil];
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    return image;
}
//快进、快退
-(void)seekToTime:(NSInteger)seekTime{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        //先暂停
        self.state = ZHPlayerPlayStatePause;
        CMTime seekCMTime = CMTimeMake(seekTime, 1);
        __weak typeof(self) wkSelf = self;
        [self.player seekToTime:seekCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            wkSelf.state = ZHPlayerPlayStatePlaying;
        }];
    }
}
//重播
- (void)replay{
    [self seekToTime:0];
}
//重新加载
-(void)reload{
    [self configPlayer];
}
#pragma mark - Private Method

- (void)configPlayer{
    
    self.resouceLoader = [[ZHPlayerResouceLoader alloc] init];
    
    self.urlAsset = [AVURLAsset URLAssetWithURL:self.videoUrl options:nil];
    
//    self.urlAsset = [AVURLAsset URLAssetWithURL:[self customSchemeURL] options:nil];
//    [self.urlAsset.resourceLoader setDelegate:self.resouceLoader queue:dispatch_get_main_queue()];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.videoGravity = self.videoGravity;
    
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    [self observeTime];
}

- (NSURL *)customSchemeURL {
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:self.videoUrl resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

//置空player相关
- (void)setNilPlayer{
    if (self.playerObserve) {
        [self.player removeTimeObserver:self.playerObserve];
        self.playerObserve = nil;
    }
    //暂停
    if (self.player.currentItem.status == ZHPlayerPlayStatePlaying) {
        [self pause];
    }
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //移除原来的layer
    [self.playerLayer removeFromSuperlayer];
    //替换PlayerItem为nil
    [self.player replaceCurrentItemWithPlayerItem:nil];
    //把player置为nil
    self.player = nil;
    
}
//实时观测时间
- (void)observeTime{
    __weak ZHPlayerView *wkSelf = self;
    self.playerObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time) {
        
        AVPlayerItem *playerItem = wkSelf.playerItem;
        CMTime duration = playerItem.asset.duration;
        
        CGFloat currentTime = CMTimeGetSeconds(time);   //已浏览时长
        CGFloat totalTime = CMTimeGetSeconds(duration); //总时长
        
        BOOL seekAble = NO;
        seekAble = playerItem.duration.timescale == 0 ? NO : YES;
        //总结
        //若是直播，则不能快进，即seek
        //如何区别直播和点播？
        //直播时 playerItem.duration.timescale = 0,作为分母=0，得到的总时长是无效的，这符合直播具体时长的特点
        //点播时 playerItem.duration.timescale != 0，而是有一个具体的正整数值，得到的总时长是具体的值。且playerItem.seekableTimeRanges可以得到可seek的time范围。
        
        if ([wkSelf.delegate respondsToSelector:@selector(observeTime:totalTime:seekAble:)]) {
            [wkSelf.delegate observeTime:currentTime totalTime:totalTime seekAble:seekAble];
        }
    }];
}
//添加观察者
- (void)addNotificationCenter{
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zhPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}
//移除观察者
- (void)removeNotificationCenter{
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
}
//计算缓冲进度
- (NSTimeInterval)loadedProgress {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    //获取缓冲区域
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    //计算缓冲总进度
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}
//显示占位图
- (void)showPlaceHolderImage{
    self.placeHolderImageView.hidden = NO;
    [UIView animateWithDuration:1.0 animations:^{
        self.placeHolderImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}
//隐藏占位图
- (void)hidePlaceHolderImage{
    [UIView animateWithDuration:1.0 animations:^{
        self.placeHolderImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.placeHolderImageView.hidden = YES;
    }];
}


#pragma mark - layoutsubviews

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (!_placeHolderImageView) {
        [self insertSubview:self.placeHolderImageView atIndex:0];
    }
    
    if (!self.player.currentItem) {
        [self configPlayer];
    }
    self.playerLayer.frame = self.layer.bounds;
}

-(void)dealloc{
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 移除time观察者
    if (self.playerObserve) {
        [self.player removeTimeObserver:self.playerObserve];
        self.playerObserve = nil;
    }
}

#pragma mark - Observe

- (void)zhPlayDidEnd:(NSNotification *)notification{
    self.state = ZHPlayerPlayStatePlayOver;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.player.currentItem) {
        
        if ([keyPath isEqualToString:@"status"]) {
            
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                if (self.autoPlay) {
                    self.state = ZHPlayerPlayStatePlaying;
                }
            }else if (self.player.currentItem.status == AVPlayerItemStatusFailed){
                self.state = ZHPlayerPlayStatePlayFail;
            }
            
        }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self loadedProgress];
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            NSLog(@"缓冲：%f",timeInterval / totalDuration);
            
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
            //缓冲中
//            if (self.player.currentItem.playbackBufferEmpty) {
                self.state = ZHPlayerPlayStateBuffering;
//            }
            
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
            //缓冲结束
            if (self.playerItem.playbackLikelyToKeepUp && self.state == ZHPlayerPlayStateBuffering) {
                self.state = ZHPlayerPlayStatePlaying;
            }
        }else if ([keyPath isEqualToString:@""]){
            
        }
    }
}

#pragma mark - Setter and Getter

-(void)setState:(ZHPlayerPlayState)state{
    _state = state;
    //不同状态对应的处理
    if (state == ZHPlayerPlayStateBuffering) {
        //缓冲中，显示菊花
    }else if (state == ZHPlayerPlayStatePlaying){
        [self.player play];
        [self hidePlaceHolderImage];
    }else if (state == ZHPlayerPlayStatePlayFail){
        //显示占位图
        [self showPlaceHolderImage];
    }else if (state == ZHPlayerPlayStatePlayOver){
        //显示占位图
        [self showPlaceHolderImage];
    }else if (state == ZHPlayerPlayStatePause){
        [self.player pause];
    }else if (state == ZHPlayerPlayStateStop){
        [self.player pause];
    }
    
    
    
    if ([_delegate respondsToSelector:@selector(zhPlayerPlayStateDidChanged:)]) {
        [_delegate zhPlayerPlayStateDidChanged:_state];
    }
}

-(UIImageView *)placeHolderImageView{
    if (!_placeHolderImageView) {
        _placeHolderImageView = [[UIImageView alloc] init];
        _placeHolderImageView.frame = self.bounds;
        _placeHolderImageView.image = _placeHolderImage;
        _placeHolderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _placeHolderImageView;
}

-(void)setPlayerItem:(AVPlayerItem *)playerItem{
    
    [self removeNotificationCenter];
    _playerItem = playerItem;
    [self addNotificationCenter];
}

#pragma mark - 下面是处理缓存，暂时还没用
#pragma mark - AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"loadingRequest:%@\nloadingRequest.dataRequest:%lld\n%lld\n%ld",loadingRequest.request.URL,loadingRequest.dataRequest.requestedOffset,loadingRequest.dataRequest.currentOffset,loadingRequest.dataRequest.requestedLength);
    
    return YES;
}

//- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForRenewalOfRequestedResource:(AVAssetResourceRenewalRequest *)renewalRequest{
//    return YES;
//}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    
}

//- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForResponseToAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge{
//    
//}
//- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)authenticationChallenge{
//    
//}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
