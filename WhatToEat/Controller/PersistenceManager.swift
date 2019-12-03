//
//  PersistenceManager.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

class PersistenceManager {

    static var bookmarkedRecipeIDs: [Int] = []
    
    static func loadBookmarkedRecipes() {
        guard let retrievedData = UserDefaults.standard.array(forKey: "BookmarkedRecipeIDs") else { return }

        bookmarkedRecipeIDs.removeAll()

        bookmarkedRecipeIDs = retrievedData as! [Int]
        print("RETRIEVED BOOKMARKED RECIPE IDS: \(bookmarkedRecipeIDs)")
    }

    static func saveBookmarkedRecipes() {
        UserDefaults.standard.set(bookmarkedRecipeIDs, forKey: "BookmarkedRecipeIDs")
        print("BOOKMARKED IDS SAVED")
    }

}


