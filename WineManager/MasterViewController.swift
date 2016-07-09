//
//  MasterViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 5/29/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, NSXMLParserDelegate, UISearchBarDelegate, SavingFilterViewControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filtersButton: UIBarButtonItem!
    @IBOutlet weak var statsButton: UIBarButtonItem!
    @IBOutlet weak var clearFiltersButton: UIBarButtonItem!
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var availableFilter = NSPredicate(format: "availableBottles > 0")
    var defaultFilter = NSPredicate(value: true)
    let defaultSorter = NSSortDescriptor(key: "maxPrice", ascending: false)
    
    var collapseDetailsView = true
    
    var sorter = NSSortDescriptor()
    var searchFilter = NSPredicate()    //Filter for the searchbar
    var viewFilter = NSPredicate()      //Filter for the filtersview
    var filtersApplied = false
    var searchApplied = false
    
    var parser = NSXMLParser()
    var bottles = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var name = String()
    var vintage = String()
    var parsedBottle = ParsedWineBottle()
    var parsedLot = ParsedLot(purchaseDate: "", price: "", quantity: "", locations: [ParsedLoc]())
    var parsedLoc = ParsedLoc(status: "", location: "", drunkDate: "", rating: "", notes: "")
    var fetchRequest = NSFetchRequest()
    
    let dateFormatter = NSDateFormatter()
    
    @IBAction func onClearFilters(sender: UIBarButtonItem) {
        filtersApplied = false
        clearFiltersButton.enabled = false
        viewFilter = availableFilter
        sorter = defaultSorter
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [viewFilter, searchFilter])
        fetchRequest.sortDescriptors = [sorter]
        performFetchAndRefresh()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
        //splitViewController?.delegate = self
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        clearFiltersButton.enabled = false
        sorter = defaultSorter
        searchFilter = defaultFilter
        viewFilter = availableFilter
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let path = NSBundle.mainBundle().pathForResource("NewWineList", ofType: "xml")
        if path != nil {
            parser = NSXMLParser(contentsOfURL: NSURL(fileURLWithPath: path!))!
        } else {
            NSLog("Failed to find xml")
        }
        let bottles = self.fetchedResultsController.sections![0].numberOfObjects
        self.title = "Wine Manager (" + String(bottles) + ")"
        
        searchBar.delegate = self
        parser.delegate = self
        //parser.parse()
        
        if (splitViewController?.displayMode == .AllVisible) {
            setupDefaultView()
        }
        
    }
    
    func setupDefaultView() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        let bottle = object as! Bottle
        self.detailViewController?.detailItem = object
        self.detailViewController?.bottleName = bottle.name!
        self.detailViewController?.bottleVintage = (bottle.vintage?.integerValue)!
        self.detailViewController?.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        self.detailViewController?.navigationItem.leftItemsSupplementBackButton = true
        self.detailViewController?.managedObjectContext = self.managedObjectContext
    }
    
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        (self.parentViewController as! UINavigationController).setToolbarHidden(false, animated: true)
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewBottle() {
        let newBottle = NSEntityDescription.insertNewObjectForEntityForName("Bottle", inManagedObjectContext: self.managedObjectContext!) as! Bottle
        
        newBottle.name = parsedBottle.name
        if let myNumber = NSNumberFormatter().numberFromString(parsedBottle.vintage) {
            newBottle.vintage = myNumber
        }
        newBottle.varietal = parsedBottle.varietal
        newBottle.region = parsedBottle.region
        newBottle.country = parsedBottle.country
        
        newBottle.reviewSource = parsedBottle.reviewSource
        if let myNumber = NSNumberFormatter().numberFromString(parsedBottle.points) {
            newBottle.points = myNumber
        }
        newBottle.review = parsedBottle.review
        
        for (_, value) in parsedBottle.purchaseLots.enumerate() {
            let newLot = NSEntityDescription.insertNewObjectForEntityForName("PurchaseLot", inManagedObjectContext: self.managedObjectContext!) as! PurchaseLot
            let lot = value as! ParsedLot
            newLot.bottle = newBottle
            newLot.purchaseDate = self.dateFormatter.dateFromString(lot.purchaseDate)
            if (newLot.purchaseDate!.compare(newBottle.lastPurchaseDate!) == NSComparisonResult.OrderedDescending) {
                newBottle.lastPurchaseDate = newLot.purchaseDate
            }
            if let myNumber = NSNumberFormatter().numberFromString(lot.price) {
                newLot.price = NSDecimalNumber(decimal: myNumber.decimalValue)
                if (newLot.price!.compare(newBottle.maxPrice!) == NSComparisonResult.OrderedDescending) {
                    newBottle.maxPrice = newLot.price
                }
            }
            if let myNumber = NSNumberFormatter().numberFromString(lot.quantity) {
                newLot.quantity = myNumber
            }
        
            for (_, value) in lot.locations.enumerate() {
                let newLoc = NSEntityDescription.insertNewObjectForEntityForName("Status", inManagedObjectContext: self.managedObjectContext!) as! Status
                let loc = value
                newLoc.lot = newLot
                if let myDate = self.dateFormatter.dateFromString(loc.drunkDate) {
                    newLoc.drunkDate = myDate
                    if (newLoc.drunkDate!.compare(newBottle.lastDrunkDate!) == NSComparisonResult.OrderedDescending) {
                        newBottle.lastDrunkDate = newLoc.drunkDate
                    }
                }
                if (loc.status == "Drunk") {
                    newLoc.available = 0
                    newLot.drunkBottles = (newLot.drunkBottles?.integerValue)! + 1
                } else {
                    newLoc.available = 1
                    newLot.availableBottles = (newLot.availableBottles?.integerValue)! + 1
                }
                newLoc.location = loc.location
                newLoc.notes = loc.notes
                if let myNumber = NSNumberFormatter().numberFromString(loc.rating) {
                    newLoc.rating = NSDecimalNumber(decimal: myNumber.decimalValue)
                }
            }
            newBottle.availableBottles = (newBottle.availableBottles?.integerValue)! + (newLot.availableBottles?.integerValue)!
            newBottle.drunkBottles = (newBottle.drunkBottles?.integerValue)! + (newLot.drunkBottles?.integerValue)!
        }
        
        // Save the context.
        do {
            try self.managedObjectContext!.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            abort()
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
    }
    
    func setPredicateAndFilterResults(searchText: String) {
        var subANDPredicates = [NSPredicate]()
        
        if (searchText.isEmpty) {
            searchFilter = defaultFilter
        } else {
            let searchWords = searchText.componentsSeparatedByString(" ")
            for(_,value) in searchWords.enumerate() {
                if (!value.isEmpty) {
                    var subORPredicates = [NSPredicate]()
                    let predicateName = NSPredicate(format: "name contains[cd] %@", value)
                    subORPredicates.append(predicateName)
                    let predicateVarietal = NSPredicate(format: "varietal contains[cd] %@", value)
                    subORPredicates.append(predicateVarietal)
                    let predicateRegion = NSPredicate(format: "region contains[cd] %@", value)
                    subORPredicates.append(predicateRegion)
                    let predicateCountry = NSPredicate(format: "country contains[cd] %@", value)
                    subORPredicates.append(predicateCountry)
                    let subOR = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: subORPredicates)
                    subANDPredicates.append(subOR)
                    subORPredicates.removeAll()
                }
            }
            searchFilter = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: subANDPredicates)
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [viewFilter, searchFilter])
        performFetchAndRefresh()
    }

    func performFetchAndRefresh() {
        NSFetchedResultsController.deleteCacheWithName(nil)
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        self.tableView.reloadData()
        let bottles = self.fetchedResultsController.sections![0].numberOfObjects
        self.title = "Wine Manager (" + String(bottles) + ")"
    }
    

    
    //MARK: - SearchBar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchApplied = true
        searchBar.showsCancelButton = true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        setPredicateAndFilterResults(searchText)
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchApplied = false
        searchBar.showsCancelButton = false
        searchBar.text = ""
        setPredicateAndFilterResults("")
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    
    // MARK: - Parser
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        element = elementName as String
        
        if elementName == "bottle" {
            parsedBottle.Erase()
        } else if elementName == "Lot" {
            parsedLot.Erase()
        } else if elementName == "Loc" {
            parsedLoc.Erase()
        }
        
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if element.isEqualToString("Name") {
            if (parsedBottle.name.isEmpty) {
                parsedBottle.name = parsedBottle.name + string
                NSLog (string)
            }
        } else if element.isEqualToString("Vintage") {
            if (parsedBottle.vintage.isEmpty) {
                parsedBottle.vintage = parsedBottle.vintage + string
            }
        } else if element.isEqualToString("Varietal") {
            if (parsedBottle.varietal.isEmpty) {
                parsedBottle.varietal = parsedBottle.varietal + string
            }
        } else if element.isEqualToString("Region") {
            if (parsedBottle.region.isEmpty) {
                parsedBottle.region = parsedBottle.region + string
            }
        } else if element.isEqualToString("Country") {
            if (parsedBottle.country.isEmpty) {
                parsedBottle.country = parsedBottle.country + string
            }
        } else if element.isEqualToString("ReviewSource") {
            if (parsedBottle.reviewSource.isEmpty) {
                parsedBottle.reviewSource = parsedBottle.reviewSource + string
            }
        } else if element.isEqualToString("Points") {
            if (parsedBottle.points.isEmpty) {
                parsedBottle.points = parsedBottle.points + string
            }
        } else if element.isEqualToString("Review") {
            if (parsedBottle.review.isEmpty) {
                parsedBottle.review = parsedBottle.review + string
            }
        } else if element.isEqualToString("PurchaseDate") {
            if (parsedLot.purchaseDate.isEmpty) {
                parsedLot.purchaseDate = parsedLot.purchaseDate + string
            }
        } else if element.isEqualToString("Price") {
            if (parsedLot.price.isEmpty) {
                parsedLot.price = parsedLot.price + string
            }
        } else if element.isEqualToString("Quantity") {
            if (parsedLot.quantity.isEmpty) {
                parsedLot.quantity = parsedLot.quantity + string
            }
        } else if element.isEqualToString("Status") {
            if (parsedLoc.status.isEmpty) {
                parsedLoc.status = parsedLoc.status + string
            }
        } else if element.isEqualToString("Location") {
            if (parsedLoc.location.isEmpty && !(string.containsString("\n") || string.isEmpty)) {
                parsedLoc.location = parsedLoc.location + string
                NSLog (string)
            }
        } else if element.isEqualToString("DrunkDate") {
            if (parsedLoc.drunkDate.isEmpty && !string.containsString("\n")) {
                parsedLoc.drunkDate = parsedLoc.drunkDate + string
            }
        } else if element.isEqualToString("Rating") {
            if (parsedLoc.rating.isEmpty && !string.containsString("\n")) {
                parsedLoc.rating = parsedLoc.rating + string
            }
        } else if element.isEqualToString("Notes") {
            if (parsedLoc.notes.isEmpty && !string.containsString("\n")) {
                parsedLoc.notes = parsedLoc.notes + string
            }
        }
        
    }
    
 func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName == "bottle") {
            insertNewBottle()
        } else if (elementName == "Lot") {
            parsedBottle.purchaseLots.addObject(parsedLot.copy())
        } else if (elementName == "Loc") {
            parsedLot.locations.append(parsedLoc.copy() as! ParsedLoc)
        }
        
    }
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let bottle = object as! Bottle
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.bottleName = bottle.name!
                controller.bottleVintage = (bottle.vintage?.integerValue)!
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.managedObjectContext = self.managedObjectContext
            }
        }
        if segue.identifier == "showStats" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! StatsViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.managedObjectContext = self.managedObjectContext
            controller.fetchPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [viewFilter, searchFilter])
            controller.showFilteredStats = searchApplied || filtersApplied
        }
        if segue.identifier == "showFilters" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! FiltersViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.delegate = self
        }
        if segue.identifier == "showAddWine" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! AddEditViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.managedObjectContext = self.managedObjectContext
        }
    }
    
    func applyFilters(filter: NSPredicate, sort: NSSortDescriptor) {
        filtersApplied = true
        clearFiltersButton.enabled = true
        viewFilter = filter
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [viewFilter, searchFilter])
        fetchRequest.sortDescriptors = [sort]
        
        self.navigationController?.popViewControllerAnimated(true)
        performFetchAndRefresh()
    }

    // MARK: - Table View

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = CGFloat(60.0)
        return height
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        self.configureCell(cell, withObject: object)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let context = self.fetchedResultsController.managedObjectContext
            context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject)
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //print("Unresolved error \(error), \(error.userInfo)")
                abort()
            }
        }
    }

    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        let customCell = cell as! CustomPrototypeCell
        let currentBottle = object as! Bottle
        let formatter = NSNumberFormatter()
        let pointsFormatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        pointsFormatter.maximumFractionDigits = 0
        pointsFormatter.minimumFractionDigits = 0
        
        if (currentBottle.vintage! == 0) {
            customCell.lblName.text = "NV " + currentBottle.name!
        } else {
            customCell.lblName.text = String(currentBottle.vintage!) + " " + currentBottle.name!
        }
        customCell.lblDetails.text = "$" + formatter.stringFromNumber(currentBottle.maxPrice!)! + "  " + currentBottle.varietal!
        customCell.lblRating.text = pointsFormatter.stringFromNumber(currentBottle.points!)!
        if (currentBottle.availableBottles?.integerValue == 0) {
            customCell.colorCell(UIColor.redColor())
        } else {
            customCell.colorCell(UIColor.blackColor())
        }        
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        //let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Bottle", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        fetchRequest.sortDescriptors = [sorter]
        fetchRequest.predicate = viewFilter
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        NSFetchedResultsController.deleteCacheWithName(nil)
        _fetchedResultsController = aFetchedResultsController

        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             //print("Unresolved error \(error), \(error.userInfo)")
             abort()
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController? = nil

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, withObject: anObject as! NSManagedObject)
            case .Move:
                tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

