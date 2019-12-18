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
    
    func playLoadingAnimation(loadingView: inout UIView, activityIndicatorView: UIActivityIndicatorView, onView: UIView) {
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: onView.frame.width, height: onView.frame.height))
        loadingView.backgroundColor = .white
        onView.addSubview(loadingView)
        onView.bringSubviewToFront(loadingView)
        
        activityIndicatorView.style = .gray
        loadingView.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0))
        
        activityIndicatorView.startAnimating()
    }
    
    func stopLoadingAnimation(loadingView: inout UIView, activityIndicatorView: UIActivityIndicatorView) {
        loadingView.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
}
