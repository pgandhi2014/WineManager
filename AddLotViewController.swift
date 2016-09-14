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
    
    let pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    let dateFormatter = NSDateFormatter()
    
    var selectedRowIndex = -1
    
    var locationsArray: [String] = []
    
    var lotInfo = SimpleLot()
    var viewMode = "Add"
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBAction func onSaveLot(sender: AnyObject) {
        let keyWindow = UIApplication.sharedApplication().keyWindow
        
        if (lotInfo.bottlePrice == 0.0) {
            keyWindow!.makeToast(message: "Must provide a valid purchase price", duration: 2.0, position: HRToastPositionCenter)
            return
        }

        if (lotInfo.totalBottles == 0) {
            keyWindow!.makeToast(message: "Must provide number of bottles", duration: 2.0, position: HRToastPositionCenter)
            return
        }

        if (lotInfo.locs.count == 0) {
            keyWindow!.makeToast(message: "Must provide atleast 1 location", duration: 2.0, position: HRToastPositionCenter)
            return
        }
        
        if (viewMode == "Add") {
            if (lotInfo.locs.count != lotInfo.totalBottles) {
                keyWindow!.makeToast(message: "All bottles not accounted for", duration: 2.0, position: HRToastPositionCenter)
                return
            }
        }
        
        
        
        if((self.delegate) != nil)
        {
            delegate?.saveLot(lotInfo)
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
        
        }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (viewMode == "Edit") {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            let customCell = cell as! CustomLotTopCell
            customCell.txtPurchaseDate.text! = dateFormatter.stringFromDate(lotInfo.purchaseDate)
            customCell.txtPrice.text! = String(lotInfo.bottlePrice)
            customCell.txtQuantity.text! = String(lotInfo.totalBottles)
            customCell.txtPurchaseDate.enabled = false
            customCell.txtPrice.enabled = false
            customCell.txtQuantity.enabled = false
            var loopIndex = 0
            while (loopIndex < lotInfo.locs.count) {
                let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: loopIndex, inSection: 1))
                let customCell = cell as! CustomLotCell
                customCell.txtBottleLocation.text! = lotInfo.locs[loopIndex]!.location
                if (customCell.txtBottleLocation.text == "Drunk") {
                    customCell.txtBottleLocation.enabled = false
                }
                loopIndex += 1
                customCell.setNeedsDisplay()
            }
            customCell.setNeedsDisplay()
        }
        
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        lotInfo.purchaseDate = sender.date
    }
    
    
    func getDistinctLocatons() {
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Bottle")
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
        if (textField.tag == 101) {
            textField.text! = dateFormatter.stringFromDate(lotInfo.purchaseDate)
        } else if (textField.tag == 102) {
            if !(textField.text!.isEmpty) {
            lotInfo.bottlePrice = Float(textField.text!)!
            }
        }
        textField.resignFirstResponder()
        selectedRowIndex = -1
        
    }
    
    func textFieldDidChange(textField: UITextField) {
        let sectionSet = NSIndexSet(index: 1)
        if !(textField.text!.isEmpty) {
            lotInfo.totalBottles = Int(textField.text!)!
        } else {
            lotInfo.totalBottles = 0
        }
        tableView.reloadSections(sectionSet, withRowAnimation: .Fade)
    }
    
    
    
    // MARK: - Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        return lotInfo.totalBottles
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowHeight = CGFloat(44.0)
        return rowHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRowIndex = indexPath.row
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellTopRow", forIndexPath: indexPath)
            let customCell = cell as! CustomLotTopCell
            customCell.txtPurchaseDate!.text = dateFormatter.stringFromDate(lotInfo.purchaseDate)
            if (lotInfo.bottlePrice == 0.0) {
                customCell.txtPrice!.text = ""
            } else {
                customCell.txtPrice!.text = String(lotInfo.bottlePrice)
            }
            
            if (lotInfo.totalBottles == 0) {
                customCell.txtQuantity!.text = ""
            } else {
                customCell.txtQuantity!.text = String(lotInfo.totalBottles)
            }
            customCell.txtPurchaseDate!.delegate = self
            customCell.txtQuantity!.delegate = self
            customCell.txtPrice!.delegate = self
            customCell.txtPurchaseDate!.tag = 101
            customCell.txtPrice!.tag = 102
            customCell.txtQuantity!.tag = 103
            customCell.txtPurchaseDate!.inputView = self.datePicker
            customCell.txtQuantity.addTarget(self, action: #selector(self.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellLotRows", forIndexPath: indexPath)
            let customCell = cell as! CustomLotCell
            customCell.txtBottleLocation!.inputView = self.pickerView
            customCell.txtBottleLocation!.delegate = self
            customCell.txtBottleLocation!.tag = indexPath.row
            
            return cell
        }
    }

    
    //MARK: Picker Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return locationsArray.count
        }
        return 0
    }
    
    //MARK: Picker Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return locationsArray[row]
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (selectedRowIndex == -1) {
            return
        }
        if (selectedRowIndex >= lotInfo.locs.count) {
            let newLoc = SimpleLoc()
            lotInfo.locs[selectedRowIndex] = newLoc
        }
        lotInfo.locs[selectedRowIndex]!.location = locationsArray[row]
        lotInfo.locs[selectedRowIndex]!.status = LotState.Dirty
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedRowIndex, inSection: 1))
        let customCell = cell as! CustomLotCell
        customCell.txtBottleLocation!.text = locationsArray[row]
        customCell.setNeedsDisplay()
        
    }
}

