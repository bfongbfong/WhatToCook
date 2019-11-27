//
//  PersistenceManager.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation

class PersistenceManager {
    //var bookmarkedRecipes: [Recipe] = []
    //{
    //    didSet {
    //        bookmarkedRecipeIDs = bookmarkedRecipes.map({ (recipe) -> Int in
    //            return recipe.id!
    //        })
    //    }
    //}

    // make bookmarkedRecipeIDs a computed property or make a didSet on bookmarkedRecipes?
    static var bookmarkedRecipeIDs: [Int] = []



    //{
    //    get {
    //        return bookmarkedRecipes.map({ (recipe) -> Int in
    //            return recipe.id!
    //        })
    //    }
    //}


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

    // to persist the fridge. nah ima use coredata for that.

    //func persistSavedIngredient(ingredients: [SearchedIngredient]) {
    //    UserDefaults.standard.set(ingredients, forKey: "savedIngredients")
    //}
    //
    //func loadSavedIngredients() -> [SearchedIngredient] {
    //    (UserDefaults.standard.array(forKey: "savedIngredients") as? [SearchedIngredient])!
    //}

}


