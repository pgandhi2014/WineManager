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
    var monthlyPurchaseStats = [String: MonthlyStats]()
    var chartType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setChart()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setChart(dataPoints: [String], values: [Double]) {
        
    }
    
    func setChart() {
        var dataEntries = [BarChartDataEntry]()
        
        let dataLabels = Array(monthlyPurchaseStats.keys).sort(<)
        
        for (index, value) in dataLabels.enumerate() {
            let dataPoint = monthlyPurchaseStats[value]! as MonthlyStats
            var dataEntry = BarChartDataEntry()
            if (chartType == "TotalCost") {
                dataEntry = BarChartDataEntry(value: dataPoint.totalCost, xIndex: index)
            } else if (chartType == "TotalBottles") {
                dataEntry = BarChartDataEntry(value: Double(dataPoint.quantity), xIndex: index)
            } else if (chartType == "AvgCost") {
                dataEntry = BarChartDataEntry(value: dataPoint.avgCost, xIndex: index)
            }
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
        let chartData = BarChartData(xVals: dataLabels, dataSet: chartDataSet)
        chartDataSet.colors = ChartColorTemplates.pastel()
        barChartView.data = chartData
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.barData?.setDrawValues(false)
        barChartView.descriptionText = ""
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInCubic)
        
        
    }
    
}
