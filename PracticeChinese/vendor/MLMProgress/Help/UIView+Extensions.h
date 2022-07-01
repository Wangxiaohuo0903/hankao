//
//  UIView+Extensions.h
//  LXCircleAnimationView
//
//  Created by Leexin on 15/12/18.
//  Copyright © 2015年 Garden.Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<QuartzCore/QuartzCore.h>

@interface UIView (Extensions)

@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height_s;
@property CGFloat width_s;

@property CGFloat top_s;
@property CGFloat left_s;

@property CGFloat bottom_s;
@property CGFloat right_s;

@end


