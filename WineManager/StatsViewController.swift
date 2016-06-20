//
//  StatsViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 6/5/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import CoreData

class StatsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext? = nil
    var fetchPredicate: NSPredicate? = nil
    
    var statsAvailable = [String: String]()
    var statsDrunk = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        calculateStats("Filter")
        calculateStats("Available")
        calculateStats("Drunk")
        calculateStats("Total")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func calculateStats(statsMode: String) {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Bottle", inManagedObjectContext:  self.managedObjectContext!)
        fetchRequest.entity = entityDescription
        if (statsMode == "Available") {
            fetchRequest.predicate = NSPredicate(format: "availableBottles > 0")
        } else if (statsMode == "Drunk") {
            fetchRequest.predicate = NSPredicate(format: "drunkBottles > 0")
        } else if (statsMode == "Filter") {
            fetchRequest.predicate = self.fetchPredicate
        }

        var quantity = 0
        var cost = 0.0
        var minCost = 1000000.0
        var maxCost = 0.0
        var avgCost = 0.0
        var minPoints = 100
        var maxPoints = 0
        var avgPoints = 0.0
        var points = 0.0
        
        NSFetchedResultsController.deleteCacheWithName(nil)
        do {
            let result = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
            if (result.count > 0) {
                for (_, value) in result.enumerate() {
                    let bottle = value as! Bottle
                    if (bottle.points!.integerValue < minPoints) {
                        minPoints = bottle.points!.integerValue
                    }
                    if (bottle.points!.integerValue > maxPoints) {
                        maxPoints = bottle.points!.integerValue
                    }
                    for (_, value) in bottle.lots!.enumerate() {
                        let lot = value as! PurchaseLot
                        if (lot.price!.doubleValue < minCost) {
                            minCost = lot.price!.doubleValue
                        }
                        if (lot.price!.doubleValue > maxCost) {
                            maxCost = lot.price!.doubleValue
                        }
                        var bottles = 0.0
                        if (statsMode == "Available") {
                            bottles = lot.availableBottles!.doubleValue
                        } else if (statsMode == "Drunk") {
                            bottles = lot.drunkBottles!.doubleValue
                        } else if (statsMode == "Total" || statsMode == "Filter") {
                            bottles = lot.quantity!.doubleValue
                        }
                        cost = cost + (lot.price!.doubleValue * bottles)
                        quantity = quantity + Int(bottles)
                        points = points + (bottle.points!.doubleValue * bottles)
                    }
                }
                avgCost = cost / Double(quantity)
                avgPoints = points / Double(quantity)
                NSLog("Done")
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

        
    }
    
    
    
    // MARK: - Table View
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = CGFloat(35.0)
        return height
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //return self.fetchedResultsController.sections?.count ?? 0
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section]
        //return sectionInfo.numberOfObjects
        return 7
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellStats", forIndexPath: indexPath)
        //self.configureCell(cell, withObject: nil)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Available Bottles"
        } else if (section == 1) {
            return "Drunk Bottles"
        } else if (section == 2) {
            return "Total Bottles"
        } else if (section == 3) {
            return "Filtered Bottles"
        } else {
            return "Unknown"
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    //func configureCell(cell: UITableViewCell, withObject object: NSManagedObject) {
        
    //}

}
