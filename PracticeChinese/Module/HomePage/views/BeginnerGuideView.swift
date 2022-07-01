//
//  BeginnerGuideView.swift
//  PracticeChinese
//
//  Created by ThomasXu on 20/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation

protocol BeginnerGuideCloseDelegate: class {
    func closeBeginnerGuide()
}

class BeginnerGuideView: UIView {
    
    var birdImage: UIImageView!
    var noticeLabel: UILabel!
    
    static var birdWidth: CGFloat = 80
    static var birdHeight: CGFloat = 60
    static var noticeFont = FontUtil.getFont(size: 16, type: .Regular)
    
    weak var delegate: BeginnerGuideCloseDelegate!
    
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, birdPoint: CGPoint, noticeText: String, noticeFrame: CGRect) {
        self.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.isUserInteractionEnabled = true
        
        self.birdImage = UIImageView(frame: CGRect(x: birdPoint.x, y: birdPoint.y, width: BeginnerGuideView.birdWidth, height: BeginnerGuideView.birdHeight))
        self.birdImage.image = ChBundleImageUtil.beginnerGuideBird.image
        self.addSubview(birdImage)
        
        let noticeX = noticeFrame.minX
        let noticeY = noticeFrame.minY
        let font = BeginnerGuideView.noticeFont
        let noticeHeight = noticeText.height(withConstrainedWidth: noticeFrame.width, font: font)
        let noticeLabel = UILabel(frame: CGRect(x: noticeX, y: noticeY, width: noticeFrame.width, height: noticeHeight))
        noticeLabel.text = noticeText
        noticeLabel.textAlignment = .center
        noticeLabel.font = font
        noticeLabel.textColor = UIColor.white
        noticeLabel.lineBreakMode = .byWordWrapping
        noticeLabel.numberOfLines = 0
        self.addSubview(noticeLabel)
    
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(gesture)
        
      //  setTranspartHole(frame: CGRect(x: 0, y: 0, width: 100, height: 100), cornerRadius: 100)
      //  createHold2()
    }
    
    convenience init(frame: CGRect, birdPoint: CGPoint, noticeText: String, noticeFrame: CGRect, showFrame: CGRect, showRadius: CGFloat) {
        self.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.isUserInteractionEnabled = true
        
        self.birdImage = UIImageView(frame: CGRect(x: birdPoint.x, y: birdPoint.y, width: BeginnerGuideView.birdWidth, height: BeginnerGuideView.birdHeight))
        self.birdImage.image = ChBundleImageUtil.beginnerGuideBird.image
        self.addSubview(birdImage)
        
        let noticeX = noticeFrame.minX
        let noticeY = noticeFrame.minY
        let font = FontUtil.getFont(size: 16, type: .Regular)
        let noticeHeight = noticeText.height(withConstrainedWidth: noticeFrame.width, font: font)
        let noticeLabel = UILabel(frame: CGRect(x: noticeX, y: noticeY, width: noticeFrame.width, height: noticeHeight))
        noticeLabel.text = noticeText
        noticeLabel.textAlignment = .center
        noticeLabel.font = font
        noticeLabel.textColor = UIColor.white
        noticeLabel.lineBreakMode = .byWordWrapping
        noticeLabel.numberOfLines = 0
        self.addSubview(noticeLabel)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        self.addGestureRecognizer(gesture)
        
        //  setTranspartHole(frame: CGRect(x: 0, y: 0, width: 100, height: 100), cornerRadius: 100)
        createTransparentHole(frame: showFrame, radius: showRadius)
    }
    
    func createTransparentHole(frame: CGRect, radius: CGFloat) {
        //  self.alpha = 1
        //  self.backgroundColor = UIColor.black
        
        // Create a path with the rectangle in it.
        let path = CGMutablePath()
     //   let circlePath = UIBezierPath(roundedRect: frame, cornerRadius: radius)
    //    path.append(circlePath)
        path.addRoundedRect(in: frame, cornerWidth: radius, cornerHeight: radius)
//        path.addRect(frame)
  //      path.addrect
     //   path.addArc(center: CGPoint(x: frame.minX, y: frame.minY), radius: radius, startAngle: 0.0, endAngle: 2 * 3.14, clockwise: false)
        path.addRect(self.frame)
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path;
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        // Release the path since it's not covered by ARC.
        self.layer.mask = maskLayer
        self.clipsToBounds = true
    }

    
    func setTranspartHole(frame: CGRect, cornerRadius: CGFloat) {
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height), cornerRadius: 0)
        let circlePath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 100, height: 100), cornerRadius: 0)
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor.red.cgColor//.background.cgColor
        fillLayer.opacity = 0.5
        self.layer.addSublayer(fillLayer)
    }
    
    @objc func viewTapped() {
        self.removeFromSuperview()
        self.delegate?.closeBeginnerGuide()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func closeTapped(sender: AnyObject) {
        self.delegate.closeBeginnerGuide()
        self.removeFromSuperview()
    }
    
    static func getNestedImg(frame: CGRect, dis: CGFloat) -> (outImg: UIImageView, innerImg: UIImageView) {
        let outFrame = frame.inset(by: UIEdgeInsets.init(top: dis, left: dis, bottom: dis, right: dis))
        let outImg = UIImageView(frame: outFrame)
        outImg.layer.cornerRadius = outFrame.width / 2
        outImg.layer.masksToBounds = true
        let innerImg = UIImageView(frame: frame)
        innerImg.layer.cornerRadius = frame.width / 2
        innerImg.layer.masksToBounds = true
        return (outImg, innerImg)
    }
}
