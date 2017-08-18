//
//  ZHPlayerSystem.m
//
//  Created by Zason Hao.
//

#import "ZHPlayerSystem.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@interface ZHPlayerSystem ()

//构造调节屏幕亮度时需要显示的控件
@property (nonatomic,strong) UILabel *text;

@property (nonatomic,strong) UIImageView *brightnessImage;

@property (nonatomic,strong) UIView *tipsView;

//调节音量的slider
@property (nonatomic,strong) UISlider *volumeSlider;

@end

@implementation ZHPlayerSystem

+ (instancetype)sharedInstance {
    static ZHPlayerSystem *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZHPlayerSystem alloc] init];
    });
    return instance;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        //获取当前屏幕亮度
        _brightness = [UIScreen mainScreen].brightness;
        //获取当前系统音量
        _volume = [[AVAudioSession sharedInstance] outputVolume];
        [self setUI];
    }
    return self;
}

- (void)setUI{
    self.frame = CGRectMake(0, 0, 150, 150);
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    toolbar.alpha = 0.97;
    [self addSubview:toolbar];
    
    [self addSubview:self.text];
    [self addSubview:self.brightnessImage];
    [self addSubview:self.tipsView];
}

-(void)setBrightness:(CGFloat)brightness{
    _brightness = brightness;
    [UIScreen mainScreen].brightness = brightness;
    if (!self.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    [self showTips:brightness];
}

- (void)showTips:(CGFloat)value{
    NSInteger tipNum = value*16;
    for (NSInteger i = 0; i<16; i++) {
        UIView *tip = [_tipsView viewWithTag:222+i];
        if (tip.tag-222 <= tipNum) {
            tip.hidden = NO;
        }else{
            tip.hidden = YES;
        }
    }
    [self autoHide];
}

- (void)autoHide{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self performSelector:@selector(hide) withObject:nil afterDelay:2];
}

- (void)hide{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alpha = 1.0f;
    }];
}
#pragma mark - Setter and Getter

-(UILabel *)text{
    if (!_text) {
        _text = [[UILabel alloc] init];
        _text.text = @"亮度";
        _text.font = [UIFont boldSystemFontOfSize:16];
        _text.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        _text.textAlignment = NSTextAlignmentCenter;
    }
    return _text;
}
-(UIImageView *)brightnessImage{
    if (!_brightnessImage) {
        _brightnessImage = [[UIImageView alloc] init];
        _brightnessImage.image = [UIImage imageNamed:@"player_brightness"];
    }
    return _brightnessImage;
}

-(UIView *)tipsView{
    if (!_tipsView) {
        _tipsView = [[UIView alloc] init];
        _tipsView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
    }
    return _tipsView;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _text.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 20);
    
    _brightnessImage.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    _brightnessImage.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
    
    _text.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/4 - 20);
    
    _tipsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame)*4/5, 7);
    _tipsView.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)*3/4+20);
    CGFloat tipWidth = (CGRectGetWidth(_tipsView.frame)-17)/16;
    for (NSInteger i = 0 ; i<16; i++) {
        UIView *tip = [[UIView alloc] initWithFrame:CGRectMake((tipWidth+1)*i + 1, 1, tipWidth, 5)];
        tip.tag = 222+i;
        tip.backgroundColor = [UIColor whiteColor];
        [_tipsView addSubview:tip];
    }
    
    self.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
}

#pragma mark - 调节音量

-(void)setVolume:(CGFloat)volume{
    _volume = volume;
    self.volumeSlider.value = _volume;
}

-(UISlider *)volumeSlider{
    if (!_volumeSlider) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        for (UIView *view in [volumeView subviews]){
            Class class = NSClassFromString(@"MPVolumeSlider");
            if ([view isKindOfClass:[class class]]){
                _volumeSlider = (UISlider *)view;
                break;
            }
        }
    }
    return _volumeSlider;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
