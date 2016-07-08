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
    var showFilteredStats = false
    let keys : [String] = ["Inventory Cost", "Number of bottles", "Average bottle price", "Max bottle price", "Min bottle price", "Average points", "Max points", "Min points"]
    var valsAvailable = [String]()
    var valsDrunk = [String]()
    var valsTotal = [String]()
    var valsFilter = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        calculateStats("Available")
        calculateStats("Drunk")
        calculateStats("Total")
        if (showFilteredStats) {
            calculateStats("Filter")
        }
        
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
        
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        
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
        if (statsMode == "Available") {
            valsAvailable.append("$" + String(cost))
            valsAvailable.append(String(quantity))
            valsAvailable.append("$" + formatter.stringFromNumber(avgCost)!)
            valsAvailable.append("$" + String(maxCost))
            valsAvailable.append("$" + String(minCost))
            valsAvailable.append(formatter.stringFromNumber(avgPoints)! + " pts")
            valsAvailable.append(String(maxPoints) + " pts")
            valsAvailable.append(String(minPoints) + " pts")
        } else if (statsMode == "Drunk") {
            valsDrunk.append("$" + String(cost))
            valsDrunk.append(String(quantity))
            valsDrunk.append("$" + formatter.stringFromNumber(avgCost)!)
            valsDrunk.append("$" + String(maxCost))
            valsDrunk.append("$" + String(minCost))
            valsDrunk.append(formatter.stringFromNumber(avgPoints)! + " pts")
            valsDrunk.append(String(maxPoints) + " pts")
            valsDrunk.append(String(minPoints) + " pts")
        } else if (statsMode == "Total") {
            valsTotal.append("$" + String(cost))
            valsTotal.append(String(quantity))
            valsTotal.append("$" + formatter.stringFromNumber(avgCost)!)
            valsTotal.append("$" + String(maxCost))
            valsTotal.append("$" + String(minCost))
            valsTotal.append(formatter.stringFromNumber(avgPoints)! + " pts")
            valsTotal.append(String(maxPoints) + " pts")
            valsTotal.append(String(minPoints) + " pts")
        } else if (statsMode == "Filter") {
            valsFilter.append("$" + String(cost))
            valsFilter.append(String(quantity))
            valsFilter.append("$" + formatter.stringFromNumber(avgCost)!)
            valsFilter.append("$" + String(maxCost))
            valsFilter.append("$" + String(minCost))
            valsFilter.append(formatter.stringFromNumber(avgPoints)! + " pts")
            valsFilter.append(String(maxPoints) + " pts")
            valsFilter.append(String(minPoints) + " pts")
        }
    }
    
    
    
    // MARK: - Table View
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = CGFloat(35.0)
        return height
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (showFilteredStats) {
            return 4
        } else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section]
        //return sectionInfo.numberOfObjects
        return 8
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellStats", forIndexPath: indexPath)
        cell.textLabel?.text = keys[indexPath.row]
        if (indexPath.section == 0) {
            cell.detailTextLabel?.text = valsAvailable[indexPath.row]
        } else if (indexPath.section == 1) {
            cell.detailTextLabel?.text = valsDrunk[indexPath.row]
        } else if (indexPath.section == 2) {
            cell.detailTextLabel?.text = valsTotal[indexPath.row]
        } else if (indexPath.section == 3) {
            cell.detailTextLabel?.text = valsFilter[indexPath.row]
        }
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
