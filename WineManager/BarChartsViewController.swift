//
//  ChartsViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 7/21/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import Charts

class BarChartsViewController: UIViewController {

    @IBOutlet var barChartView: BarChartView!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var statsHelper: StatsHelper? = nil
    
    var monthlyStats = [String: MonthlyStats]()
    var statType = StatsType.MonthlyPurchasedCost
    var chartLabel = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statsHelper = StatsHelper(moc: appDelegate.managedObjectContext)
        switch statType {
        case .MonthlyPurchasedCost:
            monthlyStats = statsHelper!.getMonthlyPurchasedStats()
            chartLabel = "Value purchased per month"
        case .MonthlyPurchasedBottles:
            monthlyStats = statsHelper!.getMonthlyPurchasedStats()
            chartLabel = "Bottles purchased per month"
        case .MonthlyDrunkCost:
            monthlyStats = statsHelper!.getMonthlyDrunkStats()
            chartLabel = "Value drunk per month"
        case .MonthlyDrunkBottles:
            monthlyStats = statsHelper!.getMonthlyDrunkStats()
            chartLabel = "Bottles drunk per month"
        case .MonthlyAvailableCost:
            monthlyStats = statsHelper!.getMonthlyAvailableStats()
            chartLabel = "Value added per month"
        case .MonthlyAvailableBottles:
            monthlyStats = statsHelper!.getMonthlyAvailableStats()
            chartLabel = "Bottles added per month"
        default:
            monthlyStats = statsHelper!.getMonthlyPurchasedStats()
            chartLabel = "Value purchased per month"
        }
        
        setChart()
    }
    
    func setChart() {
        var dataEntries = [BarChartDataEntry]()
        let chartDataSet = BarChartDataSet()
        let dataLabels = Array(monthlyStats.keys).sort(<)
        let color = UIColor.lightGrayColor()
        let font = UIFont.systemFontOfSize(12.0)
        let insets = UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0)
        let marker = BalloonMarker(color: color, font: font, insets: insets)
        marker.minimumSize = CGSizeMake(60.0, 30.0);
        
        for (index, value) in dataLabels.enumerate() {
            let dataPoint = monthlyStats[value]! as MonthlyStats
            var dataEntry = BarChartDataEntry()
            if (statType == StatsType.MonthlyPurchasedCost || statType == StatsType.MonthlyDrunkCost || statType == StatsType.MonthlyAvailableCost) {
                dataEntry = BarChartDataEntry(value: dataPoint.totalCost, xIndex: index)
                chartDataSet.valueFormatter?.numberStyle = .CurrencyStyle
            } else if (statType == StatsType.MonthlyPurchasedBottles || statType == StatsType.MonthlyDrunkBottles || statType == StatsType.MonthlyAvailableBottles) {
                dataEntry = BarChartDataEntry(value: Double(dataPoint.quantity), xIndex: index)
                chartDataSet.valueFormatter?.numberStyle = .NoStyle
                chartDataSet.valueFormatter?.maximumFractionDigits = 0
                marker.formatter.numberStyle = .NoStyle
            }
            dataEntries.append(dataEntry)
        }
        chartDataSet.yVals = dataEntries
        //chartDataSet.label = chartLabel
        let chartData = BarChartData(xVals: dataLabels, dataSet: chartDataSet)
        chartDataSet.colors = ChartColorTemplates.liberty()
        
        barChartView.marker = marker
        barChartView.data = chartData
        barChartView.legend.enabled = false
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.barData?.setDrawValues(false)
        barChartView.descriptionText = ""
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInCubic)
        
        
    }
    
}
