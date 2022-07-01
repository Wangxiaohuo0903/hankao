//
//  UIImageVIew+SVG.swift
//  PracticeChinese
//
//  Created by feiyue on 11/07/2017.
//  Copyright © 2017 msra. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CocoaLumberjack

public class SVGImageView: UIView {
    private let webView = UIWebView()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        webView.frame = self.bounds

        webView.delegate = self
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.contentMode = .scaleToFill
        addSubview(webView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        webView.stopLoading()
    }
    
    public func load(url: URL) {
        webView.stopLoading()
        webView.loadRequest(URLRequest(url: url))
        
    }
    
    public func load(html: String) {
        webView.stopLoading()
        webView.loadHTMLString(html, baseURL: nil)
    }
}

extension SVGImageView: UIWebViewDelegate {
    public func webViewDidFinishLoad(_ webView: UIWebView) {
    }
}


extension UIImageView {

    func sd_setSVGImage(urlString: String?) {
        if urlString == nil {
            return
        }
        if urlString!.lowercased().hasSuffix(".svg") {
            let svgView = SVGImageView(frame:self.bounds)
            let path = CacheManager.shared.getCachedUrl(url:urlString)
            if path != nil {
                
                //svgView.load(url: path!)
                //self.addSubview(svgView)
                let htmlString = "<html><head> <style type = \"text/css\">html{height: 100%;width:100%;padding:0;margin: 0;background-image:url('\(path!.absoluteString)');background-size:cover;background-repeat:no-repeat} </style> </head></html>"
                svgView.load(html:htmlString)
                self.addSubview(svgView)
                return
            }
            else {
                AppUtil.downloadUrls(urls: [urlString]) {
                    flag in
                    if flag {
                        let path = CacheManager.shared.getCachedUrl(url: urlString)
                        let htmlString = "<html><head> <style type = \"text/css\">html{height: 100%;overflow: hidden;-webkit-touch-callout: none;-webkit-user-select: none;padding:0;margin: 0;background-image:url('\(path!.absoluteString)');background-size:cover;background-repeat:no-repeat} </style> </head></html>"
                        svgView.load(html:htmlString)
                        self.addSubview(svgView)
                        return
                    }
                    else {
                        DDLogInfo("download error")
                    }
                }
            }
        }
        else {
            self.sd_setImage(with: URL(string: urlString!))
        }
        
        
    }
}
