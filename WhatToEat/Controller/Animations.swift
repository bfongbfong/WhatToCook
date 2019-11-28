//
//  Animations.swift
//  WhatToEat
//
//  Created by Brandon Fong on 11/27/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

class Animations {
    
    // tried to modularize the jump to cart animation, but it was too specific to the VC
    
//    // MARK: - Animations
//    static func addIngredientAnimation(mainView: UIView, navigationController: UINavigationController, tableView: UITableView, indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! AutocompleteSearchTableViewCell
//
//        let imageViewPosition : CGPoint = cell.ingredientImage.convert(cell.ingredientImage.bounds.origin, to: mainView)
//
//        let imgViewTemp = UIImageView(frame: CGRect(x: imageViewPosition.x, y: imageViewPosition.y, width: cell.ingredientImage.frame.size.width, height: cell.ingredientImage.frame.size.height))
//
//        imgViewTemp.image = cell.ingredientImage.image
//
//        jumpToCartAnimation(mainView: mainView, navigationController: navigationController, tempView: imgViewTemp) {
//
//        }
//    }
//
//    // second part of jump to cart
//    static func jumpToCartAnimation(mainView: UIView, navigationController: UINavigationController, tempView: UIView, completion: () -> Void)  {
//        mainView.addSubview(tempView)
//
//        UIView.animate(withDuration: 0.5, animations: {
//
//            tempView.animationZoom(scaleX: 0.2, y: 0.2)
//            tempView.animationRoted(angle: CGFloat(Double.pi))
//
//            tempView.frame.origin.x = navigationController.navigationBar.center.x + 5
//            tempView.frame.origin.y = navigationController.navigationBar.center.y
//
//        }, completion: { _ in
//
//            completion()
////            tempView.removeFromSuperview()
////            self.updateUI()
//        })
//    }
}
