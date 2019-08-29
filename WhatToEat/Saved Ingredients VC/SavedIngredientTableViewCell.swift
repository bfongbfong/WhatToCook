//
//  SavedIngredientTableViewCell.swift
//  WhatToEat
//
//  Created by Brandon Fong on 7/31/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

class SavedIngredientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var savedIngredientImageView: UIImageView!
    @IBOutlet weak var savedIngredientLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        print("CELL SELECTED")
        // Configure the view for the selected state
    }
    
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
//        print("CELL HIGHLIGHTED")
//
//    }
    
    func updateCell(with searchedIngredient: SearchedIngredient) {
        print("Autocomplete Search Cell gets updated here")
        savedIngredientLabel.text = searchedIngredient.name
        
        let url = URL(string: "https://spoonacular.com/cdn/ingredients_100x100/\(searchedIngredient.imageName)")!
        downloadImage(from: url)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.savedIngredientImageView.image = UIImage(data: data)
            }
        }
    }

}
