//
//  UINavigationItem+Extensions.swift
//  WhatToEat
//
//  Created by Brandon Fong on 12/6/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

extension UINavigationItem {

    override open func awakeFromNib() {
        super.awakeFromNib()
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.backBarButtonItem = backItem
    }
}
