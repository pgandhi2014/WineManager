//
//  MasterViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 5/29/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
}

extension Array {
    func split() -> (left: [Element], right: [Element]) {
        let ct = self.count
        let half = ct / 2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< ct]
        return (left: Array(leftSplit), right: Array(rightSplit))
    }
}

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, NSXMLParserDelegate, UISearchBarDelegate, SavingFilterViewControllerDelegate, DetailViewControllerDelegate, UploadPendingDelegate {

    @IBOutlet weak var syncCloudButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filtersButton: UIBarButtonItem!
    @IBOutlet weak var statsButton: UIBarButtonItem!
    @IBOutlet weak var clearFiltersButton: UIBarButtonItem!
    
    var overlayView = UIView()
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var availableFilter = NSPredicate(format: "availableBottles > 0")
    var defaultFilter = NSPredicate(value: true)
    let defaultSorter = NSSortDescriptor(key: "maxPrice", ascending: false)
    
    var sorter = NSSortDescriptor()
    var searchFilter = NSPredicate()    //Filter for the searchbar
    var viewFilter = NSPredicate()      //Filter for the filtersview
    var filtersApplied = false
    var searchApplied = false
    var fetchRequest = NSFetchRequest()
    
    let container = CKContainer.defaultContainer()
    var privateDatabase : CKDatabase? = nil
    
    let dateFormatter = NSDateFormatter()
    var xmlHelper: XMLHelper? = nil
    var cloudHelper = CloudHelper.sharedInstance
    
    @IBAction func onClearFilters(sender: UIBarButtonItem) {
        filtersApplied = false
        clearFiltersButton.enabled = false
        viewFilter = availableFilter
        sorter = defaultSorter
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [viewFilter, searchFilter])
        fetchRequest.sortDescriptors = [sorter]
        performFetchAndRefresh()
    }
    
    @IBAction func onSyncCloud(sender: AnyObject) {
        showAlert("Sync with iCloud", message: "Would you like to sync with iCloud now?")
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil));
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {(action:UIAlertAction) in
            print("Record to upload: " + String(self.cloudHelper.numberOfRecordsToUpload()))
            self.cloudHelper.uploadRecords()
        }))
        presentViewController(alert, animated: true, completion: nil);
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
        cloudHelper.delegate = self
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        privateDatabase = container.privateCloudDatabase
        
        let bottles = self.fetchedResultsController.sections![0].numberOfObjects
        self.title = "Wine Manager (" + String(bottles) + ")"
        
        searchBar.delegate = self
        
        if (splitViewController?.displayMode == .AllVisible) {
            setupFirstView()
        }
        
        xmlHelper = XMLHelper(moc: self.managedObjectContext!)
        parseXML()
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
    
    func parseXML() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
            self.xmlHelper!.startParsing()
            dispatch_async(dispatch_get_main_queue()) {
                self.performFetchAndRefresh()
            }
        })
    }
    
    func setupFirstView() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        if self.fetchedResultsController.fetchedObjects?.count == 0 {
            return
        }
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
        self.detailViewController?.detailItem = object
        self.detailViewController?.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
        self.detailViewController?.navigationItem.leftItemsSupplementBackButton = true
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

    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
            let object = self.fetchedResultsController.objectAtIndexPath(indexPath)
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.delegate = self
            }
        }
        if segue.identifier == "showStats" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! StatsViewController
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
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
            controller.title = "Add a new bottle"
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
    
    func BottleDetailsDidChange(dataChanged: Bool) {
        if dataChanged {
            self.tableView.reloadData()
        }
    }
    
    func uploadPendingWithCount(count: Int) {
        if (count > 0) {
            syncCloudButton.enabled = true
        } else {
            syncCloudButton.enabled = false
        }
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
            saveContext()
        }
    }

    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        let customCell = cell as! CustomPrototypeCell
        let currentBottle = object as! Wine
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
        
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Wine", inManagedObjectContext: self.managedObjectContext!)
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
    
    func saveContext() {
        do {
            try self.managedObjectContext!.save()
        } catch {
            abort()
        }
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         self.tableView.reloadData()
     }
     */

}

 
 
 


