//
//  AddEditViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 6/27/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import CoreData

protocol EditLocationsViewControllerDelegate
{
    func applyLocationChanges(dataChanged: Bool)
}


class AddEditViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate, SaveALotViewControllerDelegate {

    var delegate : EditLocationsViewControllerDelegate?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let keyWindow = UIApplication.sharedApplication().keyWindow
    
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
    
    var selectedLotIndex = -1
    var selectedRowIndex = 0
    var viewMode = "Add"
    var bottleInfo: AnyObject?
    
    let pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    let dateFormatter = NSDateFormatter()
    
    var allLots: [SimpleLot] = []
    var varietalsArray: [String] = []
    var countriesArray: [String] = []
    var regionsArray: [String] = []
    
    
    @IBAction func onSave(sender: AnyObject) {
        if (viewMode == "Edit") {
            saveExistingBottle()
        } else if (viewMode == "Add") {
            saveNewBottle()
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
        
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.autocapitalizationType = .Words
        })
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
        
        getDistinctVarietalsCountriesRegions()
        
        datePicker.datePickerMode = .Date
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        pickerView.delegate = self
        txtVarietal.inputView = pickerView
        txtVarietal.delegate = self
        txtCountry.inputView = pickerView
        txtCountry.delegate = self
        txtRegion.inputView = pickerView
        txtRegion.delegate = self
        txtReview.textColor = UIColor.lightGrayColor()
        txtReview.delegate = self
        
        if (viewMode == "Edit") {
            configureView()
        }
    }
 
    func configureView() {
       if let bottle = self.bottleInfo {
            let bottleDetails = bottle as! Bottle            
            let sorter = NSSortDescriptor(key: "purchaseDate", ascending: false)
            let sorted = bottleDetails.lots!.sortedArrayUsingDescriptors([sorter])
            for (_, value) in sorted.enumerate() {
                let lot = value as! PurchaseLot
                var newLot = SimpleLot()
                newLot.bottlePrice = lot.price!.floatValue
                newLot.purchaseDate = lot.purchaseDate!
                newLot.totalBottles = (lot.quantity!.integerValue)
                
                for (_, value) in lot.statuses!.enumerate() {
                    let loc = value as! Status
                    if (loc.available == 1) {
                        if (newLot.locations.indexForKey(loc.location!) != nil) {
                            newLot.locations[loc.location!] = newLot.locations[loc.location!]! + 1
                        } else {
                            newLot.locations[loc.location!] = 1
                        }
                    }
                }
            saveALot(newLot)
            }
        }
    }
    
    func saveExistingBottle() {
        var oldLot: PurchaseLot
        let oldBottle = self.bottleInfo as! Bottle
        oldBottle.availableBottles = 0
        for lot in allLots {
            let datePredicate = predicateForDayFromDate(lot.purchaseDate)
            let matchingLots = oldBottle.lots?.filteredOrderedSetUsingPredicate(datePredicate)
            if (matchingLots?.count > 0) {  // We are editing an existing lot so remove all available entries
                oldLot = matchingLots?.firstObject as! PurchaseLot
                oldLot.availableBottles = 0
                for tempValue in oldLot.statuses! {
                    let status = tempValue as! Status
                    if (status.available == 1) {
                        appDelegate.managedObjectContext.deleteObject(status)
                    }
                }
            } else {    // User added a new lot to an existing bottle
                oldLot = NSEntityDescription.insertNewObjectForEntityForName("PurchaseLot", inManagedObjectContext: appDelegate.managedObjectContext) as! PurchaseLot
                oldLot.bottle = oldBottle
                oldLot.purchaseDate = lot.purchaseDate
                if (oldLot.purchaseDate!.compare(oldBottle.lastPurchaseDate!) == NSComparisonResult.OrderedDescending) {
                    oldBottle.lastPurchaseDate = oldLot.purchaseDate
                }
                oldLot.price = NSDecimalNumber(float: lot.bottlePrice)
                if (oldLot.price!.compare(oldBottle.maxPrice!) == NSComparisonResult.OrderedDescending) {
                    oldBottle.maxPrice = oldLot.price
                }
                oldLot.quantity = lot.totalBottles
            }
            
            for (loc, count) in lot.locations {
                var loopIndex = 0
                while (loopIndex < count) {
                    let newLoc = NSEntityDescription.insertNewObjectForEntityForName("Status", inManagedObjectContext: appDelegate.managedObjectContext) as! Status
                    newLoc.lot = oldLot
                    newLoc.available = 1
                    oldLot.availableBottles = (oldLot.availableBottles?.integerValue)! + 1
                    newLoc.location = loc
                    loopIndex += 1
                }
            }
            oldBottle.availableBottles = (oldBottle.availableBottles?.integerValue)! + (oldLot.availableBottles?.integerValue)!
        }
        saveContext()
    }
    
    func doChecksFail() -> Bool {
        let retVal = true
        if ((txtName.text!).isEmpty) {
            keyWindow!.makeToast(message: "Must provide a name", duration: 2.0, position: HRToastPositionCenter)
            return retVal
        }
        if ((txtVarietal.text!).isEmpty) {
            keyWindow!.makeToast(message: "Must provide a varietal", duration: 2.0, position: HRToastPositionCenter)
            return retVal
        }
        if ((txtRegion.text!).isEmpty) {
            keyWindow!.makeToast(message: "Must provide a region", duration: 2.0, position: HRToastPositionCenter)
            return retVal
        }
        if ((txtCountry.text!).isEmpty) {
            keyWindow!.makeToast(message: "Must provide a country", duration: 2.0, position: HRToastPositionCenter)
            return retVal
        }
        if (allLots.count == 0) {
            keyWindow?.makeToast(message: "Must provide atleast 1 lot", duration: 2.0, position: HRToastPositionCenter)
            return retVal
        }
        
        var vintage = ""
        if let myNumber = NSNumberFormatter().numberFromString(txtVintage.text!) {
            vintage = myNumber.stringValue
        } else {
            vintage = "0"
        }
        let fetchRequest = NSFetchRequest(entityName: "Bottle")
        let predicateName = NSPredicate(format: "name == %@", txtName.text!)
        let predicateVintage = NSPredicate(format: "vintage == %@", vintage)
        let predicateCompound = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateName, predicateVintage])
        fetchRequest.predicate = predicateCompound
        do {
            let fetchedEntities = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest) as! [Bottle]
            if (fetchedEntities.count > 0) {
                keyWindow?.makeToast(message: "Duplicate entry", duration: 2.0, position: HRToastPositionCenter)
                return retVal
            }
        }
        catch {
            abort()
        }

        return false
    }
    
    func saveNewBottle() {
        if (doChecksFail()) {
            return
        }
        
        let newBottle = NSEntityDescription.insertNewObjectForEntityForName("Bottle", inManagedObjectContext: appDelegate.managedObjectContext) as! Bottle
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
            let newLot = NSEntityDescription.insertNewObjectForEntityForName("PurchaseLot", inManagedObjectContext: appDelegate.managedObjectContext) as! PurchaseLot
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
                    let newLoc = NSEntityDescription.insertNewObjectForEntityForName("Status", inManagedObjectContext: appDelegate.managedObjectContext) as! Status
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
        saveContext()
    }
    
    func predicateForDayFromDate(date: NSDate) -> NSPredicate {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = calendar!.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar!.dateFromComponents(components)
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar!.dateFromComponents(components)
        return NSPredicate(format: "purchaseDate >= %@ AND purchaseDate =< %@", argumentArray: [startDate!, endDate!])
    }

    
    func datePickerValueChanged(sender:UIDatePicker) {
        txtPurchaseDate.text = dateFormatter.stringFromDate(sender.date)
    }
    
    
    func getDistinctVarietalsCountriesRegions() {
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Bottle")
        fetchRequest.propertiesToFetch = ["varietal", "country", "region"]
        fetchRequest.resultType = NSFetchRequestResultType.DictionaryResultType
        fetchRequest.returnsDistinctResults = true
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
            varietalsArray = varietalsArray.removeDuplicates()
            varietalsArray.sortInPlace()
            countriesArray = countriesArray.removeDuplicates()
            countriesArray.sortInPlace()
            regionsArray = regionsArray.removeDuplicates()
            regionsArray.sortInPlace()
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
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            if (selectedLotIndex >= 0 && selectedLotIndex < allLots.count) {
                controller.lotInfo = allLots[selectedLotIndex]
                controller.viewMode = "Edit"
            }
        }
    }
    
    func saveLot(lot: SimpleLot) {
        if !(selectedLotIndex >= 0 && selectedLotIndex < allLots.count) {
            let oldBottle = self.bottleInfo as! Bottle
            let datePredicate = predicateForDayFromDate(lot.purchaseDate)
            let matchingLots = oldBottle.lots?.filteredOrderedSetUsingPredicate(datePredicate)
            if (matchingLots?.count > 0) {  // We already have a lot from this date. Do not save
                keyWindow!.makeToast(message: "A lot from this date already exists", duration: 2.0, position: HRToastPositionCenter)
                return
            }
        }
        saveALot(lot)
        keyWindow!.makeToast(message: "Saved", duration: 2.0, position: HRToastPositionCenter)
    }
    
    func saveALot(lot: SimpleLot) {
        if (selectedLotIndex >= 0 && selectedLotIndex < allLots.count) {
            allLots[selectedLotIndex] = lot
        } else {
            allLots.append(lot)
        }
        self.tableView.reloadData()
    }
    
    func saveContext() {
        do {
            try appDelegate.managedObjectContext.save()
            keyWindow!.makeToast(message: "Saved", duration: 2.0, position: HRToastPositionCenter)
            if((self.delegate) != nil)
            {
                delegate?.applyLocationChanges(true)
            }
        } catch {
            abort()
        }
    }

    
    // MARK: - Table View
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1) {
            selectedLotIndex = indexPath.row
            performSegueWithIdentifier("showAddLot", sender: nil)
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (indexPath.section == 1) {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0 && viewMode == "Add") {
            return 6
        } else if (section == 1) {
            return allLots.count + 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if (indexPath.section == 0) {
            return cell
        }
        if (indexPath.row < allLots.count) {
            cell.textLabel?.text = getCellTitleForRowIndex(indexPath.row) // lotEntities[indexPath.row]
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.accessoryType = .DisclosureIndicator
        } else {
            cell.textLabel?.text = "Add a lot"
            cell.textLabel?.textColor = UIColor.lightGrayColor()
            cell.accessoryType = .DisclosureIndicator
        }
        return cell
    }
    
    func getCellTitleForRowIndex(row: Int) -> String {
        if (row >= allLots.count) {
            return "Out of bounds"
        }
        let lot = allLots[row]
        if (lot.totalBottles > 1) {
            return String(lot.totalBottles) + " bottles for $" + String(lot.bottlePrice) + " each on " + dateFormatter.stringFromDate(lot.purchaseDate)
        } else {
            return String(lot.totalBottles) + " bottle for $" + String(lot.bottlePrice) + " on " + dateFormatter.stringFromDate(lot.purchaseDate)
        }
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
        if (selectedRowIndex == 12) {
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
        if (selectedRowIndex == 12) {
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
        }
    }


}

