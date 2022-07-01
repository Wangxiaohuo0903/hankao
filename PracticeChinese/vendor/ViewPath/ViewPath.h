//
//  ViewPath.h
//
//  Created by lyb on 2017/5/9.
//  Copyright © 2017年 lyb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ViewPathArrowDirection) {
    ViewPathArrowDirectionTop = 0,  //箭头朝上
    ViewPathArrowDirectionBottom,   //箭头朝下
    ViewPathArrowDirectionLeft,     //箭头朝左
    ViewPathArrowDirectionRight,    //箭头朝右
    ViewPathArrowDirectionNone      //没有箭头
};

@interface ViewPath : NSObject

+ (CAShapeLayer *)yb_maskLayerWithRect:(CGRect)rect
                            rectCorner:(NSArray *)rectCorner
                          cornerRadius:(CGFloat)cornerRadius
                           borderColor:(UIColor *)borderColor
                       backgroundColor:(UIColor *)backgroundColor
                            arrowWidth:(CGFloat)arrowWidth
                           arrowHeight:(CGFloat)arrowHeight
                         arrowPosition:(CGFloat)arrowPosition
                        arrowDirection:(ViewPathArrowDirection)arrowDirection;

+ (UIBezierPath *)yb_bezierPathWithRect:(CGRect)rect
                             rectCorner:(NSArray *)rectCorner
                           cornerRadius:(CGFloat)cornerRadius
                            borderWidth:(CGFloat)borderWidth
                            borderColor:(UIColor *)borderColor
                        backgroundColor:(UIColor *)backgroundColor
                             arrowWidth:(CGFloat)arrowWidth
                            arrowHeight:(CGFloat)arrowHeight
                          arrowPosition:(CGFloat)arrowPosition
                         arrowDirection:(ViewPathArrowDirection)arrowDirection;
@end
