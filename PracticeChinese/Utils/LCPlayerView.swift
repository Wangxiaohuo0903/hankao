//
//  LCPlayerView.swift
//  ChineseLearning
//
//  Created by ThomasXu on 22/05/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class LCPlayerView: UIView {
    
    var lcPlayer: LCPlayer!
    var playerLayer: AVPlayerLayer!
    var spinnerView: UIActivityIndicatorView!
    var playButton: UIButton!
    
    var controlPanel: LCPlayerControlPanelView!
    var controlPanelVisible: Bool!
    var controlPanelTimer: Timer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.lcPlayer = LCPlayer(type: .Video)
        self.lcPlayer.delegate = self
        
        playerLayer = AVPlayerLayer(player: self.lcPlayer.player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.layer.addSublayer(playerLayer)
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapPlayerLayer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGestureRecognizer)
        
        let panelHeight = LCPlayerControlPanelView.infoLabelFont.lineHeight
        let panelY = frame.height - panelHeight
        controlPanel = LCPlayerControlPanelView(frame: CGRect(x: 0, y: panelY, width: frame.width, height: panelHeight))
        controlPanel.backgroundColor = UIColor.darkGray
        controlPanel.alpha = 0
        self.controlPanelVisible = false
        self.addSubview(controlPanel)
        
        spinnerView = UIActivityIndicatorView(style: .gray)
        spinnerView.center = self.center
        self.addSubview(spinnerView)
        spinnerView.isHidden = true
        
        
        playButton = UIButton(frame:CGRect(x: ScreenUtils.widthByRate(x: 0.42), y: ScreenUtils.heightByRate(y: 0.165) - ScreenUtils.widthByRate(x: 0.06), width: ScreenUtils.widthByRate(x: 0.12), height: ScreenUtils.widthByRate(x: 0.12)))
        playButton.setImage(ChImageAssets.PlayIcon.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        playButton.addTarget(self, action: #selector(touchPlayButton), for: .touchUpInside)
        playButton.tintColor = UIColor.white
        playButton.isHidden = true
        self.addSubview(playButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pressHome(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterFromHome(nofitication:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func pressHome(notification: NSNotification) {
        self.tapPlayerLayer()
        
    }
    
    @objc func enterFromHome(nofitication: NSNotification) {
    }
    
    @objc func touchPlayButton() {
        self.playButton.isHidden = true
        self.lcPlayer.startPlay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPlayUrl(webUrl: String) {
        self.lcPlayer.setPlayUrl(webUrl: webUrl)
        self.spinnerView.isHidden = false
        self.spinnerView.startAnimating()
        self.controlPanel.initSubviewContent()
    }
    
    @objc func tapPlayerLayer() {
        if nil == self.lcPlayer.playerItem {
            return
        }
        self.lcPlayer.pausePlay()
        self.playButton.isHidden = false
       /* if self.player.playerItem.status == .readyToPlay {
            self.controlPanel.alpha = 1
        //    self.controlPanelTimer = Timer.scheduledTimer(timeInterval: 1.4, target: self, selector: #selector(controlPanelInvisiable), userInfo: nil, repeats: false)
        }*/
    }
    
    func controlPanelInvisiable() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(2.0)
        self.controlPanel.alpha = 0.0
        UIView.commitAnimations()
        self.controlPanelTimer.invalidate()//如果连续点击，这句话好像就不会执行？
    }
    
    
    func secondsToTime(seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let minutes = Int(seconds / 60)
        let seconds = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}

extension LCPlayerView: LCPlayerDelegate {
    
    func periodicUpdateView(time: CMTime) {
        let currentTime = CMTimeGetSeconds(time)
        let currentStr = "\(self.secondsToTime(seconds: currentTime))"
        let totalTime = TimeInterval(self.lcPlayer.playerItem.duration.value) / TimeInterval(self.lcPlayer.playerItem.duration.timescale)
        let totalStr = "\(self.secondsToTime(seconds: totalTime))"
        self.controlPanel.infoLabel.text = currentStr + "/" + totalStr
        
        self.controlPanel.progress.progress = Float(currentTime / totalTime)
    }
    
    func playFinish() {
        self.playButton.isHidden = false
    }
    
    func loadTimeRange() {
     /*   let loadedTime = self.lcPlayer.getCacheProgress()
        let totalTime = CMTimeGetSeconds(self.lcPlayer.playerItem.duration)
        let percent = loadedTime / totalTime
        self.controlPanel.progress.progress = Float(percent) */
    }
    
    func playStart() {
        self.controlPanel.alpha = 1
        self.spinnerView.isHidden = true
        self.playButton.isHidden = false
    }
    
    func errorGetData(error: Error?) {
        UIApplication.topViewController()?.alertUserNetworkError(logMessage: "no video data")
    }
}
