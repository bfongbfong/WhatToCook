//
//  AutocompleteSearchTableViewCell.swift
//  WhatToEat
//
//  Created by Brandon Fong on 7/21/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

class AutocompleteSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredientImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(with searchedIngredient: SearchedIngredient) {
        print("Autocomplete Search Cell gets updated here")
        titleLabel.text = searchedIngredient.name
        
        let url = URL(string: "https://spoonacular.com/cdn/ingredients_100x100/\(searchedIngredient.imageName)")!
        NetworkRequests.downloadImage(from: url) { (data) in
            DispatchQueue.main.async() {
                self.ingredientImage.image = UIImage(data: data)
            }
        }
    }
}
