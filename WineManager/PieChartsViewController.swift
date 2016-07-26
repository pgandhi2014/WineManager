//
//  PieChartsViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 7/24/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import Charts

class PieChartsViewController: UIViewController {

    @IBOutlet weak var pieChartViewTop: PieChartView!
    @IBOutlet weak var pieChartViewBottom: PieChartView!
    
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var statsHelper: StatsHelper? = nil
    
    var monthlyStatsTop = [String: VarietalStats]()
    var monthlyStatsBottom = [String: VarietalStats]()
    
    var statType = StatsType.VarietalsPurchased
    var chartLabel = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statsHelper = StatsHelper(moc: appDelegate.managedObjectContext)
        switch statType {
        case .VarietalsPurchased:
            monthlyStatsTop = statsHelper!.getVarietalPurchasedStatsByValue()
            monthlyStatsBottom = statsHelper!.getVarietalPurchasedStatsByQuantity()
            chartLabel = "Purchased"
        case .VarietalsDrunk:
            monthlyStatsTop = statsHelper!.getVarietalDrunkStatsByValue()
            monthlyStatsBottom = statsHelper!.getVarietalDrunkStatsByQuantity()
            chartLabel = "Drunk"
        case .VarietalsAvailable:
            monthlyStatsTop = statsHelper!.getVarietalAvailableStatsByValue()
            monthlyStatsBottom = statsHelper!.getVarietalAvailableStatsByQuantity()
            chartLabel = "Available"
        case .CountriesAvailable:
            monthlyStatsTop = statsHelper!.getCountriesAvailableStatsByValue()
            monthlyStatsBottom = statsHelper!.getCountriesAvailableStatsByQuantity()
            chartLabel = "Available"
        case .CountriesDrunk:
            monthlyStatsTop = statsHelper!.getCountriesDrunkStatsByValue()
            monthlyStatsBottom = statsHelper!.getCountriesDrunkStatsByQuantity()
            chartLabel = "Drunk"
        case .CountriesPurchased:
            monthlyStatsTop = statsHelper!.getCountriesPurchasedStatsByValue()
            monthlyStatsBottom = statsHelper!.getCountriesPurchasedStatsByQuantity()
            chartLabel = "Purchased"
        default:
            monthlyStatsTop = statsHelper!.getVarietalPurchasedStatsByValue()
            monthlyStatsBottom = statsHelper!.getVarietalPurchasedStatsByQuantity()
            chartLabel = "Purchased"
        }
        
        setChartTop()
        setChartBottom()
    }
    
    func setChartTop() {
        var dataEntries = [ChartDataEntry]()
        let dataLabels = Array(monthlyStatsTop.keys).sort(<)
        
        for (index, value) in dataLabels.enumerate() {
            let dataPoint = monthlyStatsTop[value]! as VarietalStats
            var dataEntry = ChartDataEntry()
            dataEntry = ChartDataEntry(value: dataPoint.totalCost, xIndex: index)
            dataEntries.append(dataEntry)
        }
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.pastel()
        chartDataSet.drawValuesEnabled = true
        
        pieChartViewTop.drawSliceTextEnabled = false
        pieChartViewTop.holeRadiusPercent = CGFloat(0.4)
        pieChartViewTop.transparentCircleRadiusPercent = CGFloat(0.45)
        
        pieChartViewTop.legend.orientation = .Horizontal
        pieChartViewTop.legend.horizontalAlignment = .Center
        pieChartViewTop.legend.verticalAlignment = .Top
        
        
        let chartData = PieChartData(xVals: dataLabels, dataSet: chartDataSet)
        pieChartViewTop.centerText = "Value"
        pieChartViewTop.drawMarkers = true
        
        pieChartViewTop.data = chartData
        pieChartViewTop.descriptionText = ""
        pieChartViewTop.animate(xAxisDuration: 2.0, easingOption: .EaseInCubic)
        
    }
    
    func setChartBottom() {
        var dataEntries = [ChartDataEntry]()
        let dataLabels = Array(monthlyStatsBottom.keys).sort(<)
        
        for (index, value) in dataLabels.enumerate() {
            let dataPoint = monthlyStatsBottom[value]! as VarietalStats
            var dataEntry = ChartDataEntry()
            dataEntry = ChartDataEntry(value: Double(dataPoint.quantity), xIndex: index)
            dataEntries.append(dataEntry)
        }
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.pastel()
        chartDataSet.drawValuesEnabled = true
        
        pieChartViewBottom.drawSliceTextEnabled = false
        pieChartViewBottom.holeRadiusPercent = CGFloat(0.4)
        pieChartViewBottom.transparentCircleRadiusPercent = CGFloat(0.45)
        
        pieChartViewBottom.legend.orientation = .Horizontal
        pieChartViewBottom.legend.horizontalAlignment = .Center
        pieChartViewBottom.legend.verticalAlignment = .Bottom
        
        
        let chartData = PieChartData(xVals: dataLabels, dataSet: chartDataSet)
        pieChartViewBottom.centerText = "Quantity"
        pieChartViewBottom.data = chartData
        pieChartViewBottom.descriptionText = ""
        pieChartViewBottom.animate(xAxisDuration: 2.0, easingOption: .EaseInCubic)
        
    }

}
