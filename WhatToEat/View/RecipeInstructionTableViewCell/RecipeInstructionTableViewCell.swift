//
//  RecipeInstructionTableViewCell.swift
//  WhatToEat
//
//  Created by Brandon Fong on 8/20/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

class RecipeInstructionTableViewCell: UITableViewCell {

    @IBOutlet weak var greenCircle: UIView!
    @IBOutlet weak var instructionNumberLabel: UILabel!
    @IBOutlet weak var recipeInstructionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        greenCircle.layer.cornerRadius = greenCircle.frame.size.width/2
//        recipeInstructionLabel.
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
