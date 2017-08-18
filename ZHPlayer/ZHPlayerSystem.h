//
//  ZHPlayerSystem.h
//
//  Created by Zason Hao.
//
//  调节系统参数

#import <UIKit/UIKit.h>

@interface ZHPlayerSystem : UIView
//屏幕亮度
@property (nonatomic,assign) CGFloat brightness;
//系统音量
@property (nonatomic,assign) CGFloat volume;
//单利
+ (instancetype)sharedInstance;

@end
