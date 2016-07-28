//
//  StatsHelper.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 7/22/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import Foundation
import CoreData

enum StatsType {
    case MonthlyPurchasedCost, MonthlyPurchasedBottles, MonthlyDrunkCost, MonthlyDrunkBottles, MonthlyAvailableCost, MonthlyAvailableBottles
    case CumulativeCost, CumulativeBottles, CumulativeAverage
    case VarietalsPurchased, VarietalsDrunk, VarietalsAvailable
    case CountriesPurchased, CountriesDrunk, CountriesAvailable
}

struct MonthlyStats {
    var totalCost = 0.0
    var quantity = 0
    var avgCost = 0.0
    
    mutating func resetValues() {
        totalCost = 0.0
        avgCost = 0.0
        quantity = 0
    }
}

struct VarietalStats {
    var varietal = ""
    var totalCost = 0.0
    var quantity = 0
    var avgCost = 0.0
    
    mutating func resetValues() {
        varietal = ""
        totalCost = 0.0
        avgCost = 0.0
        quantity = 0
    }
}

class StatsHelper: NSObject {
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var monthlyPurchaseStats = [String: MonthlyStats]()
    var monthlyDrunkStats = [String: MonthlyStats]()
    var monthlyAvailableStats = [String: MonthlyStats]()
    var cumulativePurchasedStats = [String: MonthlyStats]()
    var cumulativeDrunkStats = [String: MonthlyStats]()
    var cumulativeAvailableStats = [String: MonthlyStats]()
    
    var varietalsAvailableStats = [String: VarietalStats]()
    var varietalsDrunkStats = [String: VarietalStats]()
    var varietalsPurchasedStats = [String: VarietalStats]()
    
    var countriesAvailableStats = [String: VarietalStats]()
    var countriesDrunkStats = [String: VarietalStats]()
    var countriesPurchasedStats = [String: VarietalStats]()

    var varietalsArray: [String] = []
    var countriesArray: [String] = []
    var regionsArray: [String] = []
    var locationsArray: [String] = []
    
    let dateFormatter = NSDateFormatter()
    
    init(moc: NSManagedObjectContext) {
        super.init()
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = moc.persistentStoreCoordinator
        dateFormatter.dateFormat = "yyyy/MM"
        
    }
    
    func getMonthlyPurchasedStats() -> [String: MonthlyStats] {
        if (monthlyPurchaseStats.count == 0) {
            calculatePurchasedStats()
        }
        return monthlyPurchaseStats
    }
    
    func getCumulativePurchasedStats() -> [String: MonthlyStats] {
        if (cumulativePurchasedStats.count == 0) {
            if (monthlyPurchaseStats.count == 0) {
                calculatePurchasedStats()
            }
            cumulativePurchasedStats = calculateCumulativeStats(monthlyPurchaseStats)
        }
        return cumulativePurchasedStats
    }
    
    func getMonthlyDrunkStats() -> [String: MonthlyStats] {
        if (monthlyDrunkStats.count == 0) {
            calculateDrunkStats()
        }
        return monthlyDrunkStats
    }
    
    func getCumulativeDrunkStats() -> [String: MonthlyStats] {
        if (cumulativeDrunkStats.count == 0) {
            if (monthlyDrunkStats.count == 0) {
                calculateDrunkStats()
            }
            cumulativeDrunkStats = calculateCumulativeStats(monthlyDrunkStats)
        }
        return cumulativeDrunkStats
    }
    
    func getMonthlyAvailableStats() -> [String: MonthlyStats] {
        if (monthlyAvailableStats.count == 0) {
            calculateAvailableStats()
        }
        return monthlyAvailableStats
    }

    
    func getCumulativeAvailableStats() -> [String: MonthlyStats] {
        if (cumulativeAvailableStats.count == 0) {
            if (monthlyAvailableStats.count == 0) {
                calculateAvailableStats()
            }
        cumulativeAvailableStats = calculateCumulativeStats(monthlyAvailableStats)
        }
        return cumulativeAvailableStats
    }
    
    func getVarietalPurchasedStatsByValue() -> [String: VarietalStats] {
        if (varietalsPurchasedStats.count == 0) {
            calculateVarietalStats()
        }
        return consolidateStatsFor("Varietal", type: "Purchased", byValue: true)
    }
    
    func getVarietalPurchasedStatsByQuantity() -> [String: VarietalStats] {
        if (varietalsPurchasedStats.count == 0) {
            calculateVarietalStats()
        }
        return consolidateStatsFor("Varietal", type: "Purchased", byValue: false)
    }
    
    func getVarietalDrunkStatsByValue() -> [String: VarietalStats] {
        if (varietalsDrunkStats.count == 0) {
            calculateVarietalStats()
        }
        return consolidateStatsFor("Varietal", type: "Drunk", byValue: true)

    }
    
    func getVarietalDrunkStatsByQuantity() -> [String: VarietalStats] {
        if (varietalsDrunkStats.count == 0) {
            calculateVarietalStats()
        }
        return consolidateStatsFor("Varietal", type: "Drunk", byValue: false)
    }
    
    func getVarietalAvailableStatsByValue() -> [String: VarietalStats] {
        if (varietalsAvailableStats.count == 0) {
            calculateVarietalStats()
        }
        return consolidateStatsFor("Varietal", type: "Available", byValue: true)
        
    }
    
    func getVarietalAvailableStatsByQuantity() -> [String: VarietalStats] {
        if (varietalsAvailableStats.count == 0) {
            calculateVarietalStats()
        }
        return consolidateStatsFor("Varietal", type: "Available", byValue: false)
    }

    func getCountriesPurchasedStatsByValue() -> [String: VarietalStats] {
        if (countriesPurchasedStats.count == 0) {
            calculateCountriesStats()
        }
        return consolidateStatsFor("Countries", type: "Purchased", byValue: true)
    }
    
    func getCountriesPurchasedStatsByQuantity() -> [String: VarietalStats] {
        if (countriesPurchasedStats.count == 0) {
            calculateCountriesStats()
        }
        return consolidateStatsFor("Countries", type: "Purchased", byValue: false)
    }
    
    func getCountriesDrunkStatsByValue() -> [String: VarietalStats] {
        if (countriesDrunkStats.count == 0) {
            calculateCountriesStats()
        }
        return consolidateStatsFor("Countries", type: "Drunk", byValue: true)
        
    }
    
    func getCountriesDrunkStatsByQuantity() -> [String: VarietalStats] {
        if (countriesDrunkStats.count == 0) {
            calculateCountriesStats()
        }
        return consolidateStatsFor("Countries", type: "Drunk", byValue: false)
    }
    
    func getCountriesAvailableStatsByValue() -> [String: VarietalStats] {
        if (countriesAvailableStats.count == 0) {
            calculateCountriesStats()
        }
        return consolidateStatsFor("Countries", type: "Available", byValue: true)
        
    }
    
    func getCountriesAvailableStatsByQuantity() -> [String: VarietalStats] {
        if (countriesAvailableStats.count == 0) {
            calculateCountriesStats()
        }
        return consolidateStatsFor("Countries", type: "Available", byValue: false)
    }

    

    
    private func setupFetchRequest(entity: String) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName(entity, inManagedObjectContext:  self.managedObjectContext!)
        fetchRequest.entity = entityDescription
        return fetchRequest
    }
    
    private func calculatePurchasedStats() {
        var date = NSDate(dateString: "2013/01/01")
        var monthlyStat = MonthlyStats()
        
        let fetchRequest = setupFetchRequest("PurchaseLot")
        while (date.compare(NSDate()) == .OrderedAscending) {
            monthlyStat.resetValues()
            fetchRequest.predicate = predicateForMonth(date, type: "purchaseDate")
            do {
                let result = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
                if (result.count > 0) {
                    for (_, value) in result.enumerate() {
                        let lot = value as! PurchaseLot
                        monthlyStat.totalCost += lot.price!.doubleValue * lot.quantity!.doubleValue
                        monthlyStat.quantity += lot.quantity!.integerValue
                    }
                    if (monthlyStat.quantity == 0) {
                        monthlyStat.avgCost = 0.0
                    } else {
                        monthlyStat.avgCost = monthlyStat.totalCost / Double(monthlyStat.quantity)
                    }
                }
                monthlyPurchaseStats[dateFormatter.stringFromDate(date)] = monthlyStat
            }
            catch {
                abort()
            }
            date = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: 1, toDate: date, options: [])!
        }
    }
    
    private func calculateDrunkStats() {
        var date = NSDate(dateString: "2013/01/01")
        var monthlyStat = MonthlyStats()
        
        let fetchRequest = setupFetchRequest("Bottle")
        while (date.compare(NSDate()) == .OrderedAscending) {
            monthlyStat.resetValues()
            fetchRequest.predicate = predicateForMonth(date, type: "drunkDate")
            do {
                let result = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
                if (result.count > 0) {
                    for (_, value) in result.enumerate() {
                        let bottle = value as! Bottle
                        if (bottle.available == 0) {
                            let lot = bottle.lot!
                            monthlyStat.totalCost += lot.price!.doubleValue
                            monthlyStat.quantity += 1
                        }
                    }
                    if (monthlyStat.quantity == 0) {
                        monthlyStat.avgCost = 0.0
                    } else {
                        monthlyStat.avgCost = monthlyStat.totalCost / Double(monthlyStat.quantity)
                    }
                }
                monthlyDrunkStats[dateFormatter.stringFromDate(date)] = monthlyStat
            }
            catch {
                abort()
            }
            date = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: 1, toDate: date, options: [])!
        }
    }
    
    private func calculateAvailableStats() {
        var monthlyStat = MonthlyStats()
        if (monthlyPurchaseStats.count == 0) {
            calculatePurchasedStats()
        }
        if (monthlyDrunkStats.count == 0) {
            calculateDrunkStats()
        }
        
        let sortedKeys = Array(monthlyPurchaseStats.keys).sort(<)
        for key in sortedKeys {
            monthlyStat.resetValues()
            monthlyStat.totalCost = (monthlyPurchaseStats[key]?.totalCost)! - (monthlyDrunkStats[key]?.totalCost)!
            monthlyStat.quantity = (monthlyPurchaseStats[key]?.quantity)! - (monthlyDrunkStats[key]?.quantity)!
            if (monthlyStat.quantity == 0) {
                monthlyStat.avgCost = 0.0
            } else {
                monthlyStat.avgCost = monthlyStat.totalCost / Double(monthlyStat.quantity)
            }
            monthlyAvailableStats[key] = monthlyStat
        }

    }

    private func calculateCumulativeStats(input: [String: MonthlyStats]) -> [String: MonthlyStats]{
        var cumulativeStat = MonthlyStats()
        var output = [String: MonthlyStats]()
        let sortedKeys = Array(input.keys).sort(<)
        for (index, key) in sortedKeys.enumerate() {
            if (index == 0) {
                output[key] = input[key]
            } else {
                cumulativeStat.totalCost = (output[sortedKeys[index-1]]?.totalCost)! + (input[key]?.totalCost)!
                cumulativeStat.quantity = (output[sortedKeys[index-1]]?.quantity)! + (input[key]?.quantity)!
                if (cumulativeStat.quantity == 0) {
                    cumulativeStat.avgCost = 0.0
                } else {
                    cumulativeStat.avgCost = cumulativeStat.totalCost / Double(cumulativeStat.quantity)
                }
                output[key] = cumulativeStat
            }
        }
        return output
    }
    
    private func calculateVarietalStats() {
        var availableStat = VarietalStats()
        var drunkStat = VarietalStats()
        var purchasedStat = VarietalStats()
        
        getDistinctVarietalsCountriesRegions()
        
        let fetchRequest = setupFetchRequest("Wine")
        for varietal in varietalsArray {
            availableStat.resetValues()
            drunkStat.resetValues()
            purchasedStat.resetValues()
            fetchRequest.predicate = NSPredicate(format: "varietal contains[cd] %@", varietal)
            do {
                let result = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
                if (result.count > 0) {
                    for (_, value) in result.enumerate() {
                        let wine = value as! Wine
                        for (_, val) in (wine.lots?.enumerate())! {
                            let lot = val as! PurchaseLot
                            availableStat.totalCost += lot.price!.doubleValue * lot.availableBottles!.doubleValue
                            availableStat.quantity += lot.availableBottles!.integerValue
                            drunkStat.totalCost += lot.price!.doubleValue * lot.drunkBottles!.doubleValue
                            drunkStat.quantity += lot.drunkBottles!.integerValue
                        }
                    }
                }
            }
            catch {
                abort()
            }
            purchasedStat.totalCost = availableStat.totalCost + drunkStat.totalCost
            purchasedStat.quantity = availableStat.quantity + drunkStat.quantity
            
            if (availableStat.quantity == 0) {
                availableStat.avgCost = 0.0
            } else {
                availableStat.avgCost = availableStat.totalCost / Double(availableStat.quantity)
            }
            if (drunkStat.quantity == 0) {
                drunkStat.avgCost = 0.0
            } else {
                drunkStat.avgCost = drunkStat.totalCost / Double(drunkStat.quantity)
            }
            if (purchasedStat.quantity == 0) {
                purchasedStat.avgCost = 0.0
            } else {
                purchasedStat.avgCost = purchasedStat.totalCost / Double(purchasedStat.quantity)
            }
            
            availableStat.varietal = varietal
            drunkStat.varietal = varietal
            purchasedStat.varietal = varietal
            
            varietalsAvailableStats[varietal] = availableStat
            varietalsDrunkStats[varietal] = drunkStat
            varietalsPurchasedStats[varietal] = purchasedStat
        }
    }
    
    private func calculateCountriesStats() {
        var availableStat = VarietalStats()
        var drunkStat = VarietalStats()
        var purchasedStat = VarietalStats()
        
        getDistinctVarietalsCountriesRegions()
        
        let fetchRequest = setupFetchRequest("Wine")
        for country in countriesArray {
            availableStat.resetValues()
            drunkStat.resetValues()
            purchasedStat.resetValues()
            fetchRequest.predicate = NSPredicate(format: "country contains[cd] %@", country)
            do {
                let result = try self.managedObjectContext!.executeFetchRequest(fetchRequest)
                if (result.count > 0) {
                    for (_, value) in result.enumerate() {
                        let wine = value as! Wine
                        for (_, val) in (wine.lots?.enumerate())! {
                            let lot = val as! PurchaseLot
                            availableStat.totalCost += lot.price!.doubleValue * lot.availableBottles!.doubleValue
                            availableStat.quantity += lot.availableBottles!.integerValue
                            drunkStat.totalCost += lot.price!.doubleValue * lot.drunkBottles!.doubleValue
                            drunkStat.quantity += lot.drunkBottles!.integerValue
                        }
                    }
                }
            }
            catch {
                abort()
            }
            purchasedStat.totalCost = availableStat.totalCost + drunkStat.totalCost
            purchasedStat.quantity = availableStat.quantity + drunkStat.quantity
            
            if (availableStat.quantity == 0) {
                availableStat.avgCost = 0.0
            } else {
                availableStat.avgCost = availableStat.totalCost / Double(availableStat.quantity)
            }
            if (drunkStat.quantity == 0) {
                drunkStat.avgCost = 0.0
            } else {
                drunkStat.avgCost = drunkStat.totalCost / Double(drunkStat.quantity)
            }
            if (purchasedStat.quantity == 0) {
                purchasedStat.avgCost = 0.0
            } else {
                purchasedStat.avgCost = purchasedStat.totalCost / Double(purchasedStat.quantity)
            }
            
            availableStat.varietal = country
            drunkStat.varietal = country
            purchasedStat.varietal = country
            
            if (availableStat.quantity != 0) {
                countriesAvailableStats[country] = availableStat
            }
            if (drunkStat.quantity != 0) {
                countriesDrunkStats[country] = drunkStat
            }
            if (purchasedStat.quantity != 0) {
                countriesPurchasedStats[country] = purchasedStat
            }
        }
    }

    private func consolidateStatsFor(mode: String, type: String, byValue: Bool) -> [String: VarietalStats] {
        var othersStat = VarietalStats()
        othersStat.varietal = "Others"
        
        var thresholdStat = VarietalStats()
        var inputDict = [String: VarietalStats]()
        if (mode == "Varietal") {
            if (type == "Purchased") {
                inputDict = varietalsPurchasedStats
            } else if (type == "Drunk") {
                inputDict = varietalsDrunkStats
            } else {
                inputDict = varietalsAvailableStats
            }
        } else {
            if (type == "Purchased") {
                inputDict = countriesPurchasedStats
            } else if (type == "Drunk") {
                inputDict = countriesDrunkStats
            } else {
                inputDict = countriesAvailableStats
            }
        }
        let sortedKeys = Array(inputDict.keys).sort(<)
        
        if (byValue) {
            let sortedValsByCost = Array(inputDict.values).sort {
                return $0.totalCost > $1.totalCost
            }
            if (sortedValsByCost.count > 4) {
                thresholdStat = sortedValsByCost.dropLast(sortedValsByCost.count - 4).last!
            }
            
            for (_, key) in sortedKeys.enumerate() {
                if (inputDict[key]?.totalCost < thresholdStat.totalCost) {
                    othersStat.totalCost += inputDict[key]!.totalCost
                    othersStat.quantity += inputDict[key]!.quantity
                    inputDict[key] = nil
                }
            }
        }
        else {
            let sortedValsByQuantity = Array(inputDict.values).sort {
                return $0.quantity > $1.quantity
            }
            if (sortedValsByQuantity.count > 4) {
                thresholdStat = sortedValsByQuantity.dropLast(sortedValsByQuantity.count - 4).last!
            }
            for (_, key) in sortedKeys.enumerate() {
                if (inputDict[key]?.quantity < thresholdStat.quantity) {
                    othersStat.totalCost += inputDict[key]!.totalCost
                    othersStat.quantity += inputDict[key]!.quantity
                    inputDict[key] = nil
                }
            }
        }
        if (othersStat.quantity == 0) {
            othersStat.avgCost = 0.0
        } else {
            othersStat.avgCost = othersStat.totalCost / Double(othersStat.quantity)
            inputDict["Others"] = othersStat
        }
        return inputDict
    }

    
    private func predicateForMonth(date: NSDate, type: String) -> NSPredicate {
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
    
    func getDistinctVarietalsCountriesRegions() {
        let managedContext = self.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "Wine")
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

}