//
//  RecipeDetailView.swift
//  WhatToEat
//
//  Created by Brandon Fong on 8/8/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

class RecipeDetailView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var readyInMinutesLabel: UILabel!
    @IBOutlet weak var servingsLabel: UILabel!
    @IBOutlet weak var sourceButton: UIButton!
    @IBOutlet weak var dietsCollectionView: UICollectionView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var instructionsTableView: UITableView!
    @IBOutlet weak var bookmarkButton: UIButton!
    
    
    // constraints
    @IBOutlet weak var aboveRecipeTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var belowTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeAndServingsStackView: UIStackView!
    @IBOutlet weak var belowTimeAndServingsStackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var belowSourceHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dietCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var belowDietsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var aboveIngredientsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var belowIngredientsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var belowIngredientsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var aboveInstructionsLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var belowInstructionsLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ingredientsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var instructionsTableViewHeightConstraint: NSLayoutConstraint!
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("RecipeDetailView", owner: self, options: nil)
        contentView.fixInView(self)
    }

    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "RecipeDetailView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    override var intrinsicContentSize: CGSize {
        get {
            // add together the vertical pixels of the entire view
            var height: CGFloat = self.recipeTitleLabel.bounds.size.height
            height += self.aboveRecipeTitleHeight.constant
            height += self.belowTitleHeightConstraint.constant
            height += self.timeAndServingsStackView.bounds.size.height
            height += self.belowTimeAndServingsStackHeightConstraint.constant
            height += self.recipeImageView.bounds.size.height
            height += self.sourceButton.bounds.size.height
            height += self.belowSourceHeightConstraint.constant
            height += self.dietsCollectionView.bounds.size.height
            height += self.belowDietsHeightConstraint.constant
            height += self.aboveIngredientsLabelHeightConstraint.constant
            // for green separator line
            height += 1
            height += self.belowIngredientsLabelHeightConstraint.constant
            height += self.ingredientsTableView.bounds.size.height
            height += self.aboveInstructionsLabelHeightConstraint.constant
            height += 1
            height += self.belowInstructionsLabelHeightConstraint.constant
            height += self.instructionsTableView.bounds.size.height
            let size = CGSize(width: 414, height: height)
            return size
        }
    }

}

extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
//        self.invalidateIntrinsicContentSize()
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
//        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
