//
//  AddEditViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 6/27/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import CoreData


class AddEditViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, SaveALotViewControllerDelegate {

    @IBOutlet weak var txtVintage: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtVarietal: UITextField!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtRegion: UITextField!
    @IBOutlet weak var txtPoints: UITextField!
    @IBOutlet weak var txtSource: UITextField!
    @IBOutlet weak var txtReview: UITextView!
    @IBOutlet weak var txtPurchaseDate: UITextField!
    @IBOutlet weak var txtQuantity: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    var txtLocation: UITextField!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    let pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    let dateFormatter = NSDateFormatter()
    var selectedRowIndex = 0
    var allLots: [ALot] = []
    var lotEntities: [String] = []
    var varietalsArray: [String] = []
    var countriesArray: [String] = []
    var regionsArray: [String] = []
    var locationsArray: [String] = []
    let quantitiesArray = [Int](0...100)
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBAction func onSave(sender: AnyObject) {
        let newBottle = NSEntityDescription.insertNewObjectForEntityForName("Bottle", inManagedObjectContext: self.managedObjectContext!) as! Bottle
            
        newBottle.name = txtName.text
        if let myNumber = NSNumberFormatter().numberFromString(txtVintage.text!) {
            newBottle.vintage = myNumber
        }
        newBottle.varietal = txtVarietal.text
        newBottle.region = txtRegion.text
        newBottle.country = txtCountry.text
        
        newBottle.reviewSource = txtSource.text
        if let myNumber = NSNumberFormatter().numberFromString(txtPoints.text!) {
            newBottle.points = myNumber
        }
        newBottle.review = txtReview.text
        
        for (_, value) in allLots.enumerate() {
            let newLot = NSEntityDescription.insertNewObjectForEntityForName("PurchaseLot", inManagedObjectContext: self.managedObjectContext!) as! PurchaseLot
            let lot = value
            newLot.bottle = newBottle
            newLot.purchaseDate = lot.purchaseDate
            if (newLot.purchaseDate!.compare(newBottle.lastPurchaseDate!) == NSComparisonResult.OrderedDescending) {
                newBottle.lastPurchaseDate = newLot.purchaseDate
            }
            newLot.price = NSDecimalNumber(float: lot.bottlePrice)
            if (newLot.price!.compare(newBottle.maxPrice!) == NSComparisonResult.OrderedDescending) {
                newBottle.maxPrice = newLot.price
            }
            newLot.quantity = lot.totalBottles
            
            for (loc, count) in lot.locations {
                var loopIndex = 0
                while (loopIndex < count) {
                    let newLoc = NSEntityDescription.insertNewObjectForEntityForName("Status", inManagedObjectContext: self.managedObjectContext!) as! Status
                    newLoc.lot = newLot
                    newLoc.available = 1
                    newLot.availableBottles = (newLot.availableBottles?.integerValue)! + 1
                    newLoc.location = loc
                    loopIndex += 1
                }
            }
            newBottle.availableBottles = (newBottle.availableBottles?.integerValue)! + (newLot.availableBottles?.integerValue)!
            newBottle.drunkBottles = (newBottle.drunkBottles?.integerValue)! + (newLot.drunkBottles?.integerValue)!
        }
        
        // Save the context.
        do {
            try self.managedObjectContext!.save()
            UIApplication.sharedApplication().keyWindow?.makeToast(message: "Saved", duration: 2.0, position: HRToastPositionCenter)
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            abort()
        }
            
    }
    
    @IBAction func onAddVarietal(sender: UIButton) {
        showAlert("Add a new Varietal", message: "please provide varietal name", mode: "Varietal")
    }
    
    @IBAction func onAddCountry(sender: UIButton) {
        showAlert("Add a new country", message: "please provide country name", mode: "Country")
    }
    
    
    @IBAction func onAddRegion(sender: UIButton) {
        showAlert("Add a new region", message: "please provide region name", mode: "Region")
    }
    
    func showAlert(title: String, message: String, mode: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler(nil);
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil));
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action:UIAlertAction) in
            let entry = alert.textFields![0].text!
            if (mode == "Varietal") {
                self.varietalsArray.insert(entry, atIndex: 0)
                self.txtVarietal.text = entry
            } else if (mode == "Country") {
                self.countriesArray.insert(entry, atIndex: 0)
                self.txtCountry.text = entry
            } else if (mode == "Region") {
                self.regionsArray.insert(entry, atIndex: 0)
                self.txtRegion.text = entry
            }
            self.pickerView.reloadAllComponents()
            self.pickerView.selectRow(0, inComponent: 0, animated: true)
            
        }))
        presentViewController(alert, animated: true, completion: nil);
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FiltersViewController.handleTap(_:))))
        
        getDistinctVarietals()
        getDistinctLocatons()
        
        lotEntities.append("Buffer0")
        lotEntities.append("Buffer1")
        lotEntities.append("Buffer2")
        lotEntities.append("Buffer3")
        lotEntities.append("Buffer4")
        lotEntities.append("Buffer5")
        
        varietalsArray = varietalsArray.removeDuplicates()
        varietalsArray.sortInPlace()
        countriesArray = countriesArray.removeDuplicates()
        countriesArray.sortInPlace()
        regionsArray = regionsArray.removeDuplicates()
        regionsArray.sortInPlace()
        locationsArray.removeDuplicates()
        locationsArray.sortInPlace()

        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        pickerView.delegate = self
        txtVarietal.inputView = pickerView
        txtVarietal.delegate = self
        txtCountry.inputView = pickerView
        txtCountry.delegate = self
        txtRegion.inputView = pickerView
        txtRegion.delegate = self
        txtReview.textColor = UIColor.lightGrayColor()
        txtReview.delegate = self
        //txtPurchaseDate.inputView = datePicker
        //txtPurchaseDate.delegate = self
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        txtPurchaseDate.text = dateFormatter.stringFromDate(sender.date)
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

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Expert Review"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAddLot" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! AddLotController
            controller.delegate = self
        }
    }
    
    func saveLot(lot: ALot) {
        allLots.append(lot)
        var aLotEntity = ""
        if (lot.totalBottles > 1) {
            aLotEntity = String(lot.totalBottles) + " bottles for $" + String(lot.bottlePrice) + " each on " + dateFormatter.stringFromDate(lot.purchaseDate)
        } else {
            aLotEntity = String(lot.totalBottles) + " bottle for $" + String(lot.bottlePrice) + " on " + dateFormatter.stringFromDate(lot.purchaseDate)
        }
        lotEntities.append(aLotEntity)
        self.tableView.reloadData()
    }

    

    
    // MARK: - Table View
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if (cell?.accessoryType == .DisclosureIndicator) {
            performSegueWithIdentifier("showAddLot", sender: nil)
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if (cell?.accessoryType == .DisclosureIndicator) {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lotEntities.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if (indexPath.row < 6) {
            return cell
        }
        if (indexPath.row < lotEntities.count) {
            cell.textLabel?.text = lotEntities[indexPath.row]
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.accessoryType = .None
        } else {
            cell.textLabel?.text = "Add a lot"
            cell.textLabel?.textColor = UIColor.lightGrayColor()
            cell.accessoryType = .DisclosureIndicator
        }
        return cell
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight = CGFloat(44.0)
        if (indexPath.row == 5) {
            rowHeight = CGFloat(144.0)
        }
        return rowHeight
    }
    
    //MARK: Picker Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if (selectedRowIndex == 21) {
            return 2
        }
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (selectedRowIndex == 21) {
            if (component == 0) {
                return locationsArray.count
            } else if (component == 1) {
                return quantitiesArray.count
            }
        } else if (selectedRowIndex == 12) {
            return varietalsArray.count
        } else if (selectedRowIndex == 13) {
            return countriesArray.count
        } else if (selectedRowIndex == 14) {
            return regionsArray.count
        }
        return 0
    }
    
    //MARK: Picker Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (selectedRowIndex == 21) {
            if (component == 0) {
                return locationsArray[row]
            } else if (component == 1) {
                return String(quantitiesArray[row])
            }
        } else if (selectedRowIndex == 12) {
            return varietalsArray[row]
        } else if (selectedRowIndex == 13) {
            return countriesArray[row]
        } else if (selectedRowIndex == 14) {
            return regionsArray[row]
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (selectedRowIndex == 12) {
            txtVarietal.text = varietalsArray[row]
        } else if (selectedRowIndex == 13) {
            txtCountry.text = countriesArray[row]
        } else if (selectedRowIndex == 14) {
            txtRegion.text = regionsArray[row]
        } else if (selectedRowIndex == 21) {
            var loc = ""
            var quan = ""
            if (component == 0) {
                loc = locationsArray[row]
            } else if (component == 1) {
                quan = String(quantitiesArray[row])
            }
            txtLocation.text = loc + ":" + quan
        }
    }


}

