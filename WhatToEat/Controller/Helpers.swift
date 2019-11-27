//
//  Helpers.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

class RecipesViewed {
    static var counter: Int = 0
    static var notMultipleOfThree: Bool {
        get {
            return counter % 3 == 0
        }
    }
}


