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

protocol SavingFilterViewControllerDelegate
{
    func applyFilters(filters: NSPredicate)
}


class FiltersViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var delegate : SavingFilterViewControllerDelegate?
    
    @IBOutlet weak var txtVarietal: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtRegion: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    
    @IBOutlet weak var btnApply: UIBarButtonItem!
    
    @IBAction func onBtnApplyPress(sender: UIBarButtonItem) {
        NSLog("Btn pressed")
        var subANDPredicates = [NSPredicate]()
        
        if (!(txtVarietal.text!.isEmpty)) {
            let predicateVarietal = NSPredicate(format: "varietal contains[cd] %@", txtVarietal.text!)
            subANDPredicates.append(predicateVarietal)
        }
        if (!(txtCountry.text!.isEmpty)) {
            let predicateCountry = NSPredicate(format: "country contains[cd] %@", txtCountry.text!)
            subANDPredicates.append(predicateCountry)
        }
        if (!(txtRegion.text!.isEmpty)) {
            let predicateRegion = NSPredicate(format: "region contains[cd] %@", txtRegion.text!)
            subANDPredicates.append(predicateRegion)
        }
        if (!(txtLocation.text!.isEmpty)) {
            let predicateLocation = NSPredicate(format: "SUBQUERY(lots, $l, ANY $l.statuses.location == %@).@count > 0", txtLocation.text!)
            subANDPredicates.append(predicateLocation)
        }
        if (!(txtPrice.text!.isEmpty)) {
            let predicatePriceMin = NSPredicate(format: "ANY lots.price >= %d", priceMin)
            let predicatePriceMax = NSPredicate(format: "ANY lots.price <= %d", priceMax)
            subANDPredicates.append(predicatePriceMin)
            subANDPredicates.append(predicatePriceMax)
        }
        
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: subANDPredicates)
        if((self.delegate) != nil)
        {
            delegate?.applyFilters(predicate)
        }
    }
    //SUBQUERY(models, $m, ANY $m.trims IN %@).@count > 0",arrayOfTrims];
    
    @IBOutlet weak var sortVintage: UISwitch!
    
    var selectedRowIndex = 0
    var varietalsArray: [String] = []
    var countriesArray: [String] = []
    var regionsArray: [String] = []
    var locationsArray: [String] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let pickerView = UIPickerView()
    let pricesArray = ["Any", "50", "100", "150", "200", "250", "300", "400", "500", "750", "1000", "2000"]
    
    var priceMin = 0
    var priceMax = 100000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FiltersViewController.handleTap(_:))))
        
        getDistinctVarietals()
        getDistinctLocatons()

        varietalsArray = varietalsArray.removeDuplicates()
        varietalsArray.sortInPlace()
        countriesArray = countriesArray.removeDuplicates()
        countriesArray.sortInPlace()
        regionsArray = regionsArray.removeDuplicates()
        regionsArray.sortInPlace()
        locationsArray.removeDuplicates()
        locationsArray.sortInPlace()
        
        pickerView.delegate = self
        txtVarietal.inputView = pickerView
        txtCountry.inputView = pickerView
        txtRegion.inputView = pickerView
        txtLocation.inputView = pickerView
        txtPrice.inputView = pickerView
        
        txtVarietal.delegate = self
        txtCountry.delegate = self
        txtRegion.delegate = self
        txtLocation.delegate = self
        txtPrice.delegate = self
        
        
    }
    
    func getDistinctVarietals() {
        let managedContext = appDelegate.managedObjectContext
        //FetchRequest
        let fetchRequest = NSFetchRequest(entityName: "Bottle")
        fetchRequest.propertiesToFetch = ["varietal", "country", "region"]
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
                    if let region = dic["region"]{
                        regionsArray.append(region)
                    }
                }
            }
        } catch {
            print("fetch failed:")
        }
    }
    
    func getDistinctLocatons() {
        let managedContext = appDelegate.managedObjectContext
        //FetchRequest
        let fetchRequest = NSFetchRequest(entityName: "Status")
        fetchRequest.propertiesToFetch = ["location"]
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        fetchRequest.returnsDistinctResults = true
        //Fetch
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            for i in 0 ..< results.count {
                if let dic = (results[i] as? [String : String]){
                    if let location = dic["location"]{
                        if (!location.isEmpty) {
                            locationsArray.append(location)
                        }
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
        pickerView.selectRow(0, inComponent: 0, animated: false)
        
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
        if (selectedRowIndex == 14) {
            return 3
        }
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 1) {
            if (selectedRowIndex == 14) {
                return 1
            } else {
                return 0
            }
        } else {
            if (selectedRowIndex == 10) {
                return varietalsArray.count
            } else if (selectedRowIndex == 11) {
                return countriesArray.count
            } else if (selectedRowIndex == 12) {
                return regionsArray.count
            } else if (selectedRowIndex == 13) {
                return locationsArray.count
            } else if (selectedRowIndex == 14) {
                return pricesArray.count
            } else {
                return 0
            }
        }
    }
    
    //MARK: Picker Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 1) {
            return "TO"
        }
        if (selectedRowIndex == 10) {
            return varietalsArray[row]
        } else if (selectedRowIndex == 11) {
            return countriesArray[row]
        } else if (selectedRowIndex == 12) {
            return regionsArray[row]
        } else if (selectedRowIndex == 13) {
            return locationsArray[row]
        } else if (selectedRowIndex == 14) {
            return "$" + pricesArray[row]
        } else {
            return ""
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (selectedRowIndex == 10) {
            txtVarietal.text = varietalsArray[row]
        } else if (selectedRowIndex == 11) {
            txtCountry.text = countriesArray[row]
        } else if (selectedRowIndex == 12) {
            txtRegion.text = regionsArray[row]
        } else if (selectedRowIndex == 13) {
            txtLocation.text = locationsArray[row]
        } else if (selectedRowIndex == 14) {
            if (component == 0) {
                if (row == 0) {
                    priceMin = 0
                } else {
                    priceMin = Int(pricesArray[row])!
                }
            } else if (component == 2) {
                if (row == 0) {
                    priceMax = 100000
                } else {
                    priceMax = Int(pricesArray[row])!
                }
            }
            txtPrice.text = "$" + String(priceMin) + " to $" + String(priceMax)
        }
    }
    
}