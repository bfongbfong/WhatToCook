//
//  ViewController.swift
//  WhatToEat
//
//  Created by Brandon Fong on 7/1/19.
//  Copyright © 2019 Fiesta Togo Inc. All rights reserved.
//

import UIKit
import Unirest

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var greenCircleForSearchButton: UIView!
    @IBOutlet weak var fridgeBarButtonItem: BadgeBarButtonItem!
    @IBOutlet var tapSearchButton: UITapGestureRecognizer!
    
    var searchResults: [SearchedIngredient] = []
    var savedIngredients: [SearchedIngredient] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        hideKeyboardWhenTappedAround()
        
        tableView.keyboardDismissMode = .onDrag
        greenCircleForSearchButton.layer.cornerRadius = greenCircleForSearchButton.frame.width/8
        greenCircleForSearchButton.layer.masksToBounds = true
        greenCircleForSearchButton.backgroundColor = UIColor.gray
        tapSearchButton.isEnabled = false

        textField.contentVerticalAlignment = .center
        textField.layer.cornerRadius = 15
        textField.clipsToBounds = true
        navigationController?.navigationBar.barTintColor = myGreen
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "PoetsenOne-Regular", size: 21)!]
        
//        self.tabBarItem.imageInsets = UIEdgeInsets(top: 5.5, left: 0, bottom: -5.5, right: 0)
//        self.title = nil
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.barStyle = .black
        
        // to make "SEARCH INGREDIENTS" placeholder text fit and cetner vertically
        for subview in textField.subviews {
            if let label = subview as? UILabel {
                label.minimumScaleFactor = 0.3
                label.adjustsFontSizeToFitWidth = true
                label.baselineAdjustment = .alignCenters
            }
        }
        
        // add horizontal padding to "SEARCH INGREDIENTS" placeholder
        let leftPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        let rightPaddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
    }
    
    // MARK: - tableView data source methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return searchResults.count
        } else {
            return savedIngredients.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell") as! AutocompleteSearchTableViewCell
        cell.updateCell(with: searchResults[indexPath.row])
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    
    // MARK: - Tableview Delegate methods
    
    // save ingredients
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        jumpToCartAnimation(indexPath: indexPath)
        
        // remove from tableView
        let ingredient = SearchedIngredient(name: searchResults[indexPath.row].name, imageName: searchResults[indexPath.row].imageName)
        searchResults.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        searchResults = []
        tableView.reloadData()
        // add to bottom tableView
        savedIngredients.append(ingredient)
        // empty text field
        textField.text = ""
        UIDevice.vibrate()
        
    }
    
    @IBAction func textFieldEditingChanged(_ sender: Any) {
        print("EDITING CHANGED")
        
        // make sure if textfield is empty, empty table view
        if textField.text == "" || textField.text == " " {
            searchResults.removeAll()
            tableView.reloadData()
        } else {
            // populate table view with search results
            if let text = textField.text {
                autocompleteIngredientSearch(input: text)
                // https://spoonacular.com/cdn/ingredients_100x100/
            }
        }
    }
    

    // MARK: - API Requests
    func autocompleteIngredientSearch(input: String) {
        
        if input == "" || input == " " {
            return
        }
        
//        if input == "\'" {
//            print("THERE'S AN APOSTROPHE")
//            input = input.replacingOccurrences(of: "\'", with: "")
//        }
        
        let inputAdjustedForSpecialCharacters = replaceSpecialCharacters(input: input)
        
        UNIRest.get { (request) in
            
            let requestString = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/food/ingredients/autocomplete?number=7&query=\(inputAdjustedForSpecialCharacters)"
            
            if let unwrappedRequest = request {
                unwrappedRequest.url = requestString
                unwrappedRequest.headers = ["X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", "X-RapidAPI-Key": "ba59075c47msh50cd1afad35f3adp1d65cdjsn4b0f3c045f70"]
            }
            
            }?.asJsonAsync({ (response, error) in
                
                let body: UNIJsonNode = response!.body
                //                let rawBody: Data = response!.rawBody
                //                print(String(data: rawBody, encoding: .utf8))
                
                if let errorThatHappened = error {
                    print("ERROR HAPPENED")
                    print("btw this is the error: \(errorThatHappened)")
                }
                
                if let bodyJsonArray = body.jsonArray() {
                    print("JSON ARRAY ==================================================")
                    print(bodyJsonArray)
                    self.searchResults = []
                    for jsonObject in bodyJsonArray {
                        if let dictionary = jsonObject as? [String: Any] {
                            
                            let searchedIngredient = SearchedIngredient(name: dictionary["name"] as! String, imageName: dictionary["image"] as! String)
                            var matchFound = false
                            for savedIngredient in self.savedIngredients {
                                if searchedIngredient == savedIngredient {
                                    matchFound = true
                                }
                            }
                            if matchFound == false {
                                self.searchResults.append(searchedIngredient)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
                if let bodyJsonObject = body.jsonObject() {
                    print("JSON OBJECT ==================================================")
                    print(bodyJsonObject)
                }
            })
    }
    
    func getSavedItemsAsRequestString() -> String {
        var resultString = ""
        for (index, ingredient) in savedIngredients.enumerated() {
            if index != 0 {
                resultString += "%2C+"
            }
            let nameOfIngredientWithoutSpaces = replaceSpecialCharacters(input: ingredient.name)
            resultString += nameOfIngredientWithoutSpaces
        }
        return resultString
    }
    
    // MARK: - animations
    
    func jumpToCartAnimation(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AutocompleteSearchTableViewCell
        
        let imageViewPosition : CGPoint = cell.ingredientImage.convert(cell.ingredientImage.bounds.origin, to: self.view)
        
        let imgViewTemp = UIImageView(frame: CGRect(x: imageViewPosition.x, y: imageViewPosition.y, width: cell.ingredientImage.frame.size.width, height: cell.ingredientImage.frame.size.height))
        
        imgViewTemp.image = cell.ingredientImage.image
        
        animation(tempView: imgViewTemp)
    }
    
    // second part of jump to cart
    func animation(tempView : UIView)  {
        self.view.addSubview(tempView)

        UIView.animate(withDuration: 0.5, animations: {
            
            tempView.animationZoom(scaleX: 0.2, y: 0.2)
            tempView.animationRoted(angle: CGFloat(Double.pi))
            
            tempView.frame.origin.x = self.navigationController!.navigationBar.center.x + 5
            tempView.frame.origin.y = self.navigationController!.navigationBar.center.y
            
        }, completion: { _ in
            
            tempView.removeFromSuperview()
            self.fridgeBarButtonItem.badgeNumber = self.savedIngredients.count
            self.greenCircleForSearchButton.backgroundColor = mySalmon
            self.tapSearchButton.isEnabled = true

        })
    }

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "ToSearchResults" {
            if let destinationVC = segue.destination as? SearchResultsViewController {
                
                // temp solution to back button word showing up
//                let backItem = UIBarButtonItem()
//                backItem.title = ""
//                navigationItem.backBarButtonItem = backItem
                
                if savedIngredients.count == 0 {
                    
                } else {
                    let ingredientNames = savedIngredients.map({ $0.name })
                    let ingredientNamesWithoutSpaces = ingredientNames.map({
                        $0.replacingOccurrences(of: " ", with: "+")})
                    let ingredientsString = ingredientNamesWithoutSpaces.joined(separator: "%2C")
                    destinationVC.ingredientNames = ingredientsString
                }
            }
        } else if segue.identifier == "ToSavedIngredients" {
            if let destinationVC = segue.destination as? SavedIngredientViewController {
                destinationVC.savedIngredients = savedIngredients
                // temp solution to back button word 
//                let backItem = UIBarButtonItem()
//                backItem.title = ""
//                navigationItem.backBarButtonItem = backItem
            }
        }
    }
}

// global function
func replaceSpecialCharacters(input: String) -> String {
    var returnString = input.replacingOccurrences(of: " ", with: "+")
    returnString = returnString.replacingOccurrences(of: "‘", with: "\'")
    returnString = returnString.replacingOccurrences(of: "’", with: "\'")
    // this stuff isn't working below... above is working though
    returnString = returnString.replacingOccurrences(of: "“", with: "\"")
    returnString = returnString.replacingOccurrences(of: "”", with: "\"")
    returnString = returnString.replacingOccurrences(of: "\"", with: "")
    returnString = returnString.replacingOccurrences(of: "\\", with: "")

// *********** STUCK ON WHY THE API REQUEST FAILS IF YOU TYPE A DOUBLE QUOTE

    

//    returnString = returnString.replacingOccurrences(of: "'", with: "")

    returnString = returnString.replacingOccurrences(of: "\"", with: "\"")
//    returnString = returnString.typographized(language: "en")
    return returnString
}


// hide keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

// for use in add to cart animation
extension UIView {
    func animationZoom(scaleX: CGFloat, y: CGFloat) {
        self.transform = CGAffineTransform(scaleX: scaleX, y: y)
    }
    
    func animationRoted(angle : CGFloat) {
        self.transform = self.transform.rotated(by: angle)
    }
}

let myGreen = UIColor(red: 128/255, green: 202/255, blue: 50/255, alpha: 1.0)
let mySalmon = UIColor(displayP3Red: 253/255, green: 156/255, blue: 136/255, alpha: 1)




