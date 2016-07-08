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
    func applyFilters(filter: NSPredicate, sort: NSSortDescriptor)
}


class FiltersViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var delegate : SavingFilterViewControllerDelegate?
    
    @IBOutlet weak var txtVarietal: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtRegion: UITextField!
    @IBOutlet weak var txtLocation: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtSortOrder: UITextField!
    
    @IBOutlet weak var viewOptions: UISegmentedControl!
    
    var selectedRowIndex = 0
    var selectedSortOrderIndex = 4
    var varietalsArray: [String] = []
    var countriesArray: [String] = []
    var regionsArray: [String] = []
    var locationsArray: [String] = []
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let pickerView = UIPickerView()
    let pricesArray = ["Any", "50", "100", "150", "200", "250", "300", "400", "500", "750", "1000", "2000"]
    let sorterArray = ["Name: A to Z", "Name: Z to A", "Vintage: Young to Mature", "Vintage: Mature to Young", "Price: High to Low", "Price: Low to High", "Points: High to Low", "Points: Low to High", "Purchase Date: Oldest to Newest", "Purchase Date: Newest to Oldest", "Drunk Date: Oldest to Newest", "Drunk Date: Newest to Oldest"]
    
    var priceMin = 0
    var priceMax = 100000
    
    
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
        if (viewOptions.selectedSegmentIndex == 0) {
            let predicateView = NSPredicate(format: "availableBottles > 0")
            subANDPredicates.append(predicateView)
        } else if (viewOptions.selectedSegmentIndex == 1) {
            let predicateView = NSPredicate(format: "drunkBottles > 0")
            subANDPredicates.append(predicateView)
        } else if (viewOptions.selectedSegmentIndex == 2) {
            let predicateView = NSPredicate(value: true)
            subANDPredicates.append(predicateView)
        }
        
        let predicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: subANDPredicates)
        
        var sortDescriptor = NSSortDescriptor(key: "maxPrice", ascending: false)
        switch selectedSortOrderIndex {
        case 0:
            sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        case 1:
            sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        case 2:
            sortDescriptor = NSSortDescriptor(key: "vintage", ascending: false)
        case 3:
            sortDescriptor = NSSortDescriptor(key: "vintage", ascending: true)
        case 4:
            sortDescriptor = NSSortDescriptor(key: "maxPrice", ascending: false)
        case 5:
            sortDescriptor = NSSortDescriptor(key: "maxPrice", ascending: true)
        case 6:
            sortDescriptor = NSSortDescriptor(key: "points", ascending: false)
        case 7:
            sortDescriptor = NSSortDescriptor(key: "points", ascending: true)
        case 8:
            sortDescriptor = NSSortDescriptor(key: "lastPurchaseDate", ascending: true)
        case 9:
            sortDescriptor = NSSortDescriptor(key: "lastPurchaseDate", ascending: false)
        case 10:
            sortDescriptor = NSSortDescriptor(key: "lastDrunkDate", ascending: true)
        case 11:
            sortDescriptor = NSSortDescriptor(key: "lastDrunkDate", ascending: false)
        default:
            sortDescriptor = NSSortDescriptor(key: "maxPrice", ascending: false)
        }
        
        if((self.delegate) != nil)
        {
            delegate?.applyFilters(predicate, sort: sortDescriptor)
        }
    }
    
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
        txtSortOrder.inputView = pickerView
        
        txtVarietal.delegate = self
        txtCountry.delegate = self
        txtRegion.delegate = self
        txtLocation.delegate = self
        txtPrice.delegate = self
        txtSortOrder.delegate = self
        
        txtSortOrder.text = sorterArray[selectedSortOrderIndex]
        
        
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
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 5
        } else {
            return 1
        }
    }
    
//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if (section == 0) {
//            return 0.0
//        }
//        return super.tableView(tableView, heightForHeaderInSection: section)
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
            } else if (selectedRowIndex == 15) {
                return sorterArray.count
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
        } else if (selectedRowIndex == 15) {
            return sorterArray[row]
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
        } else if (selectedRowIndex == 15) {
            selectedSortOrderIndex = row
            txtSortOrder.text = sorterArray[row]
        } else if (selectedRowIndex == 14) {
            if (component == 0) {
                if (row == 0) {
                    priceMin = 0
                } else {
                    priceMin = Int(pricesArray[row])!
                    if (priceMin >= priceMax) {
                        if (row < pricesArray.count-1) {
                            pickerView.selectRow(row+1, inComponent: 2, animated: true)
                            priceMax = Int(pricesArray[row+1])!
                        } else {
                            pickerView.selectRow(0, inComponent: 2, animated: true)
                            priceMax = 100000
                        }
                    }
                }
            } else if (component == 2) {
                if (row == 0) {
                    priceMax = 100000
                } else {
                    priceMax = Int(pricesArray[row])!
                    if (priceMax <= priceMin) {
                        pickerView.selectRow(row-1, inComponent: 0, animated: true)
                        if (row > 1) {
                            priceMin = Int(pricesArray[row-1])!
                        } else if (row == 1) {
                            priceMin = 0
                        }
                    }
                }
            }
            txtPrice.text = "$" + String(priceMin) + " to $" + String(priceMax)
        }
    }
    
}