//
//  Array<Int>+Extension.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element == Int {
    func contains(number: Int) -> Bool {
        var set: Set<Int> = []
        for element in self {
            set.insert(element)
        }
        return set.contains(number)
    }
}
