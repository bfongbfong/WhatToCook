//
//  UIView+Extension.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

// for use in add to cart animation
extension UIView {
    func animationZoom(scaleX: CGFloat, y: CGFloat) {
        self.transform = CGAffineTransform(scaleX: scaleX, y: y)
    }
    
    func animationRoted(angle : CGFloat) {
        self.transform = self.transform.rotated(by: angle)
    }
    
    func playLoadingAnimation(loadingView: inout UIView, activityIndicatorView: UIActivityIndicatorView) {
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        loadingView.backgroundColor = .white
        self.addSubview(loadingView)
        self.bringSubviewToFront(loadingView)
        
        activityIndicatorView.style = .gray
        activityIndicatorView.center = CGPoint(x: self.center.x, y: self.center.y)
        activityIndicatorView.startAnimating()
        loadingView.addSubview(activityIndicatorView)
    }
    
    func stopLoadingAnimation(loadingView: inout UIView, activityIndicatorView: UIActivityIndicatorView) {
        loadingView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
}
