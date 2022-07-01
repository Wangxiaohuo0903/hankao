//
//  CircularProgressView.swift
//  ChineseDev
//
//  Created by Temp on 2018/7/10.
//  Copyright © 2018年 msra. All rights reserved.
//

import UIKit
import AVFoundation

enum VedioStatus {
    case pause
    // 暂停播放
    case playing
    // 播放中
    case buffering
    // 缓冲中
    case finished
    //停止播放
    case failed
}
protocol CircularProgressViewDelegate: NSObjectProtocol {
    
    func playerDidFinishPlaying()
}

class CircularProgressView: UIView,AVAudioPlayerDelegate {

    var backColor: UIColor?
    var progressColor: UIColor?
    var duration: TimeInterval = 0.0
    var playOrPauseButtonIsPlaying = false
    weak var delegate: CircularProgressViewDelegate?

    //新增
    
    var player: AVPlayer!
    //播放模型
    var playerItem: AVPlayerItem?
    //播放状态
    var playerStatus: VedioStatus?
    /** 开始播放 */
    var playerStarted: (() -> Void)?
    /** 播放完成 */
    var playerFinishedBlock: (() -> Void)?
    var videoId = ""
    var videoProgress: CGFloat = 0.0
    var progressLayer: CAShapeLayer!
    var progress: Float = 0.0
    var angle: CGFloat = 0.0
    //设置圆圈
    var lineWidth: CGFloat = 0.0 
    //angle between two lines
    var playOrPauseButton = ToggleButton()
    var showProgress = false
    //选择正确读音后是不需要更改状态的，不需要进度
    //总播放时长
    var totalTime: CGFloat = 0.0
    //监听者
    var timeObserver: Any?
    //设置音频
    
    
    var Scope:String = ""
    var Lessonid:String = ""
    var Subscope:String = ""
    var IndexPath:String = ""
    
    var audioUrl:String? {
        didSet {
            initPlayer()
            addPlayerListener()
            //播放完成通知监听
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerFinished(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        }
    }
    
    init(frame: CGRect, back: UIColor?, progressColor: UIColor?, lineWidth: CGFloat, audioURL: String?, targetObject: Any?) {
        super.init(frame: frame)
        self.backColor = back
        self.progressColor = progressColor
        self.lineWidth = lineWidth
        self.audioUrl = audioURL
        initUI()
        setUp()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
        
    }
    //初始化播放按钮
    func setUp() {
        playOrPauseButton.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        playOrPauseButton.isSelected = false
        playOrPauseButton.layer.masksToBounds = true
        playOrPauseButton.addTarget(self, action: #selector(self.playButtonAction(_:)), for: .touchUpInside)
        addSubview(playOrPauseButton)
    }
    
    // MARK: 播放按钮事件
    @objc func playButtonAction(_ sender: UIButton?) {
        if playerItem != nil {
            if playerStatus == VedioStatus.finished {
                play()
                //埋点：点击播放音频
                let info = ["Scope" : self.Scope,"Lessonid" : self.Lessonid,"Subscope" : self.Subscope,"IndexPath" : self.IndexPath,"Event" : "Audio"]
                UserManager.shared.logUserClickInfo(info)
            } else {
                pause()
            }
        } else {
            initPlayer()
            play()
        }
    }
    
    //暂停
    func pause() {
        //VedioStatusPause,       // 暂停播放
        self.progressLayer?.strokeEnd = 0
        playerItem?.seek(to: CMTime.zero)
        progress = 0
        playOrPauseButton.isSelected = false
        if (player != nil) && playerStatus != VedioStatus.finished {
            playerStatus = VedioStatus.finished
            player?.pause()
        }
    }
    
    //播放完成
    @objc func playerFinished(_ notification: Notification?) {
        playOrPauseButton.isSelected = false
        playerFinishedBlock?()
        pause()
    }
//创建进度圈
    func createRingLayer(withCenter center: CGPoint, radius: CGFloat, lineWidth: CGFloat, color: UIColor?) -> CAShapeLayer {
        let smoothedPath = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius, startAngle: -CGFloat(Double.pi/2), endAngle: CGFloat(Double.pi + Double.pi/2), clockwise: true)
        let slice = CAShapeLayer()
        slice.contentsScale = UIScreen.main.scale
        slice.frame = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        slice.fillColor = UIColor.clear.cgColor
        slice.strokeColor = color?.cgColor
        slice.lineWidth = lineWidth
        slice.lineCap = CAShapeLayerLineCap.round
        slice.lineJoin = CAShapeLayerLineJoin.bevel
        slice.path = smoothedPath.cgPath
        return slice
    }
    
    //设置播放进度
    func makeProgress(_ progress: Float) {
        if showProgress == false {
            return
        }
        if progress <= 0.0 {
            self.progressLayer?.strokeEnd = 0
        } else {
            if !progress.isNaN {
              self.progressLayer?.strokeEnd = CGFloat(progress)
            }
        }
    }

    //协议方法
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            //restore progress value
            progress = 0
            delegate?.playerDidFinishPlaying()
        }
    }
    
    //calculate angle between start to point
    func angleFromStart(to point: CGPoint) -> CGFloat {
        var angle = angleBetweenLines(withLine1Start: CGPoint(x: bounds.width / 2, y: bounds.height / 2), line1End: CGPoint(x: bounds.width / 2, y: bounds.height / 2 - 1), line2Start: CGPoint(x: bounds.width / 2, y: bounds.height / 2), line2End: point)
        if CGRect(x: 0, y: 0, width: frame.width / 2, height: frame.height).contains(point) {
            angle = 2 * .pi - angle
        }
        return angle
    }
    
    
    func angleBetweenLines(withLine1Start line1Start: CGPoint, line1End: CGPoint, line2Start: CGPoint, line2End: CGPoint) -> CGFloat {
        let a: CGFloat = line1End.x - line1Start.x
        let b: CGFloat = line1End.y - line1Start.y
        let c: CGFloat = line2End.x - line2Start.x
        let d: CGFloat = line2End.y - line2Start.y
        
        return  acos(((a * c) + (b * d)) / ((sqrt(a * a + b * b)) * (sqrt(c * c + d * d))))
    }
    
    
    // MARK: 初始化基础UI
    func initUI() {
        showProgress = true
        player = AVPlayer()
        
        playerStatus = VedioStatus.finished
        let backgroundLayer = createRingLayer(withCenter: CGPoint(x: frame.width / 2, y: frame.height / 2), radius: bounds.width / 2 - lineWidth / 2, lineWidth: lineWidth, color: backColor)
        layer.addSublayer(backgroundLayer)
        
        progressLayer = createRingLayer(withCenter: CGPoint(x: frame.width / 2, y: frame.height / 2), radius: bounds.width / 2 - lineWidth / 2, lineWidth: lineWidth, color: progressColor)
        
        progressLayer.strokeEnd = 0
        
        layer.addSublayer(progressLayer)
    }
    
    // MARK: 初始化播放文件，只允许在播放按钮事件使用
    func initPlayer() {
        initPlayerItem()
    }
    
    func initPlayerItem() {
        
        if audioUrl == nil{
            return
        }
        if (self.playerItem != nil) {
            self.playerItem?.removeObserver(self, forKeyPath: "status")
        }
        var playerItem: AVPlayerItem? = nil

        if let anUrl = URL(string: audioUrl!) {
            playerItem = AVPlayerItem(url: anUrl)
        }
        self.playerItem = playerItem
        player.replaceCurrentItem(with: self.playerItem)

        //播放状态监听
        self.playerItem?.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
        //缓冲进度监听
//        self.playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new, .old], context: nil)
    }
    
    
    // MARK: 播放速度、播放状态、播放进度、后台等用户操作、横竖屏监听
    func addPlayerListener() {
        if (player != nil) {
            //播放速度监听
            player.addObserver(self, forKeyPath: "rate", options: [.new, .old], context: nil)
            //播放中监听，更新播放进度
            weak var weakself = self
            timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 30), queue: DispatchQueue.main, using: { time in
                var currentPlayTime = Double((weakself?.playerItem?.currentTime().value)!) / Double((weakself?.playerItem?.currentTime().timescale)!)
                if (weakself?.playerItem?.currentTime().value ?? 0) < 0 {
                    currentPlayTime = 0.001
                    //防止出现时间计算越界问题
                }
//                print("播放进度\(Float(currentPlayTime) / Float(self.totalTime))")
                
                weakself?.makeProgress(Float(currentPlayTime) / Float(self.totalTime))
            })
        }
    }

    //观察
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        let new = change?[NSKeyValueChangeKey.newKey]
//        let old = change?[NSKeyValueChangeKey.oldKey]
        
        if (keyPath == "status") {
            //播放状态
//            if new == old {
//                return
//            }
            let item = object as? AVPlayerItem
            if playerItem?.status == .readyToPlay {
                //获取音频总长度
                let duration: CMTime? = item?.duration
                self.makeMaxDuratuin(CGFloat(CMTimeGetSeconds(duration!)))
            } else if playerItem?.status == .failed {
                //播放异常
                playerFailed()
            } else if playerItem?.status == .unknown {
                //未知原因停止
                pause()
            }
        }else if (keyPath == "loadedTimeRanges") {
            //缓冲进度
//            let array = (object as? AVPlayerItem)?.loadedTimeRanges
//            let timeRange: CMTimeRange? = array?.first?.timeRangeValue
//            var totalBuffer: TimeInterval = CMTimeGetSeconds((timeRange?.start)!) + CMTimeGetSeconds((timeRange?.duration)!)
//            当缓存到位后开启播放，取消loading
//            if totalBuffer >= totalTime && playerStatus != VedioStatus.finished {
//
//            }
        } else if (keyPath == "rate") {
//            //播放速度
//            if new == old {
//                return
//            }
            let item = object as? AVPlayer
            if item?.rate == 0 && playerStatus != VedioStatus.finished {
                playerStatus = VedioStatus.buffering
            } else if item?.rate == 1 {
                playerStatus = VedioStatus.playing
            }
        }
    }
    
    // MARK: 设置时间轴最大时间
    func makeMaxDuratuin(_ duration: CGFloat) {
        totalTime = duration
    }

    // MARK: 销毁
    deinit {
        //remove监听 销毁播放对象
        destroyPlayer()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: 销毁播放item
    func destoryPlayerItem() {
        pause()
        if (playerItem != nil) {
            playerItem?.removeObserver(self, forKeyPath: "status")
            player?.replaceCurrentItem(with: nil)
        }
        playerStatus = VedioStatus.finished
    }

    func destroyPlayer() {
        destoryPlayerItem()
    }

    // MARK: 播放, 暂停, 停止
    func play() {
        showProgress = true
        if audioUrl == nil || self.audioUrl == "" {
            playerFinishedBlock?()
            return
        }
        playerStarted?()
        if (player != nil) {
            playOrPauseButton.isSelected = true
            playerStatus = VedioStatus.buffering
            player?.play()
        }
    }
    //播放，但不改变图片
    func playNotChangeAudioImage(_ audioUrl: String?) {
        showProgress = false
        self.audioUrl = audioUrl
        if self.audioUrl == nil || self.audioUrl == "" {
            return
        }
        if (player != nil) && playerStatus == VedioStatus.finished {
            playerStatus = VedioStatus.buffering
            player?.play()
        }
    }
//停止
    func stop() {
        self.progressLayer?.strokeEnd = 0
        playerItem?.seek(to: CMTime.zero)
        progress = 0
        playOrPauseButton.isSelected = false
        if (player != nil) && playerStatus != VedioStatus.finished {
            playerStatus = VedioStatus.finished
            player?.pause()
        }
    }

    // MARK: 播放
    func playerFailed() {
        self.progressLayer?.strokeEnd = 0
        playOrPauseButton.isSelected = false
        pause()
        playerFinishedBlock?()
    }


    }

