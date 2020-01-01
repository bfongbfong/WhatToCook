//
//  Helpers.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

class Helpers {
    static func replaceSpecialCharacters(input: String) -> String {
        var returnString = input.replacingOccurrences(of: " ", with: "+")
        returnString = returnString.replacingOccurrences(of: "‘", with: "\'")
        returnString = returnString.replacingOccurrences(of: "’", with: "\'")
        // this stuff isn't working below... above is working though
        returnString = returnString.replacingOccurrences(of: "“", with: "\"")
        returnString = returnString.replacingOccurrences(of: "”", with: "\"")
        returnString = returnString.replacingOccurrences(of: "\"", with: "")
        returnString = returnString.replacingOccurrences(of: "\\", with: "")

    // *********** STUCK ON WHY THE API REQUEST FAILS IF YOU TYPE A DOUBLE QUOTE

    //    returnString = returnString.replacingOccurrences(of: "'", with: "")

        returnString = returnString.replacingOccurrences(of: "\"", with: "\"")
    //    returnString = returnString.typographized(language: "en")
        return returnString
    }
}

class RecipesViewed {
    static var counter: Int = 2
    static var isMultipleOfThree: Bool {
        get {
            return counter % 3 == 0
        }
    }
}

class TestMode {
    static var testMode = false
}


