//
//  Ingredient.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

class Ingredient {
    var aisle: String?
    var amount: NSNumber?
    var id: Int?
    var imageName: String?
    var name: String?
    var unit: String?
    var unitShort: String?
    
    init() {
        
    }
    
    init(aisle: String, amount: NSNumber, id: Int, imageName: String, name: String, unit: String, unitShort: String) {
        self.aisle = aisle
        self.amount = amount
        self.id = id
        self.imageName = imageName
        self.name = name
        self.unit = unit
        self.unitShort = unitShort
    }
    
    init(aisle: String?, amount: NSNumber?, id: Int?, imageName: String?, name: String?, unit: String?, unitShort: String?) {
        self.aisle = aisle
        self.amount = amount
        self.id = id
        self.imageName = imageName
        self.name = name
        self.unit = unit
        self.unitShort = unitShort
    }
    
    init(name: String, amount: NSNumber, id: Int, imageName: String, unitShort: String) {
        self.name = name
        self.amount = amount
        self.id = id
        self.imageName = imageName
        self.unitShort = unitShort
        self.aisle = ""
    }
}
