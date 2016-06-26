//
//  FiltersViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 6/21/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import CoreData

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}


class FiltersViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var txtVarietal: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtRegion: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    
    @IBOutlet weak var sortVintage: UISwitch!
    
    var selectedRowIndex = 0
    var varietalsArray: [String] = []
    var countriesArray: [String] = []
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let pickerView = UIPickerView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FiltersViewController.handleTap(_:))))
        
        getDistinctVarietals()
        varietalsArray = varietalsArray.removeDuplicates()
        varietalsArray.sortInPlace()
        countriesArray = countriesArray.removeDuplicates()
        countriesArray.sortInPlace()
        
        pickerView.delegate = self
        txtVarietal.inputView = pickerView
        txtCountry.inputView = pickerView
        
        txtVarietal.delegate = self
        txtCountry.delegate = self
        txtRegion.delegate = self
        
        
    }
    
    func getDistinctVarietals() {
        let managedContext = appDelegate.managedObjectContext
        //FetchRequest
        let fetchRequest = NSFetchRequest(entityName: "Bottle")
        fetchRequest.propertiesToFetch = ["varietal", "country"]
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        fetchRequest.returnsDistinctResults = true
        //Fetch
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            for i in 0 ..< results.count {
                if let dic = (results[i] as? [String : String]){
                    if let varietal = dic["varietal"]{
                        varietalsArray.append(varietal)
                    }
                    if let country = dic["country"]{
                        countriesArray.append(country)
                    }
                }
            }
        } catch {
            print("fetch failed:")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedRowIndex = textField.tag
        pickerView.reloadAllComponents()
        
    }

    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        selectedRowIndex = 0
        
    }
    
    
    

    // MARK: - Table View
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 5
        } else {
            return 3
        }
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("CellStats", forIndexPath: indexPath)
//        cell.textLabel?.text = keys[indexPath.row]
//        if (indexPath.section == 0) {
//            cell.detailTextLabel?.text = valsAvailable[indexPath.row]
//        } else if (indexPath.section == 1) {
//            cell.detailTextLabel?.text = valsDrunk[indexPath.row]
//        } else if (indexPath.section == 2) {
//            cell.detailTextLabel?.text = valsTotal[indexPath.row]
//        } else if (indexPath.section == 3) {
//            cell.detailTextLabel?.text = valsFilter[indexPath.row]
//        }
//        return cell
//    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    //MARK: Picker Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (selectedRowIndex == 10) {
            return varietalsArray.count
        } else if (selectedRowIndex == 11) {
            return countriesArray.count
        } else {
            return 0
        }
    }
    
    //MARK: Picker Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (selectedRowIndex == 10) {
            return varietalsArray[row]
        } else if (selectedRowIndex == 11) {
            return countriesArray[row]
        } else {
            return ""
        }

    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (selectedRowIndex == 10) {
            txtVarietal.text = varietalsArray[row]
        } else if (selectedRowIndex == 11) {
            txtCountry.text = countriesArray[row]
        }
    }
    
}