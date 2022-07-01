////
////  CircularProgressView.h
////  CircularProgressView
////
////  Created by nijino saki on 13-3-2.
////  Copyright (c) 2013年 nijino. All rights reserved.
////  QQ:20118368
////  http://www.nijino.cn
//
//#import <UIKit/UIKit.h>
//#import <AVFoundation/AVFoundation.h>
//#import "ToggleButton.h"
//#import <QuartzCore/QuartzCore.h>
//
//typedef NS_ENUM(NSUInteger, VedioStatus) {
//    VedioStatusPause,       // 暂停播放
//    VedioStatusPlaying,       // 播放中
//    VedioStatusBuffering,     // 缓冲中
//    VedioStatusFinished,       //停止播放
//    VedioStatusFailed        // 播放失败
//};
//
//@protocol CircularProgressViewDelegate <NSObject>
//
//@optional
//
//- (void)updateProgressViewWithPlayer:(AVPlayer *)player;
//- (void)playerDidFinishPlaying;
//
//@end
//
//@interface CircularProgressView : UIView
//
//@property (nonatomic) UIColor *backColor;
//@property (nonatomic) UIColor *progressColor;
//@property (nonatomic,copy) NSString *audioUrl;
//@property (nonatomic) CGFloat lineWidth;
//@property (nonatomic) NSTimeInterval duration;
//@property (nonatomic) BOOL playOrPauseButtonIsPlaying;
//@property (nonatomic) id <CircularProgressViewDelegate> delegate;
//
//
//- (id)initWithFrame:(CGRect)frame
//          backColor:(UIColor *)backColor
//      progressColor:(UIColor *)progressColor
//          lineWidth:(CGFloat)lineWidth
//           audioURL:(NSString *)audioUrl
//       targetObject:(id)targetObject;
//
//- (void)play;
//- (void)pause;
//- (void)stop;
//- (void)playNotChangeAudioImage:(NSString *)audioUrl;
//+ (UIImage *)getThumbnailImage:(NSURL *)videoURL;
//
////新增
//@property (nonatomic, strong) AVPlayer *player;
////播放模型
//@property (nonatomic, strong) AVPlayerItem *playerItem;
////播放状态
//@property (nonatomic, assign) VedioStatus playerStatus;
///** 播放完成 */
//@property (nonatomic, copy)void(^playerFinished)(void);
//
//@property (nonatomic, copy) NSString *videoId;
//
//@property (nonatomic, assign) CGFloat videoProgress;
//
//@property (nonatomic, assign) CGRect frame;
//
//@end
