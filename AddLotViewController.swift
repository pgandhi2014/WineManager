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
    func saveLot(lot: ALot)
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
    var selectedRowIndex = 0
    var totalLotQuantity = 0
    var locationsArray: [String] = []
    let quantitiesArray = [Int](0...100)
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBAction func onSaveLot(sender: AnyObject) {
        var newLot = ALot()
        newLot.purchaseDate = dateFormatter.dateFromString(txtPurchaseDate.text!)!
        newLot.bottlePrice = Float(txtPrice.text!)!
        newLot.totalBottles = Int(txtQuantity.text!)!
        var tag = 0
        for location in txtLocations {
            if (!(location.text?.isEmpty)!) {
                newLot.locations[location.text!] = Int(txtBottles[tag].text!)!
            }
            tag += 1
        }
        if((self.delegate) != nil)
        {
            delegate?.saveLot(newLot)
            UIApplication.sharedApplication().keyWindow?.makeToast(message: "Saved", duration: 2.0, position: HRToastPositionCenter)
        }
    }
    
    @IBAction func onAddLocation(sender: AnyObject) {
        let alert = UIAlertController(title: "Add a new location", message: "provide a location name", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler(nil);
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
        
        locationsArray.removeDuplicates()
        locationsArray.sortInPlace()
        
        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        pickerView.delegate = self
        txtPurchaseDate.inputView = datePicker
        txtPurchaseDate.delegate = self
        var tag = 0
        for location in txtLocations {
            location.delegate = self
            self.txtBottles[tag].delegate = self
            location.inputView = pickerView
            self.txtBottles[tag].inputView = pickerView
            location.tag = tag
            self.txtBottles[tag].tag = tag
            tag += 1
        }
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        txtPurchaseDate.text = dateFormatter.stringFromDate(sender.date)
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
        selectedRowIndex = 0
    }
    
    
    
    // MARK: - Table View
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
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
        if (component == 0) {
            txtLocations[selectedRowIndex].text = locationsArray[row]
        } else if (component == 1) {
            txtBottles[selectedRowIndex].text = String(quantitiesArray[row])
        }
        
        
    }
    
    
}

