//
//  ViewPathPath.m
//  ViewPath
//
//  Created by lyb on 2017/5/9.
//  Copyright © 2017年 lyb. All rights reserved.
//

#import "ViewPath.h"
#import "YBRectConst.h"

@implementation ViewPath

+ (CAShapeLayer *)yb_maskLayerWithRect:(CGRect)rect
                            rectCorner:(NSArray *)rectCorner
                          cornerRadius:(CGFloat)cornerRadius
                           borderColor:(UIColor *)borderColor
                       backgroundColor:(UIColor *)backgroundColor
                            arrowWidth:(CGFloat)arrowWidth
                           arrowHeight:(CGFloat)arrowHeight
                         arrowPosition:(CGFloat)arrowPosition
                        arrowDirection:(ViewPathArrowDirection)arrowDirection
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [self yb_bezierPathWithRect:rect rectCorner:rectCorner cornerRadius:cornerRadius borderWidth:0 borderColor:borderColor backgroundColor:backgroundColor arrowWidth:arrowWidth arrowHeight:arrowHeight arrowPosition:arrowPosition arrowDirection:arrowDirection].CGPath;
    shapeLayer.fillColor = [backgroundColor CGColor];
    shapeLayer.strokeColor = [borderColor CGColor];
    return shapeLayer;
}


+ (UIBezierPath *)yb_bezierPathWithRect:(CGRect)rect
                             rectCorner:(NSArray *)rectCorner
                           cornerRadius:(CGFloat)cornerRadius
                            borderWidth:(CGFloat)borderWidth
                            borderColor:(UIColor *)borderColor
                        backgroundColor:(UIColor *)backgroundColor
                             arrowWidth:(CGFloat)arrowWidth
                            arrowHeight:(CGFloat)arrowHeight
                          arrowPosition:(CGFloat)arrowPosition
                         arrowDirection:(ViewPathArrowDirection)arrowDirection
{
    //创建一个Bezier path对象。
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    if (borderColor) {
        [[UIColor whiteColor] setStroke];
    }
    if (backgroundColor) {
        [[UIColor redColor] setFill];
    }
    bezierPath.lineWidth = borderWidth;
    rect = CGRectMake(borderWidth / 2, borderWidth / 2, YBRectWidth(rect) - borderWidth, YBRectHeight(rect) - borderWidth);
    CGFloat topRightRadius = [rectCorner[0] floatValue],topLeftRadius = [rectCorner[1] floatValue],bottomRightRadius = [rectCorner[2] floatValue],bottomLeftRadius = [rectCorner[3] floatValue];
    CGPoint topRightArcCenter,topLeftArcCenter,bottomRightArcCenter,bottomLeftArcCenter;


    if (arrowDirection == ViewPathArrowDirectionTop) {
        topLeftArcCenter = CGPointMake(topLeftRadius + YBRectX(rect), arrowHeight + topLeftRadius + YBRectX(rect));
        topRightArcCenter = CGPointMake(YBRectWidth(rect) - topRightRadius + YBRectX(rect), arrowHeight + topRightRadius + YBRectX(rect));
        bottomLeftArcCenter = CGPointMake(bottomLeftRadius + YBRectX(rect), YBRectHeight(rect) - bottomLeftRadius + YBRectX(rect));
        bottomRightArcCenter = CGPointMake(YBRectWidth(rect) - bottomRightRadius + YBRectX(rect), YBRectHeight(rect) - bottomRightRadius + YBRectX(rect));
        if (arrowPosition < topLeftRadius + arrowWidth / 2) {
            arrowPosition = topLeftRadius + arrowWidth / 2;
        }else if (arrowPosition > YBRectWidth(rect) - topRightRadius - arrowWidth / 2) {
            arrowPosition = YBRectWidth(rect) - topRightRadius - arrowWidth / 2;
        }
        //使用方法moveToPoint:去设置初始线段的起点
        [bezierPath moveToPoint:CGPointMake(arrowPosition - arrowWidth / 2, arrowHeight + YBRectX(rect))];
        //添加line或者curve去定义一个或者多个subpaths。
        [bezierPath addLineToPoint:CGPointMake(arrowPosition, arrowHeight * 2 + YBRectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(arrowPosition + arrowWidth / 2, arrowHeight + YBRectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(YBRectWidth(rect) - topRightRadius, arrowHeight + YBRectX(rect))];
        
        [bezierPath addArcWithCenter:topRightArcCenter radius:topRightRadius startAngle:M_PI * 3 / 2 endAngle:2 * M_PI clockwise:YES];
        
        [bezierPath addLineToPoint:CGPointMake(YBRectWidth(rect) + YBRectX(rect), YBRectHeight(rect) - bottomRightRadius - YBRectX(rect))];
        [bezierPath addArcWithCenter:bottomRightArcCenter radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(bottomLeftRadius + YBRectX(rect), YBRectHeight(rect) + YBRectX(rect))];
        [bezierPath addArcWithCenter:bottomLeftArcCenter radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(YBRectX(rect), arrowHeight + topLeftRadius + YBRectX(rect))];
        [bezierPath addArcWithCenter:topLeftArcCenter radius:topLeftRadius startAngle:M_PI endAngle:M_PI * 3 / 2 clockwise:YES];
        
    }else if (arrowDirection == ViewPathArrowDirectionBottom) {
        topLeftArcCenter = CGPointMake(topLeftRadius + YBRectX(rect),topLeftRadius + YBRectX(rect));
        topRightArcCenter = CGPointMake(YBRectWidth(rect) - topRightRadius + YBRectX(rect), topRightRadius + YBRectX(rect));
        bottomLeftArcCenter = CGPointMake(bottomLeftRadius + YBRectX(rect), YBRectHeight(rect) - bottomLeftRadius + YBRectX(rect) - arrowHeight);
        bottomRightArcCenter = CGPointMake(YBRectWidth(rect) - bottomRightRadius + YBRectX(rect), YBRectHeight(rect) - bottomRightRadius + YBRectX(rect) - arrowHeight);
        if (arrowPosition < bottomLeftRadius + arrowWidth / 2) {
            arrowPosition = bottomLeftRadius + arrowWidth / 2;
        }else if (arrowPosition > YBRectWidth(rect) - bottomRightRadius - arrowWidth / 2) {
            arrowPosition = YBRectWidth(rect) - bottomRightRadius - arrowWidth / 2;
        }
        [bezierPath moveToPoint:CGPointMake(arrowPosition + arrowWidth / 2, YBRectHeight(rect) - arrowHeight + YBRectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(arrowPosition, YBRectHeight(rect) + YBRectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(arrowPosition - arrowWidth / 2, YBRectHeight(rect) - arrowHeight + YBRectX(rect))];
        [bezierPath addLineToPoint:CGPointMake(bottomLeftRadius + YBRectX(rect), YBRectHeight(rect) - arrowHeight + YBRectX(rect))];
        [bezierPath addArcWithCenter:bottomLeftArcCenter radius:bottomLeftRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(YBRectX(rect), topLeftRadius + YBRectX(rect))];
        [bezierPath addArcWithCenter:topLeftArcCenter radius:topLeftRadius startAngle:M_PI endAngle:M_PI * 3 / 2 clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(YBRectWidth(rect) - topRightRadius + YBRectX(rect), YBRectX(rect))];
        [bezierPath addArcWithCenter:topRightArcCenter radius:topRightRadius startAngle:M_PI * 3 / 2 endAngle:2 * M_PI clockwise:YES];
        [bezierPath addLineToPoint:CGPointMake(YBRectWidth(rect) + YBRectX(rect), YBRectHeight(rect) - bottomRightRadius - YBRectX(rect) - arrowHeight)];
        [bezierPath addArcWithCenter:bottomRightArcCenter radius:bottomRightRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
        
    }
    
    [bezierPath closePath];
    return bezierPath;
}

@end
