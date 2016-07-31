//
//  StatsViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 6/5/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import CoreData

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy/MM/dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
}

class StatsViewController: UITableViewController {
    var fetchPredicate: NSPredicate? = nil
    var showFilteredStats = false
    let keys : [String] = ["Inventory Cost", "Number of bottles", "Average bottle price", "Max bottle price", "Min bottle price", "Average points", "Max points", "Min points"]
    var valsAvailable = [String]()
    var valsDrunk = [String]()
    var valsTotal = [String]()
    var valsFilter = [String]()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateStats("Available", valsArray: &valsAvailable)
        calculateStats("Drunk", valsArray: &valsDrunk)
        calculateStats("Total", valsArray: &valsTotal)
        if (showFilteredStats) {
            calculateStats("Filter", valsArray: &valsFilter)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func calculateStats(statsMode: String, inout valsArray: [String]) {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("Wine", inManagedObjectContext:  appDelegate.managedObjectContext)
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
            let result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
            if (result.count > 0) {
                for (_, value) in result.enumerate() {
                    let bottle = value as! Wine
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
            }
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        valsArray.append("$" + String(cost))
        valsArray.append(String(quantity))
        valsArray.append("$" + formatter.stringFromNumber(avgCost)!)
        valsArray.append("$" + String(maxCost))
        valsArray.append("$" + String(minCost))
        valsArray.append(formatter.stringFromNumber(avgPoints)! + " pts")
        valsArray.append(String(maxPoints) + " pts")
        valsArray.append(String(minPoints) + " pts")
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
        return keys.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellStats", forIndexPath: indexPath)
        cell.textLabel?.text = keys[indexPath.row]
        
        switch indexPath.section {
        case 0:
            cell.detailTextLabel?.text = valsAvailable[indexPath.row]
        case 1:
            cell.detailTextLabel?.text = valsDrunk[indexPath.row]
        case 2:
            cell.detailTextLabel?.text = valsTotal[indexPath.row]
        case 3:
            cell.detailTextLabel?.text = valsFilter[indexPath.row]
        default:
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Available Bottles"
        case 1:
            return "Drunk Bottles"
        case 2:
            return "Total Bottles"
        case 3:
            return "Filtered Bottles"
        default:
            return "Unknown"
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
}
