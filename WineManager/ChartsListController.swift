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
    
    let sections : [String] = ["Monthly Comparisons", "Cumulative Totals", "Varietals", "Countries"]
    let rowsMonthly : [String] = ["Purchased value", "Purchased bottles", "Drunk value", "Drunk bottles", "Added value", "Added bottles"]
    let rowsCumulative : [String] = ["Total value", "Total bottles", "Average bottle cost"]
    let rowsVarietals : [String] = ["Purchased by varietal", "Drunk by varietal", "Available by varietal"]
    let rowsCountries : [String] = ["Purchased by country", "Drunk by country", "Available by country"]
    
    
    var selectedRow: Int? = nil
    var selectedSection: Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    

    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let row = selectedRow {
            if segue.identifier == "showPieCharts" {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! PieChartsViewController
                if (selectedSection == 2) {
                    if (row == 0) {
                        controller.statType = StatsType.VarietalsPurchased
                    } else if (row == 1) {
                        controller.statType = StatsType.VarietalsDrunk
                    } else if (row == 2) {
                        controller.statType = StatsType.VarietalsAvailable
                    }
                } else if (selectedSection == 3) {
                    if (row == 0) {
                        controller.statType = StatsType.CountriesPurchased
                    } else if (row == 1) {
                        controller.statType = StatsType.CountriesDrunk
                    } else if (row == 2) {
                        controller.statType = StatsType.CountriesAvailable
                    }
                }
            }
            if segue.identifier == "showBarCharts" {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! BarChartsViewController
                if (row == 0) {
                    controller.statType = StatsType.MonthlyPurchasedCost
                } else if (row == 1) {
                    controller.statType = StatsType.MonthlyPurchasedBottles
                } else if (row == 2) {
                        controller.statType = StatsType.MonthlyDrunkCost
                } else if (row == 3) {
                    controller.statType = StatsType.MonthlyDrunkBottles
                } else if (row == 4) {
                    controller.statType = StatsType.MonthlyAvailableCost
                } else if (row == 5) {
                    controller.statType = StatsType.MonthlyAvailableBottles
                }
            }
            if segue.identifier == "showLineCharts" {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! LineChartsViewController
                if (row == 0) {
                    controller.statType = StatsType.CumulativeCost
                } else if (row == 1) {
                    controller.statType = StatsType.CumulativeBottles
                } else if (row == 2) {
                    controller.statType = StatsType.CumulativeAverage
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
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return rowsMonthly.count
        case 1:
            return rowsCumulative.count
        case 2:
            return rowsVarietals.count
        case 3:
            return rowsCountries.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            performSegueWithIdentifier("showBarCharts", sender: self)
        case 1:
            performSegueWithIdentifier("showLineCharts", sender: self)
        case 2:
            performSegueWithIdentifier("showPieCharts", sender: self)
        case 3:
            performSegueWithIdentifier("showPieCharts", sender: self)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        self.selectedRow = indexPath.row
        self.selectedSection = indexPath.section
        return indexPath
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellCharts", forIndexPath: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = rowsMonthly[indexPath.row]
        case 1:
            cell.textLabel?.text = rowsCumulative[indexPath.row]
        case 2:
            cell.textLabel?.text = rowsVarietals[indexPath.row]
        case 3:
            cell.textLabel?.text = rowsCountries[indexPath.row]
        default:
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    

}
