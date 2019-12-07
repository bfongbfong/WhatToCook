//
//  UIDevice+Extensions.swift
//  WhatToEat
//
//  Created by Brandon Fong on 12/6/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit
import AVFoundation

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
