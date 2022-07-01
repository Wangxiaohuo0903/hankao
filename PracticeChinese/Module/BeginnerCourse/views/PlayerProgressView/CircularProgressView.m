////
////  CircularProgressView.m
////  CircularProgressView
////
////  Created by nijino saki on 13-3-2.
////  Copyright (c) 2013年 nijino. All rights reserved.
////  QQ:20118368
////  http://www.nijino.cn
//
//#import "CircularProgressView.h"
//
//
//@interface CircularProgressView ()<AVAudioPlayerDelegate>
//@property (nonatomic) CAShapeLayer *progressLayer;
//@property (nonatomic) float progress;
//@property (nonatomic) CGFloat angle;//angle between two lines
//@property (strong, nonatomic)ToggleButton *playOrPauseButton;
//@property (nonatomic) BOOL showProgress;//选择正确读音后是不需要更改状态的，不需要进度
//
////总播放时长
//@property (nonatomic, assign) CGFloat totalTime;
////监听者
//@property (nonatomic, strong) id timeObserver;
//
//@end
//
//@implementation CircularProgressView
//
//- (id)initWithFrame:(CGRect)frame
//          backColor:(UIColor *)backColor
//      progressColor:(UIColor *)progressColor
//          lineWidth:(CGFloat)lineWidth
//           audioURL:(NSString *)audioUrl
//       targetObject:(id)targetObject
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.layer.backgroundColor = [[UIColor orangeColor] CGColor];
//        _backColor = backColor;
//        _progressColor = progressColor;
//        self.lineWidth = lineWidth;
//        _audioUrl = audioUrl;
//        [self initUI];
//        [self setUp];
//    }
//    return self;
//}
//
//- (id)initWithCoder:(NSCoder *)aDecoder{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        [self setUp];
//    }
//    return self;
//}
//
//- (void)setUp{
//    self.playOrPauseButton = [ToggleButton buttonWithOnImage:[UIImage imageNamed:@"playing_new"] offImage:[UIImage imageNamed:@"pause_new"] highlightedImage:[UIImage imageNamed:@"in_recording"]];
//    self.playOrPauseButton.frame = CGRectMake(3, 3, self.bounds.size.width - 6, self.bounds.size.height - 6);
//    self.playOrPauseButton.selected = NO;
//    self.playOrPauseButton.layer.masksToBounds = YES;
//    [self.playOrPauseButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.playOrPauseButton];
//}
//
//- (void)setLineWidth:(CGFloat)lineWidth{
//    CAShapeLayer *backgroundLayer = [self createRingLayerWithCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:CGRectGetWidth(self.bounds) / 2 - lineWidth / 2 lineWidth:lineWidth color:self.backColor];
//    _lineWidth = lineWidth;
//    [self.layer addSublayer:backgroundLayer];
//    _progressLayer = [self createRingLayerWithCenter:CGPointMake(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2) radius:CGRectGetWidth(self.bounds) / 2 - lineWidth / 2 lineWidth:lineWidth color:self.progressColor];
//    _progressLayer.strokeEnd = 0;
//    [self.layer addSublayer:_progressLayer];
//}
//
//- (void)setAudioUrl:(NSString *)audioUrl{
//    _audioUrl = audioUrl;
//    [self initPlayer];
//    [self addPlayerListener];
//    //播放完成通知监听
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
//}
//
//- (CAShapeLayer *)createRingLayerWithCenter:(CGPoint)center radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth color:(UIColor *)color {
//    UIBezierPath *smoothedPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:- M_PI_2 endAngle:(M_PI + M_PI_2) clockwise:YES];
//    CAShapeLayer *slice = [CAShapeLayer layer];
//    slice.contentsScale = [[UIScreen mainScreen] scale];
//    slice.frame = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
//    slice.fillColor = [UIColor clearColor].CGColor;
//    slice.strokeColor = color.CGColor;
//    slice.lineWidth = lineWidth;
//    slice.lineCap = kCALineJoinBevel;
//    slice.lineJoin = kCALineJoinBevel;
//    slice.path = smoothedPath.CGPath;
//    return slice;
//}
//
//- (void)setProgress:(float)progress{
//    if (_showProgress == NO) {
//        return;
//    }
//    NSLog(@"播放进度-%f",progress);
//    if (progress <= 0.0001) {
//        self.progressLayer.hidden = YES;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.progressLayer.strokeEnd = 0;
//        });
//    }else {
//        self.progressLayer.hidden = NO;
//        self.progressLayer.strokeEnd = progress;
//    }
//}
//
//- (void)updateProgressCircle{
//
//    if (self.playerItem.currentTime.value<0) {
//        self.progress = 0.1; //防止出现时间计算越界问题
//    }
//
//    if (self.delegate && [self.delegate conformsToProtocol:@protocol(CircularProgressViewDelegate)]) {
//        [self.delegate updateProgressViewWithPlayer:self.player];
//    }
//}
//
//
//#pragma mark AVAudioPlayerDelegate method
//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    if (flag) {
//        //restore progress value
//        self.progress = 0;
//        [self.delegate playerDidFinishPlaying];
//    }
//}
//
//- (void)updatePlayOrPauseButton{
//    self.playOrPauseButton.selected = YES;
//}
//
//
////calculate angle between start to point
//- (CGFloat)angleFromStartToPoint:(CGPoint)point{
//    CGFloat angle = [self angleBetweenLinesWithLine1Start:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2)
//                                                 Line1End:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2 - 1)
//                                               Line2Start:CGPointMake(CGRectGetWidth(self.bounds) / 2,CGRectGetHeight(self.bounds) / 2)
//                                                 Line2End:point];
//    if (CGRectContainsPoint(CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame)), point)) {
//        angle = 2 * M_PI - angle;
//    }
//    return angle;
//}
//
////calculate angle between 2 lines
//- (CGFloat)angleBetweenLinesWithLine1Start:(CGPoint)line1Start
//                                  Line1End:(CGPoint)line1End
//                                Line2Start:(CGPoint)line2Start
//                                  Line2End:(CGPoint)line2End{
//    CGFloat a = line1End.x - line1Start.x;
//    CGFloat b = line1End.y - line1Start.y;
//    CGFloat c = line2End.x - line2Start.x;
//    CGFloat d = line2End.y - line2Start.y;
//    return acos(((a * c) + (b * d)) / ((sqrt(a * a + b * b)) * (sqrt(c * c + d * d))));
//}
//
//
////新增
//
//
//#pragma mark 初始化基础UI
//- (void)initUI {
//    _showProgress = YES;
//    self.player = [[AVPlayer alloc]init];
//    self.playerStatus = VedioStatusFinished;
//
//}
//
//#pragma mark 初始化播放文件，只允许在播放按钮事件使用
//- (void)initPlayer {
//    [self initPlayerItem];
//}
//
//#pragma mark 初始化playerItem
//- (void)initPlayerItem {
////    if (_audioUrl) {
//        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:_audioUrl]];
//        self.playerItem = playerItem;
//        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
//        //播放状态监听
//        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//        //缓冲进度监听
//        [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
////    }
//}
//
//#pragma mark 播放速度、播放状态、播放进度、后台等用户操作、横竖屏监听
//- (void)addPlayerListener {
//
//    if (self.player) {
//        //播放速度监听
//        [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
//
//        //播放中监听，更新播放进度
//        __weak typeof(self) weakself = self;
//        self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//            double currentPlayTime = (double)weakself.playerItem.currentTime.value/weakself.playerItem.currentTime.timescale;
//
//            if (weakself.playerItem.currentTime.value<0) {
//                currentPlayTime = 0.1; //防止出现时间计算越界问题
//            }
//            weakself.progress = currentPlayTime/_totalTime;
//        }];
//    }
//
//    //监听应用后台切换
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(appEnteredBackground)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:nil];
//    //播放中被打断
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
//}
//
//#pragma mark 播放对象监听、缓冲值，播放状态
//
//
//
//#pragma mark 监听捕获
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    int new = (int)[change objectForKey:@"new"];
//    int old = (int)[change objectForKey:@"old"];
//    if ([keyPath isEqualToString:@"status"]) {     //播放状态
//        if (new == old) {
//            return;
//        }
//        AVPlayerItem *item = (AVPlayerItem *)object;
//        if ([self.playerItem status] == AVPlayerStatusReadyToPlay) {
//            //获取音频总长度
//            CMTime duration = item.duration;
//            [self setMaxDuratuin:CMTimeGetSeconds(duration)];
//        } else if([self.playerItem status] == AVPlayerStatusFailed) {
//            //播放异常
//            [self playerFailed];
//        } else if([self.playerItem status] == AVPlayerStatusUnknown) {
//            //未知原因停止
//            [self pause];
//        }
//    } else if([keyPath isEqualToString:@"loadedTimeRanges"]) { //缓冲进度
//        NSArray * array = ((AVPlayerItem *)object).loadedTimeRanges;
//        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
//        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
//        //当缓存到位后开启播放，取消loading
//        if (totalBuffer >= _totalTime && self.playerStatus != VedioStatusFinished) {
//            NSLog(@"缓冲完了，开始");
//            //            [self play];
//        }
//        NSLog(@"---共缓冲---%.2f",totalBuffer);
//    } else if ([keyPath isEqualToString:@"rate"]){ //播放速度
//        if (new == old) {
//            return;
//        }
//        AVPlayer *item = (AVPlayer *)object;
//        if (item.rate == 0 && self.playerStatus != VedioStatusFinished) {
//            self.playerStatus = VedioStatusBuffering;
//        } else if (item.rate == 1) {
//            self.playerStatus = VedioStatusPlaying;
//
//        }
//    }
//}
//
////销毁player,无奈之举 因为avplayeritem的制空后依然缓存的问题。
//#pragma mark 销毁播放item
//- (void)destoryPlayerItem {
//    [self pause];
//    if (_playerItem) {
//        [_playerItem removeObserver:self forKeyPath:@"status"];
//        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
//        _playerItem = nil;
//        [_player replaceCurrentItemWithPlayerItem:nil];
//    }
//
//    _playerStatus = VedioStatusFinished;
//
//}
//#pragma mark 销毁
//-(void)dealloc {
//    //remove监听 销毁播放对象
//    [self destroyPlayer];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//#pragma mark 销毁所有
//- (void)destroyPlayer {
//    [self destoryPlayerItem];
//    [_player removeObserver:self forKeyPath:@"rate"];
//    [_player removeTimeObserver:_timeObserver];
//    _player = nil;
//}
//
//#pragma mark 播放, 暂停, 停止
//- (void)play{
//    _showProgress = YES;
//    if (_audioUrl == nil) {
//        return;
//    }
//    if (self.player && self.playerStatus == VedioStatusFinished) {
//        NSLog(@"通过播放开始");
//
//        self.playOrPauseButton.selected = YES;
//        self.playerStatus = VedioStatusBuffering;
//        [self.player play];
//    }
//}
//- (void)playNotChangeAudioImage:(NSString *)audioUrl{
//    _audioUrl = audioUrl;
//    _showProgress = NO;
//    if (_audioUrl == nil) {
//        return;
//    }
//    if (self.player && self.playerStatus == VedioStatusFinished) {
//        self.playerStatus = VedioStatusBuffering;
//        [self.player play];
//    }
//}
//#pragma 暂停
//- (void)pause{
//    //VedioStatusPause,       // 暂停播放
//    [self.playerItem seekToTime:kCMTimeZero];
//    self.progress = 0;
//    if (self.player && self.playerStatus != VedioStatusFinished) {
//        NSLog(@"通过暂停停止");
//        self.playOrPauseButton.selected = NO;
//        self.playerStatus = VedioStatusFinished;
//        [self.player pause];
//    }
//}
//- (void)stop {
//
//    self.playOrPauseButton.selected = NO;
//    [self.playerItem seekToTime:kCMTimeZero];
//    self.progress = 0;
//    if (self.player && self.playerStatus != VedioStatusFinished) {
//        NSLog(@"通过暂停停止");
//        self.playerStatus = VedioStatusFinished;
//        [self.player pause];
//    }
//}
//#pragma mark 播放按钮事件
//- (void)playButtonAction:(UIButton *)sender {
//    if (self.playerItem) {
//        if (self.playerStatus == VedioStatusFinished) {
//            [self play];
//        } else {
//            [self pause];
//        }
//    } else {
//        [self initPlayer];
//        [self play];
//    }
//}
//
//#pragma mark 监听播放完成事件
//-(void)playerFinished:(NSNotification *)notification{
//    NSLog(@"播放完成");
//    _playerItem = [notification object];
//    self.playOrPauseButton.selected = NO;
//    [self pause];
//    if (self.playerFinished) {
//        self.playerFinished();
//    }
//}
//
//#pragma mark 播放失败
//-(void)playerFailed{
//    NSLog(@"播放失败");
//    self.playOrPauseButton.selected = NO;
//    [self pause];
//    if (self.playerFinished) {
//        self.playerFinished();
//    }
//}
//
//#pragma mark 设置时间轴最大时间
//- (void)setMaxDuratuin:(CGFloat)duration {
//    _totalTime = duration;
//}
//
//
//
//@end
