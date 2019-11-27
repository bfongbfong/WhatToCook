//
//  SavedIngredientViewController.swift
//  WhatToEat
//
//  Created by Brandon Fong on 8/7/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

class SavedIngredientViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var savedIngredients: [SearchedIngredient] = []

    @IBOutlet weak var savedIngredientTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        savedIngredientTableView.delegate = self
        savedIngredientTableView.dataSource = self
        navigationController?.delegate = self
        
        savedIngredientTableView.allowsMultipleSelectionDuringEditing = true
        
        //toolbar setup
        // when i change the toolbar to hidden or not, it affects what it says teh y position is. when its hidden is 896, which is the same as the view's height. when it's not hidden its 681
        self.navigationController?.setToolbarHidden(false, animated: false)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let deleteButton: UIBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(didPressDelete))
        let clearAllButton = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAll))
        deleteButton.image = UIImage(named: "garbage")
        clearAllButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Gotham", size: 17)!, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        self.toolbarItems = [clearAllButton, flexible, deleteButton]
        
//        self.tabBarController?.setToolbarItems(toolbarItems, animated: true)
//        self.tabBarController?.toolbarItems = [clearAllButton, flexible, deleteButton]
        
        
        self.navigationController?.toolbar.barTintColor = UIColor.mySalmon
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        let window = UIApplication.shared.keyWindow
//        let topPadding = window?.safeAreaInsets.top
//        let bottomPadding = window?.safeAreaInsets.bottom
//
//        let toolBarBeginningPosition = navigationController?.toolbar.frame.origin.y
//        print("toolbar y position: ", toolBarBeginningPosition)
////        print("bottomPadding: ", bottomPadding)
//        print("view height: ", self.view.frame.height)
//
////        print("tab bar max y:", tabBarController?.accessibilityFrame.maxY)
//        let tabBarHeight = tabBarController?.accessibilityFrame.height
//        print("tabbar accessibility frame height: ", tabBarHeight!)
//
//        let topOfTabBar = view.frame.height - tabBarHeight!
//        print("topOfTabBar:", topOfTabBar)
//
//        let bottomOfTableView = savedIngredientTableView.frame.minY + savedIngredientTableView.frame.height
//        print("bottomOfTableView = savedIngredientTableView.frame.minY: \(savedIngredientTableView.frame.minY) + savedIngredientTableView.frame.height: \(savedIngredientTableView.frame.height)")
//        print("bottomOfTableView: ", bottomOfTableView)
//
//        let amountToTransformVertically = topOfTabBar - toolBarBeginningPosition!
        

        
//        UIView.animate(withDuration: 0.01) {
//            self.navigationController?.toolbar?.transform = CGAffineTransform(translationX: 0, y: amountToTransformVertically - self.navigationController!.toolbar.frame.height)
//        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedIngredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = savedIngredientTableView.dequeueReusableCell(withIdentifier: "SavedIngredientCell") as! SavedIngredientTableViewCell
        cell.updateCell(with: savedIngredients[indexPath.row])
        cell.selectionStyle = .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedIngredients.remove(at: indexPath.row)
            savedIngredientTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @objc func didPressDelete() {
        var selectedRows = self.savedIngredientTableView.indexPathsForSelectedRows
        // they need to be sorted in reverse order
        selectedRows = selectedRows?.sorted(by: >)
        if selectedRows != nil {
            for selectionIndex in selectedRows! {
                tableView(savedIngredientTableView, commit: .delete, forRowAt: selectionIndex)
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Toggles the actual editing actions appearing on a table view
        savedIngredientTableView.setEditing(editing, animated: true)
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {

        self.savedIngredientTableView.isEditing = !self.savedIngredientTableView.isEditing

        if savedIngredientTableView.isEditing {
            enableEditing()
        } else {
            disableEditing()
        }
    }
    
    func disableEditing() {
        self.navigationController?.setToolbarHidden(true, animated: true)
        editButton.title = nil
        editButton.image = UIImage(named: "edit")
    }
    
    func enableEditing() {
        self.navigationController?.setToolbarHidden(false, animated: true)
        editButton.image = nil
        editButton.title = "Done"
        editButton.setTitleTextAttributes([
        NSAttributedString.Key.font: UIFont(name: "Gotham", size: 17)!], for: .normal)
    }
    
    
    @objc func clearAll() {
        savedIngredients.removeAll()
        savedIngredientTableView.reloadData()
        edit(editButton)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

// update saved items in view controller
extension SavedIngredientViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        disableEditing()
        if let homeViewController = (viewController as? HomeViewController) {
            homeViewController.savedIngredients = savedIngredients

            homeViewController.updateUI()
        }
        print("SEGUE IS GOING BACKWARDS FROM SAVED INGREDIENTS TO VIEW CONTROLLER")
        // Here you pass the to your original view controller
    }
}
