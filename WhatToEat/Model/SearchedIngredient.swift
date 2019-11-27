//
//  SearchedIngredient.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

struct SearchedIngredient: Equatable {

    var name: String
    var imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
    
    static func == (lhs: SearchedIngredient, rhs: SearchedIngredient) -> Bool {
        return lhs.name == rhs.name
    }
}
