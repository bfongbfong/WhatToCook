//
//  SavedIngredientViewController.swift
//  WhatToEat
//
//  Created by Brandon Fong on 8/7/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit

class SavedIngredientViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var savedIngredientTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // MARK: - Properties
    var savedIngredients: [SearchedIngredient] = []

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        savedIngredientTableView.delegate = self
        savedIngredientTableView.dataSource = self
        navigationController?.delegate = self
        savedIngredientTableView.allowsMultipleSelectionDuringEditing = true
        
        setUpToolbar()
    }
    
    func setUpToolbar() {
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
        self.navigationController?.toolbar.barTintColor = UIColor.mySalmon
    }
}



// MARK: - IBActions & Objc Functions
extension SavedIngredientViewController {
    
    @objc func didPressDelete() {
        var selectedRows = self.savedIngredientTableView.indexPathsForSelectedRows
        // they need to be sorted in reverse order
        selectedRows = selectedRows?.sorted(by: >)
        if selectedRows != nil {
            for selectionIndex in selectedRows! {
                tableView(savedIngredientTableView, commit: .delete, forRowAt: selectionIndex)
            }
        }
        PersistenceManager.persistSavedIngredients(savedIngredients: savedIngredients)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // Toggles the actual editing actions appearing on a table view
        savedIngredientTableView.setEditing(editing, animated: true)
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {

        self.savedIngredientTableView.isEditing = !self.savedIngredientTableView.isEditing

        if savedIngredientTableView.isEditing {
            setEditing(enabled: true)
        } else {
            setEditing(enabled: false)
        }
    }
    
    @objc func clearAll() {
        savedIngredients.removeAll()
        savedIngredientTableView.reloadData()
        edit(editButton)
        PersistenceManager.persistSavedIngredients(savedIngredients: savedIngredients)
    }
    
}

// MARK: - UI Functions
extension SavedIngredientViewController {
    
    func setEditing(enabled: Bool) {
        if enabled {
            self.navigationController?.setToolbarHidden(false, animated: true)
            editButton.image = nil
            editButton.title = "Done"
            editButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: "Gotham", size: 17)!], for: .normal)
        } else {
            self.navigationController?.setToolbarHidden(true, animated: true)
            editButton.title = nil
            editButton.image = UIImage(named: "edit")
        }
    }
    
}

// MARK: - UITableView Data Source
extension SavedIngredientViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedIngredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = savedIngredientTableView.dequeueReusableCell(withIdentifier: "SavedIngredientCell") as! SavedIngredientTableViewCell
        cell.updateCell(with: savedIngredients[indexPath.row])
        cell.selectionStyle = .gray
        return cell
    }
    
}

// MARK: - UITableView Delegate
extension SavedIngredientViewController: UITableViewDelegate {
    
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
        PersistenceManager.persistSavedIngredients(savedIngredients: savedIngredients)
    }
}

// MARK: - UINavigationControllerDelegate
extension SavedIngredientViewController: UINavigationControllerDelegate {
    
    // update saved items in view controller
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        setEditing(enabled: false)
        if let homeViewController = (viewController as? HomeViewController) {
            homeViewController.savedIngredients = savedIngredients

            homeViewController.updateUI()
        }
        print("SEGUE IS GOING BACKWARDS FROM SAVED INGREDIENTS TO VIEW CONTROLLER")
        // Here you pass the to your original view controller
    }
}
