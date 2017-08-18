//
//  UIView+ZHPlayer.m
//
//  Created by Zason Hao.
//

#import "UIView+ZHPlayer.h"

@implementation UIView (ZHPlayer)

- (void)setLineGradientBackgroundColorWithColor:(UIColor *)color from:(CGPoint)from to:(CGPoint)to{
    CAGradientLayer *layer = (CAGradientLayer *)self.layer.sublayers[0];
    if (layer && ![layer isKindOfClass:[CAGradientLayer class]]) {
        CAGradientLayer *graLayer = [CAGradientLayer layer];
        graLayer.colors = @[(__bridge id)color.CGColor,(__bridge id)[UIColor clearColor].CGColor];
        graLayer.locations = @[@0.0,@1.0];
        graLayer.startPoint = from;
        graLayer.endPoint = to;
        graLayer.frame = self.bounds;
        [graLayer layoutIfNeeded];
        [self.layer insertSublayer:graLayer atIndex:0];
    }
    if (layer && [layer isKindOfClass:[CAGradientLayer class]]) {
        layer.frame = self.bounds;
    }
    if (!layer) {
        layer = [CAGradientLayer layer];
        layer.colors = @[(__bridge id)color.CGColor,(__bridge id)[UIColor clearColor].CGColor];
        layer.locations = @[@0.0,@1.0];
        layer.startPoint = from;
        layer.endPoint = to;
        layer.frame = self.bounds;
        [layer layoutIfNeeded];
        [self.layer insertSublayer:layer atIndex:0];
    }
}

@end
