//
//  UIView+pick.swift
//  PracticeChinese
//
//  Created by 费跃 on 9/7/17.
//  Copy right © 2017 msra. All rights reserved.
//

import Foundation

extension UIView {
    func applyNavBarConstraints(size: (width: CGFloat, height: CGFloat)) {
        //adjust size on iOS 9 or later
        if #available(iOS 9.0, *) {
            let widthConstraint = self.widthAnchor.constraint(equalToConstant: size.width)
            let heightConstraint = self.heightAnchor.constraint(equalToConstant: size.height)
            heightConstraint.isActive = true
            widthConstraint.isActive = true
        }
        
    }
}

public extension UIView {
    
    public enum PeakSide: Int {
        case Top
        case Left
        case Right
        case Bottom
    }
    
    public func addPikeOnView( side: PeakSide, size: CGFloat = 10.0) {
        self.layoutIfNeeded()
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2
        let peakLayer = CAShapeLayer()
        var path: CGPath?
        switch side {
        case .Top:
            path = self.makePeakPathWithRect(rect: self.bounds, topSize: size, rightSize: 0.0, bottomSize: 0.0, leftSize: 0.0)
        case .Left:
            path = self.makePeakPathWithRect(rect: self.bounds.insetBy(dx: 1, dy: 1), topSize: 0.0, rightSize: 0.0, bottomSize: 0.0, leftSize: size)
        case .Right:
            path = self.makePeakPathWithRect(rect: self.bounds.insetBy(dx: 1, dy: 1), topSize: 0.0, rightSize: size, bottomSize: 0.0, leftSize: 0.0)
        case .Bottom:
            path = self.makePeakPathWithRect(rect: self.bounds, topSize: 0.0, rightSize: 0.0, bottomSize: size, leftSize: 0.0)
        }
        peakLayer.path = path
        let color = (self.backgroundColor?.cgColor)
        peakLayer.fillColor = color
        peakLayer.strokeColor = color
        peakLayer.lineWidth = 1
        peakLayer.position = CGPoint.zero
        self.layer.insertSublayer(peakLayer, at: 0)
    }
    
    
    func makePeakPathWithRect(rect: CGRect, topSize ts: CGFloat, rightSize rs: CGFloat, bottomSize bs: CGFloat, leftSize ls: CGFloat) -> CGPath {
        //                      P3
        //                    /    \
        //      P1 -------- P2     P4 -------- P5
        //      |                               |
        //      |                               |
        //      P16                            P6
        //     /                                 \
        //  P15                                   P7
        //     \                                 /
        //      P14                            P8
        //      |                               |
        //      |                               |
        //      P13 ------ P12    P10 -------- P9
        //                    \   /
        //                     P11
        
        var h: CGFloat = 0
        let path = CGMutablePath()
        let rad = ScreenUtils.widthBySix(x: 20)
        // P1
        // Points for top side
        self.startPath(path: path, onPoint:  CGPoint(x:rect.origin.x,y: rect.origin.y + rad))
        self.addArc(point1: CGPoint(x:rect.origin.x ,y: rect.origin.y), point2: CGPoint(x:rect.origin.x + rad,y: rect.origin.y), toPath: path)

        self.addPoint(point: CGPoint(x:rect.origin.x + rect.width - rad,y: rect.origin.y), toPath: path)
        self.addArc(point1: CGPoint(x:rect.origin.x + rect.width ,y: rect.origin.y), point2: CGPoint(x:rect.origin.x + rect.width,y: rect.origin.y+rad), toPath: path)
        
        // P5
        // Points for right side
        if rs > 0 {
            h = rs * sqrt(3.0) / 2
            let x = rect.origin.x + rect.width
            let y = rect.origin.y + min(ScreenUtils.widthBySix(x: 40), rect.height / 2)
            self.addPoint(point: CGPoint(x:x,y: y - rs), toPath: path)
            self.addPoint(point: CGPoint(x:x + h,y: y), toPath: path)
            self.addPoint(point: CGPoint(x:x ,y: y+rs), toPath: path)
            
        }
        
        // P9
        self.addPoint(point: CGPoint(x:rect.origin.x + rect.width,y: rect.origin.y + rect.height - rad), toPath: path)
        self.addArc(point1: CGPoint(x:rect.origin.x + rect.width,y: rect.origin.y + rect.height), point2: CGPoint(x:rect.origin.x + rect.width - rad,y: rect.origin.y+rect.height), toPath: path)

        
        // P13
        self.addPoint(point: CGPoint(x:rect.origin.x + rad,y: rect.origin.y + rect.height), toPath: path)
        self.addArc(point1: CGPoint(x:rect.origin.x,y: rect.origin.y + rect.height), point2: CGPoint(x:rect.origin.x,y: rect.origin.y+rect.height - rad), toPath: path)

        // Point for left sidey:
        if ls > 0 {
            h = ls * sqrt(3.0) / 2
            let x = rect.origin.x
            let y = rect.origin.y + min(ScreenUtils.widthBySix(x: 40), rect.height / 2)
            self.addPoint(point: CGPoint(x:x,y: y + ls), toPath: path)
            self.addPoint(point: CGPoint(x:x - h,y: y), toPath: path)
            self.addPoint(point: CGPoint(x:x ,y: y - ls), toPath: path)

        }
        self.addPoint(point: CGPoint(x:rect.origin.x,y: rect.origin.y + rad), toPath: path)

        return path
    }
    
    private func startPath( path: CGMutablePath, onPoint point: CGPoint) {
        path.move(to: CGPoint(x: point.x, y: point.y))
    }
    
    private func addPoint(point: CGPoint, toPath path: CGMutablePath) {
        path.addLine(to: CGPoint(x: point.x, y: point.y))
    }
    
    private func addArc(point1: CGPoint,  point2: CGPoint, toPath path:CGMutablePath) {
        //path.addArc(tangent1End: point1, tangent2End: point2, radius: ScreenUtils.widthBySix(x: 40))
        path.addQuadCurve(to: point2, control: point1)
    }
}

