//
//  ToggleButton.m
//  zwpg-ios
//  开关按钮，继承自UIButton
//  Created by nijino on 13-4-27.
//  Copyright (c) 2013年 nijino. All rights reserved.
//  QQ:20118368
//  http://www.nijino.cn

#import "ToggleButton.h"

@implementation ToggleButton

- (void)setSelected:(BOOL)selected {
    if (selected) {
         [self setImage:self.onImage forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5 delay:0.00 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeRotation(M_PI_2);
            
        } completion:^(BOOL finished) {
            
        }];
    }else {
         [self setImage:self.offImage forState:UIControlStateNormal];
        [UIView animateWithDuration:0.5 delay:0.00 usingSpringWithDamping:0.7 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeRotation(0);
            
        } completion:^(BOOL finished) {
        }];
    }
}

+ (instancetype)buttonWithOnImage:(UIImage *)onImage
               offImage:(UIImage *)offImage
       highlightedImage:(UIImage *)highlightedImage{
    ToggleButton *button = [self buttonWithType:UIButtonTypeCustom];
    button.onImage = onImage;
    button.offImage = offImage;
    [button setImage:offImage forState:UIControlStateNormal];
    [button setImage:onImage forState:UIControlStateSelected];
    button.toggleEnabled = YES;
    button.userInteractionEnabled = YES;
    return button;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.toggleEnabled = YES;

        [self setBackgroundImage:nil forState:UIControlStateSelected];

        [self setImage:nil forState:UIControlStateSelected];

    }
    return self;
}


#pragma mark - Toggle Support
- (BOOL)toggle{
    self.selected = !self.selected;
    return self.selected;
}

//Detect a touchUpInside event and perform toggle if toggleEnabled = YES
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    if (self.touchInside && self.toggleEnabled) {
        [self toggle];
    }
}

@end
