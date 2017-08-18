//
//  UIView+ZHPlayer.h
//
//  Created by Zason Hao.
//

#import <UIKit/UIKit.h>

@interface UIView (ZHPlayer)

/*
 * 线性渐变色
 * color    渐变色
 * from     渐变起始位置
 * to       渐变终点位置
 *
 */
- (void)setLineGradientBackgroundColorWithColor:(UIColor *)color from:(CGPoint)from to:(CGPoint)to;

@end
