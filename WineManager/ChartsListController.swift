//
//  ChartsListController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 7/21/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import CoreData

class ChartsListController: UITableViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let keys : [String] = ["Purchased Value by Month", "Purchased Bottles by Month", "Average Value by Month", "Drunk Value by Month", "Drunk Bottles by Month", "Available Value by Month", "Available Bottles by Month"]
    
    var selectedRow = -1
    var monthlyPurchaseStats = [String: MonthlyStats]()
    var monthlyDrunkStats = [String: MonthlyStats]()
    var monthlyTotalStats = [String: MonthlyStats]()
    var monthlyAvailableStats = [String: MonthlyStats]()
    var monthlyCumulativeDrunkStats = [String: MonthlyStats]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        calculateMonthlyPurchasedStats()
    }
    
    func calculateMonthlyPurchasedStats() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM"
        var date = NSDate(dateString: "2013/01/01")
        var monthlyStat = MonthlyStats()
        var monthlyTotalStat = MonthlyStats()
        
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("PurchaseLot", inManagedObjectContext:  appDelegate.managedObjectContext)
        fetchRequest.entity = entityDescription
        while (date.compare(NSDate()) == .OrderedAscending) {
            monthlyStat.resetValues()
            monthlyTotalStat.resetValues()
            fetchRequest.predicate = predicateForMonth(date, type: "purchaseDate")
            do {
                let result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
                if (result.count > 0) {
                    for (_, value) in result.enumerate() {
                        let lot = value as! PurchaseLot
                        monthlyStat.totalCost += lot.price!.doubleValue * lot.quantity!.doubleValue
                        monthlyStat.quantity += lot.quantity!.integerValue
                    }
                    monthlyStat.avgCost = monthlyStat.totalCost / Double(monthlyStat.quantity)
                }
                monthlyPurchaseStats[dateFormatter.stringFromDate(date)] = monthlyStat
            }
            catch {
                abort()
            }
            date = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: 1, toDate: date, options: [])!
        }
        let sortedKeys = Array(monthlyPurchaseStats.keys).sort(<)
        for (index, key) in sortedKeys.enumerate() {
            if (index == 0) {
                monthlyTotalStats[key] = monthlyPurchaseStats[key]
            } else {
                monthlyTotalStat.totalCost = (monthlyTotalStats[sortedKeys[index-1]]?.totalCost)! + (monthlyPurchaseStats[key]?.totalCost)!
                monthlyTotalStat.quantity = (monthlyTotalStats[sortedKeys[index-1]]?.quantity)! + (monthlyPurchaseStats[key]?.quantity)!
                monthlyTotalStat.avgCost = monthlyTotalStat.totalCost / Double(monthlyTotalStat.quantity)
                monthlyTotalStats[key] = monthlyTotalStat
            }
            
            print (key, monthlyPurchaseStats[key]?.totalCost)
            print (key, monthlyTotalStats[key]?.totalCost)
        }
    }
    
    func predicateForMonth(date: NSDate, type: String) -> NSPredicate {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let components = calendar!.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: date)
        components.day = 1
        components.hour = 00
        components.minute = 00
        components.second = 00
        let startDate = calendar!.dateFromComponents(components)
        
        let dayRange = calendar!.rangeOfUnit(.Day, inUnit: .Month, forDate: date)
        let numberOfDaysInCurrentMonth = dayRange.length
        components.day = numberOfDaysInCurrentMonth
        components.hour = 23
        components.minute = 59
        components.second = 59
        let endDate = calendar!.dateFromComponents(components)
        return NSPredicate(format: type + " >= %@ AND " + type + " =< %@", argumentArray: [startDate!, endDate!])
    }


    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBarChartView" {
            if (selectedRow >= 0 && selectedRow < 5) {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! BarChartsViewController
                if (selectedRow == 0) {
                    controller.monthlyPurchaseStats = self.monthlyPurchaseStats
                    controller.chartType = "TotalCost"
                } else if (selectedRow == 1) {
                    controller.monthlyPurchaseStats = self.monthlyPurchaseStats
                    controller.chartType = "TotalBottles"
                } else if (selectedRow == 2) {
                    controller.monthlyPurchaseStats = self.monthlyPurchaseStats
                    controller.chartType = "AvgCost"
                }
            }
        }
    }

    
    
    // MARK: - Table View
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = CGFloat(35.0)
        return height
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedRow = indexPath.row
        return indexPath
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellCharts", forIndexPath: indexPath)
        cell.textLabel?.text = keys[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    

}
