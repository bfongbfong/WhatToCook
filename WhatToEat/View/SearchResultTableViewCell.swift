//
//  SearchResultTableViewCell.swift
//  WhatToEat
//
//  Created by Brandon Fong on 7/17/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var bookmarkStarButton: UIButton!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bookmarkStarButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func smallBookmarkStarPressed(_ sender: UIButton) {
        
//        bookmarkStarButton.isHidden = true
        // have to access the cell that is inside the one that i clicked.
        // so that i can set that recipe to unbookmarked.
        
    }
    
    func handleBookmark(recipe: Recipe) {
        
//        if checkIfBookmarkedThroughGlobalArray(recipe: recipe) {
//            recipe.bookmarked = true
//            bookmarkStarButton.isHidden = false
//        } else {
//            recipe.bookmarked = false
//            bookmarkStarButton.isHidden = true
//        }
        
        if PersistenceManager.bookmarkedRecipeIDs.contains(recipe.id!) {
            recipe.bookmarked = true
            bookmarkStarButton.isHidden = false
        } else {
            recipe.bookmarked = false
            bookmarkStarButton.isHidden = true
        }
    }
    
    

//    func checkIfBookmarkedThroughGlobalArray(recipe: Recipe) -> Bool {
//        for recipeID in PersistenceManager.bookmarkedRecipeIDs {
//            if recipe.id == recipeID {
//                return true
//            }
//        }
//        return false
//    }
    
    func updateCellWithUsedIngredients(with recipe: Recipe) {
        handleBookmark(recipe: recipe)
        titleLabel.text = recipe.title

        if recipe.usedIngredients.count == 0 {
            ingredientsLabel.text = "No used ingredients"
        } else {
            var usedIngredientsString = ""
            
            for (index, usedIngredient) in recipe.usedIngredients.enumerated() {
                if index != 0 {
                    usedIngredientsString += ", "
                }
                if let unwrappedName = usedIngredient.name {
                    usedIngredientsString += unwrappedName
                }
            }
            ingredientsLabel.text = "Used Ingredients: \(usedIngredientsString)"
        }
        imageLabel.image = recipe.image
    }
    
    func updateCell(with recipe: Recipe) {
        handleBookmark(recipe: recipe)
        titleLabel.text = recipe.title
        self.imageLabel.image = recipe.image

        var ingredientsString = ""
        
        for (index, ingredient) in recipe.ingredients.enumerated() {
            if index != 0 {
                ingredientsString += ", "
            }
            if let unwrappedName = ingredient.name {
                ingredientsString += unwrappedName
            }
        }
        ingredientsLabel.text = "Ingredients: \(ingredientsString)"
        ingredientsLabel.lineBreakMode = .byTruncatingTail
    }
}



