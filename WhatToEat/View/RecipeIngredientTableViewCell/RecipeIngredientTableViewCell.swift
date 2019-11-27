//
//  RecipeIngredientTableViewCell.swift
//  WhatToEat
//
//  Created by Brandon Fong on 8/20/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

class RecipeIngredientTableViewCell: UITableViewCell {

    @IBOutlet weak var ingredientLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
