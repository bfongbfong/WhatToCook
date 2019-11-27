//
//  Recipe.swift
//  WhatToEat
//
//  Created by Brandon Fong on 7/16/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import Foundation
import Unirest

class Recipe: Equatable {
    
    var title: String?
    var id: Int?
    var imageName: String?
    var missedIngredientCount: Int?
    var missedIngredients: [Ingredient] = []
    var unusedIngredients: [Ingredient] = []
    var unusedIngredientCount: Int?
    var usedIngredientCount: Int?
    var usedIngredients: [Ingredient] = []
    
    // properties to be used at recipe detail
    var url: URL?
    var summary: String?
    var ingredients: [Ingredient] = []
    var instructions: [[String]] = [[]]
    var source: String?
    var readyInMinutes: Int?
    var servings: Int?
    var diets: [String]?
    var creditsText: String?
    var bookmarked: Bool = false {
        didSet {
//            print("bookmarked did set called")
            if bookmarked == true {
//                print("bookmarked was true")
                // this next part is to prevent copies of the recipe to be saved
                // if bookmarkedRecipeIDs is empty, append.
                if bookmarkedRecipeIDs.count == 0 {
                    bookmarkedRecipeIDs.append(self.id!)
                } else {
                    if !bookmarkedRecipeIDs.contains(self.id!) {
                        bookmarkedRecipeIDs.append(self.id!)
                    }
                }
            } else {
//                print("bookmarked was set to false")
                // removes bookmarked recipe from bookmarkedRecipeIDs
                let arrayWithoutTargetRecipe = bookmarkedRecipeIDs.filter { $0 != self.id }
                bookmarkedRecipeIDs = arrayWithoutTargetRecipe
            }
            
//            for recipeID in bookmarkedRecipeIDs {
//                print(recipeID)
//            }
        }
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
}


extension Sequence where Iterator.Element == Int {
    func contains(number: Int) -> Bool {
        var set: Set<Int> = []
        for element in self {
            set.insert(element)
        }
        return set.contains(number)
    }
}




//var bookmarkedRecipes: [Recipe] = []
//{
//    didSet {
//        bookmarkedRecipeIDs = bookmarkedRecipes.map({ (recipe) -> Int in
//            return recipe.id!
//        })
//    }
//}

// make bookmarkedRecipeIDs a computed property or make a didSet on bookmarkedRecipes?
var bookmarkedRecipeIDs: [Int] = []
//{
//    get {
//        return bookmarkedRecipes.map({ (recipe) -> Int in
//            return recipe.id!
//        })
//    }
//}


func loadBookmarkedRecipes() {
    guard let retrievedData = UserDefaults.standard.array(forKey: "BookmarkedRecipeIDs") else { return }

    bookmarkedRecipeIDs.removeAll()

    bookmarkedRecipeIDs = retrievedData as! [Int]
    print("RETRIEVED BOOKMARKED RECIPE IDS: \(bookmarkedRecipeIDs)")
}

func saveBookmarkedRecipes() {
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


