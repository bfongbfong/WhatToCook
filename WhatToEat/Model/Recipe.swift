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
                
                // A FOR IN LOOP DOESN'T GET CALLED IF THE ARRAY IS EMPTY DUMMYYY
                if bookmarkedRecipeIDs.count == 0 {
                    bookmarkedRecipeIDs.append(self.id!)
                } else {
                    // there error is that you are looping through everything in bookmarkedRecipeIDs and comparing every item to the newest item. if the item isn't the same, then you are adding it. but what if you're comparing something that has a match SOMEHERE in the array... you still add it to the array!
                    // that's not right.
                    // it should be: compare every value in your array with your target value. if you finish the entire array and it doesn't find a match, then append it. if not, return.
//                    for bookmarkedRecipeID in bookmarkedRecipeIDs {
//                        if bookmarkedRecipeID == self.id {
//                            return
//                        } else {
//                            bookmarkedRecipeIDs.append(self.id!)
//                        }
//                    }
                    
                    if !loopThrough(id: self.id!) {
                        bookmarkedRecipeIDs.append(self.id!)
                    }
                }
                
                

            } else {
//                print("bookmarked was set to false")
                let arrayWithoutTargetRecipe = bookmarkedRecipeIDs.filter {$0 != self.id}
                bookmarkedRecipeIDs = arrayWithoutTargetRecipe
            }
            
            // print bookmarked recipes
//            let bookmarkedRecipesToPrint = bookmarkedRecipeIDs.map { (recipe) -> Int in
//                return recipe.id!
//            }
//            print(bookmarkedRecipesToPrint)
            

            for recipeID in bookmarkedRecipeIDs {
                print(recipeID)
            }
        }
    }
    // this was an idea i had to help keep local recipe arrays to be the same as bookmarkedRecipeIds but im not sure it's a good idea anymore
    var orderInArray: Int?
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
}

private func loopThrough(id: Int) -> Bool {
    
    for bookmarkedRecipeID in bookmarkedRecipeIDs {
        if bookmarkedRecipeID == id {
            return true
        }
    }
    return false
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

class RecipesViewed {
    static var counter: Int = 0
    static var notMultipleOfThree: Bool {
        get {
            return counter % 3 == 0
        }
    }
}

class adIDs {
    static var searchResultsVCBannerID: String {
        return "ca-app-pub-5775764210542302/4339264751"
    }
    static var recipeDetailVCBannerID: String {
        return "ca-app-pub-5775764210542302/9192273207"
    }
    static var searchByRecipeNameVCBannerID: String {
        return "ca-app-pub-5775764210542302/7631779527"
    }
    static var savedRecipesVCBannerID: String {
        return "ca-app-pub-5775764210542302/6262518225"
    }
    static var beforeInterstitialID: String {
        return "ca-app-pub-5775764210542302/6785262409"
    }
}
