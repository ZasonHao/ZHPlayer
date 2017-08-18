//
//  ZHPlayerHudView.m
//
//  Created by Zason Hao.
//

#import "ZHPlayerHudView.h"

@interface ZHPlayerHudView (){
    ZHPlayerHudViewType _type;
}

@property (nonatomic,strong) UIImageView *speedLogo;

@property (nonatomic,strong) UILabel *speedLabel;

@property (nonatomic,strong) UIView *backGroundView;

@end

@implementation ZHPlayerHudView

+ (ZHPlayerHudView *)shareInstance{
    static ZHPlayerHudView *hudView;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        hudView = [[ZHPlayerHudView alloc] init];
    });
    return hudView;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)showOnTheView:(UIView *)superView hudType:(ZHPlayerHudViewType)type{
    _type = type;
    if (!self.superview) {
        //        [superView addSubview:self];
        [superView insertSubview:self atIndex:0];
        self.frame = superView.bounds;
    }
}

- (void)hide{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alpha = 1.0f;
    }];
    
}

- (void)setUpUI{
    
    switch (_type) {
        case ZHPlayerHudViewTypeSpeed:
            [self loadSpeedView];
            break;
            
        default:
            break;
    }
    
}
//加载speedView
- (void)loadSpeedView{
    
    [self addSubview:self.backGroundView];
    [self.backGroundView addSubview:self.speedLogo];
    [self.backGroundView addSubview:self.speedLabel];
}

-(void)setSpeed:(NSString *)speed direction:(BOOL)forward{
    
    if (forward) {
        _speedLogo.image = [UIImage imageNamed:@"player_fast_forward"];
    }else{
        _speedLogo.image = [UIImage imageNamed:@"player_fast_backward"];
    }
    
    if (self.speedLabel) {
        _speedLabel.text = speed;
    }
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self setUpUI];
}

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    self.center = [self.superview.superview convertPoint:self.superview.center fromView:self.superview];
}
#pragma mark - Setter and Getter

-(UIView *)backGroundView{
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc] init];
        _backGroundView.frame = CGRectMake(0, 0, 120, 70);
        _backGroundView.center = [self.superview convertPoint:self.center fromView:self];
        _backGroundView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.7];
        _backGroundView.layer.cornerRadius = 5.0f;
        _backGroundView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    return _backGroundView;
}
-(UIImageView *)speedLogo{
    if (!_speedLogo) {
        _speedLogo = [[UIImageView alloc] init];
        _speedLogo.frame = CGRectMake(0, 0, 40, 40);
        CGPoint center = [self.backGroundView convertPoint:self.backGroundView.center fromView:self];
        _speedLogo.center = CGPointMake(center.x, 20);
    }
    return _speedLogo;
}

-(UILabel *)speedLabel{
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc] init];
        _speedLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.backGroundView.frame), 30);
        CGPoint center = [self.backGroundView convertPoint:self.backGroundView.center fromView:self];
        _speedLabel.center = CGPointMake(center.x, CGRectGetHeight(self.backGroundView.frame)-15);
        _speedLabel.textColor = [UIColor whiteColor];
        _speedLabel.font = [UIFont systemFontOfSize:14];
        _speedLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _speedLabel;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
