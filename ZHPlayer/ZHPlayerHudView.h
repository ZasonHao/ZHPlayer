//
//  ZHPlayerHudView.h
//
//  Created by Zason Hao.
//
//
//  本类还没处理好

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ZHPlayerHudViewType){
    ZHPlayerHudViewTypeSpeed,       //快进、快退
    
};


@interface ZHPlayerHudView : UIView

//单利
+ (ZHPlayerHudView *)shareInstance;

/*
 *  显示
 *  superView   父视图
 *  type        hud类型
 */
- (void)showOnTheView:(UIView *)superView hudType:(ZHPlayerHudViewType)type;

/*
 *  隐藏
 */
- (void)hide;

/*
 *  ZHPlayerHudViewTypeSpeed类型时调用
 *  speed       时间
 *  forward     方向
 */
- (void)setSpeed:(NSString *)speed direction:(BOOL)forward;

@end
