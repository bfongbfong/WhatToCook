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
        self.navigationController?.setToolbarHidden(true, animated: false)
        let flexible = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let deleteButton: UIBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(didPressDelete))
        deleteButton.image = UIImage(named: "garbage")
        self.toolbarItems = [flexible, deleteButton]
        self.navigationController?.toolbar.barTintColor = mySalmon
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
            self.navigationController?.setToolbarHidden(false, animated: true)
            editButton.image = nil
            editButton.title = "Done"
            
        } else {
            self.navigationController?.setToolbarHidden(true, animated: true)
            editButton.title = nil
            editButton.image = UIImage(named: "edit")
        }
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
        if let homeViewController = (viewController as? ViewController) {
            homeViewController.savedIngredients = savedIngredients

            // added this line to the do the actual label setting from this vc
            homeViewController.fridgeBarButtonItem.badgeNumber = savedIngredients.count
            if homeViewController.fridgeBarButtonItem.badgeNumber == 0 {
                homeViewController.greenCircleForSearchButton.backgroundColor = UIColor.gray
                homeViewController.tapSearchButton.isEnabled = false
            } else {
                homeViewController.greenCircleForSearchButton.backgroundColor = mySalmon
                homeViewController.tapSearchButton.isEnabled = true
            }
        }
        print("SEGUE IS GOING BACKWARDS FROM SAVED INGREDIENTS TO VIEW CONTROLLER")
        // Here you pass the to your original view controller
    }
}
