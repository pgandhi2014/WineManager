//
//  LineChartsViewController.swift
//  WineManager
//
//  Created by Prashant Gandhi (Intel) on 7/22/16.
//  Copyright © 2016 Prashant Gandhi. All rights reserved.
//

import UIKit
import Charts

class LineChartsViewController: UIViewController {
    
    @IBOutlet var lineChartView: LineChartView!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var statsHelper: StatsHelper? = nil
    
    var monthlyStats = [String: MonthlyStats]()
    var monthlyStats2 = [String: MonthlyStats]()
    var monthlyStats3 = [String: MonthlyStats]()
    var statType = StatsType.CumulativeCost
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statsHelper = StatsHelper(moc: appDelegate.managedObjectContext)
        monthlyStats = statsHelper!.getCumulativePurchasedStats()
        monthlyStats2 = statsHelper!.getCumulativeDrunkStats()
        monthlyStats3 = statsHelper!.getCumulativeAvailableStats()
        
        setChart()
    }
    
    func setChart() {
        var dataEntries = [ChartDataEntry]()
        var dataEntries2 = [ChartDataEntry]()
        var dataEntries3 = [ChartDataEntry]()
        let dataLabels = Array(monthlyStats.keys).sort(<)
        
        for (index, value) in dataLabels.enumerate() {
            let dataPoint = monthlyStats[value]! as MonthlyStats
            let dataPoint2 = monthlyStats2[value]! as MonthlyStats
            let dataPoint3 = monthlyStats3[value]! as MonthlyStats
            
            var dataEntry = ChartDataEntry()
            var dataEntry2 = ChartDataEntry()
            var dataEntry3 = ChartDataEntry()
            
            if (statType == StatsType.CumulativeCost) {
                dataEntry = ChartDataEntry(value: dataPoint.totalCost, xIndex: index)
                dataEntry2 = ChartDataEntry(value: dataPoint2.totalCost, xIndex: index)
                dataEntry3 = ChartDataEntry(value: dataPoint3.totalCost, xIndex: index)
            } else if (statType == StatsType.CumulativeBottles) {
                dataEntry = ChartDataEntry(value: Double(dataPoint.quantity), xIndex: index)
                dataEntry2 = ChartDataEntry(value: Double(dataPoint2.quantity), xIndex: index)
                dataEntry3 = ChartDataEntry(value: Double(dataPoint3.quantity), xIndex: index)
            } else if (statType == StatsType.CumulativeAverage) {
                dataEntry = ChartDataEntry(value: dataPoint.avgCost, xIndex: index)
                dataEntry2 = ChartDataEntry(value: dataPoint2.avgCost, xIndex: index)
                dataEntry3 = ChartDataEntry(value: dataPoint3.avgCost, xIndex: index)
            }
            dataEntries.append(dataEntry)
            dataEntries2.append(dataEntry2)
            dataEntries3.append(dataEntry3)
        }
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: "Purchased")
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.lineWidth = CGFloat(4.0)
        chartDataSet.colors = [NSUIColor(red: 200/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)]
        chartDataSet.drawValuesEnabled = false
        
        let chartDataSet2 = LineChartDataSet(yVals: dataEntries2, label: "Drunk")
        chartDataSet2.drawCirclesEnabled = false
        chartDataSet2.lineWidth = CGFloat(4.0)
        chartDataSet2.colors = [NSUIColor(red: 200/255.0, green: 0/255.0, blue: 200/255.0, alpha: 1.0)]
        chartDataSet2.drawValuesEnabled = false

        let chartDataSet3 = LineChartDataSet(yVals: dataEntries3, label: "Available")
        chartDataSet3.drawCirclesEnabled = false
        chartDataSet3.lineWidth = CGFloat(4.0)
        chartDataSet3.colors = [NSUIColor(red: 0/255.0, green: 0/255.0, blue: 200/255.0, alpha: 1.0)]
        chartDataSet3.drawValuesEnabled = false
        
        let dataSets = [chartDataSet, chartDataSet2, chartDataSet3]
        
        //let chartData = LineChartData(xVals: dataLabels, dataSet: chartDataSet)
        let chartData = LineChartData(xVals: dataLabels, dataSets: dataSets)
        lineChartView.data = chartData
        lineChartView.xAxis.labelPosition = .Bottom
        lineChartView.descriptionText = ""
        lineChartView.animate(xAxisDuration: 2.0, easingOption: .EaseInCubic)
        
    }
    
}
