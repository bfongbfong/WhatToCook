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
    static var dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("SavedIngredients.plist")
    
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
    
    static func persistSavedIngredients(savedIngredients: [SearchedIngredient]) {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(savedIngredients)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("Saved ingredients couldn't be encoded. Error: \(error)")
        }
    }
    
    static func loadSavedIngredients() -> [SearchedIngredient] {
        var returnArray = [SearchedIngredient]()
        
        guard let data = try? Data(contentsOf: self.dataFilePath!) else { return returnArray }
        
        let decoder = PropertyListDecoder()
        do {
            returnArray = try decoder.decode([SearchedIngredient].self, from: data)
        } catch {
            print("Error: \(error)")
        }
        
        return returnArray
    }

}


