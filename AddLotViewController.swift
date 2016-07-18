//
//  AddLotViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 6/29/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import CoreData

protocol SaveALotViewControllerDelegate
{
    func saveLot(lot: SimpleLot)
}

class AddLotController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    var delegate : SaveALotViewControllerDelegate?
    
    @IBOutlet weak var txtPurchaseDate: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtQuantity: UITextField!
    
    @IBOutlet var txtLocations: [UITextField]!
    @IBOutlet var txtBottles: [UITextField]!
    
    let pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    let dateFormatter = NSDateFormatter()
    
    var selectedRowIndex = -1
    
    var locationsArray: [String] = []
    let quantitiesArray = [Int](0...100)
    
    var lotInfo = SimpleLot()
    var viewMode = "Add"

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBAction func onSaveLot(sender: AnyObject) {
        let keyWindow = UIApplication.sharedApplication().keyWindow
        var newLot = SimpleLot()
        
        var sumOfBottles = 0
        
        if ((txtPurchaseDate.text!).isEmpty) {
            keyWindow!.makeToast(message: "Must provide a valid date", duration: 2.0, position: HRToastPositionCenter)
            return
        }
        newLot.purchaseDate = dateFormatter.dateFromString(txtPurchaseDate.text!)!
        
        if ((txtPrice.text!).isEmpty) {
            keyWindow!.makeToast(message: "Must provide a valid purchase price", duration: 2.0, position: HRToastPositionCenter)
            return
        }
        newLot.bottlePrice = Float(txtPrice.text!)!
        
        if ((txtQuantity.text!).isEmpty) {
            keyWindow!.makeToast(message: "Must provide number of bottles", duration: 2.0, position: HRToastPositionCenter)
            return
        }
        newLot.totalBottles = Int(txtQuantity.text!)!
        
        for (index, location) in txtLocations.enumerate() {
            if (!(location.text?.isEmpty)!) {
                let numberOfBottles = Int(txtBottles[index].text!)!
                if (numberOfBottles > 0) {
                    sumOfBottles += numberOfBottles
                    newLot.locations[location.text!] = numberOfBottles
                }
            }
        }
        if (newLot.locations.count == 0) {
            keyWindow!.makeToast(message: "Must provide atleast 1 location", duration: 2.0, position: HRToastPositionCenter)
            return
        }
        
        if (viewMode == "Add") {
            if (sumOfBottles != newLot.totalBottles) {
                keyWindow!.makeToast(message: "All bottles not accounted for", duration: 2.0, position: HRToastPositionCenter)
                return
            }
        }
        
        if((self.delegate) != nil)
        {
            delegate?.saveLot(newLot)
        }
    }
    
    @IBAction func onAddLocation(sender: AnyObject) {
        let alert = UIAlertController(title: "Add a new location", message: "provide a location name", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.autocapitalizationType = .Words
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil));
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action:UIAlertAction) in
            let entry = alert.textFields![0].text!
            self.locationsArray.insert(entry, atIndex: 0)
            self.pickerView.reloadAllComponents()
            self.pickerView.selectRow(0, inComponent: 0, animated: true)
        }))
        presentViewController(alert, animated: true, completion: nil);

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FiltersViewController.handleTap(_:))))
        
        getDistinctLocatons()
        
        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        pickerView.delegate = self
        txtPurchaseDate.inputView = datePicker
        txtPurchaseDate.delegate = self
        txtPurchaseDate.text = dateFormatter.stringFromDate(NSDate())
        
        for (index, location) in txtLocations.enumerate() {
            location.delegate = self
            location.inputView = pickerView
            location.tag = index
        }
        for (index, bottle) in txtBottles.enumerate() {
            bottle.delegate = self
            bottle.inputView = pickerView
            bottle.tag = index
        }
        
        if (viewMode == "Edit") {
            txtPurchaseDate.text = dateFormatter.stringFromDate(lotInfo.purchaseDate)
            txtPrice.text = String(lotInfo.bottlePrice)
            txtQuantity.text = String(lotInfo.totalBottles)
            for (index, lot) in lotInfo.locations.enumerate() {
                txtLocations[index].text = lot.0
                txtBottles[index].text = String(lot.1)
            }
            txtPurchaseDate.enabled = false
            txtQuantity.enabled = false
            txtPrice.enabled = false
            
        }
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        txtPurchaseDate.text = dateFormatter.stringFromDate(sender.date)
    }
    
    
    func getDistinctLocatons() {
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Status")
        fetchRequest.propertiesToFetch = ["location"]
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        fetchRequest.returnsDistinctResults = true
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
            locationsArray.removeDuplicates()
            locationsArray.sortInPlace()
        } catch {
            print("fetch failed:")
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            view.endEditing(true)
        }
        sender.cancelsTouchesInView = false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedRowIndex = textField.tag
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        selectedRowIndex = -1
    }
    
    
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowHeight = CGFloat(44.0)
        return rowHeight
    }
    
    //MARK: Picker Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return locationsArray.count
        } else if (component == 1) {
            return quantitiesArray.count
        }
        return 0
    }
    
    //MARK: Picker Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return locationsArray[row]
        } else if (component == 1) {
            return String(quantitiesArray[row])
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (selectedRowIndex == -1) {
            return
        }
        if (component == 0) {
            txtLocations[selectedRowIndex].text = locationsArray[row]
        } else if (component == 1) {
            txtBottles[selectedRowIndex].text = String(quantitiesArray[row])
        }
    }
}

