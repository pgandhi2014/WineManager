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
    
    @IBOutlet weak var topViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewTopConstraint: NSLayoutConstraint!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var statsHelper: StatsHelper? = nil
    
    var monthlyStatsTop = [String: VarietalStats]()
    var monthlyStatsBottom = [String: VarietalStats]()
    
    var statType = StatsType.VarietalsPurchased
    var chartLabel = ""
    
    var currentOrientation = UIInterfaceOrientation.Unknown
    
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
        
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let padding: CGFloat = 30.0
        let viewHeight = self.view.frame.size.width
        let viewWidth = self.view.frame.size.height
        
        if UIInterfaceOrientationIsLandscape(toInterfaceOrientation) {
            topViewTrailingConstraint.constant = (viewWidth/2.0) + (padding/2.0)
            topViewBottomConstraint.constant = 0
            bottomViewTopConstraint.constant = 0
            bottomViewLeadingConstraint.constant = (viewWidth/2.0) + (padding/2.0)
                    } else {
            topViewBottomConstraint.constant = (viewHeight/2.0) - padding
            topViewTrailingConstraint.constant = -20
            bottomViewLeadingConstraint.constant = -20
            bottomViewTopConstraint.constant = (viewHeight/2.0) - padding
        }
        currentOrientation = toInterfaceOrientation
        setChartTop(false)
        setChartBottom(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        if UIScreen.mainScreen().bounds.height > UIScreen.mainScreen().bounds.width {
            setupViewConstraintsForOrientation(UIInterfaceOrientation.Portrait)
            currentOrientation = UIInterfaceOrientation.Portrait
        } else {
            setupViewConstraintsForOrientation(UIInterfaceOrientation.LandscapeLeft)
            currentOrientation = UIInterfaceOrientation.LandscapeLeft
        }
        setChartTop(true)
        setChartBottom(true)
        
    }
    
    func setupViewConstraintsForOrientation(interfaceOrientation: UIInterfaceOrientation) {
        let padding: CGFloat = 4.0
        var viewHeight = CGFloat(0.0)
        var viewWidth = CGFloat(0.0)
        viewHeight = self.view.frame.size.height
        viewWidth = self.view.frame.size.width
        
        if UIInterfaceOrientationIsLandscape(interfaceOrientation) {
            topViewTrailingConstraint.constant = (viewWidth/2.0) - (padding * 4.0)
            topViewBottomConstraint.constant = 0
            bottomViewTopConstraint.constant = 0
            bottomViewLeadingConstraint.constant = (viewWidth/2.0) - (padding * 4.0)
        } else {
            topViewBottomConstraint.constant = (viewHeight/2.0) + (padding/2.0)
            topViewTrailingConstraint.constant = -20
            bottomViewLeadingConstraint.constant = -20
            bottomViewTopConstraint.constant = (viewHeight/2.0) + (padding/2.0)
        }

    }
    func setChartTop(animate: Bool) {
        var dataEntries = [ChartDataEntry]()
        let dataLabels = Array(monthlyStatsTop.keys).sort{
            return monthlyStatsTop[$0]!.totalCost > monthlyStatsTop[$1]!.totalCost
        }
        
        for (index, value) in dataLabels.enumerate() {
            let dataPoint = monthlyStatsTop[value]! as VarietalStats
            var dataEntry = ChartDataEntry()
            dataEntry = ChartDataEntry(value: dataPoint.totalCost, xIndex: index)
            dataEntries.append(dataEntry)
        }
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.colorful()
        chartDataSet.drawValuesEnabled = true
        chartDataSet.sliceSpace = CGFloat(1.0)
        chartDataSet.yValuePosition = .OutsideSlice
        chartDataSet.valueTextColor = NSUIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        chartDataSet.valueLinePart1Length = CGFloat(0.5)
        chartDataSet.valueLinePart2Length = CGFloat(0.2)
        chartDataSet.valueFormatter?.numberStyle = .NoStyle
        
        pieChartViewTop.drawSliceTextEnabled = false
        pieChartViewTop.holeRadiusPercent = CGFloat(0.45)
        pieChartViewTop.transparentCircleRadiusPercent = CGFloat(0.5)
        
        pieChartViewTop.legend.orientation = .Horizontal
        pieChartViewTop.legend.horizontalAlignment = .Center
        pieChartViewTop.legend.verticalAlignment = .Top
        if (currentOrientation == UIInterfaceOrientation.Portrait) {
            pieChartViewTop.setExtraOffsets(left: CGFloat(0.0), top: CGFloat(0.0), right: CGFloat(0.0), bottom: CGFloat(0.0))
        } else {
            pieChartViewTop.setExtraOffsets(left: CGFloat(0.0), top: CGFloat(15.0), right: CGFloat(0.0), bottom: CGFloat(15.0))
        }
        
        let chartData = PieChartData(xVals: dataLabels, dataSet: chartDataSet)
        pieChartViewTop.centerText = "$ Value"
        pieChartViewTop.drawMarkers = true
        pieChartViewTop.data = chartData
        pieChartViewTop.descriptionText = ""
        if (animate) {
            pieChartViewTop.animate(xAxisDuration: 2.0, easingOption: .EaseInCubic)
        }
        
    }
    
    func setChartBottom(animate: Bool) {
        var dataEntries = [ChartDataEntry]()
        let dataLabels = Array(monthlyStatsBottom.keys).sort{
            return monthlyStatsBottom[$0]!.quantity > monthlyStatsBottom[$1]!.quantity
        }
        
        for (index, value) in dataLabels.enumerate() {
            let dataPoint = monthlyStatsBottom[value]! as VarietalStats
            var dataEntry = ChartDataEntry()
            dataEntry = ChartDataEntry(value: Double(dataPoint.quantity), xIndex: index)
            dataEntries.append(dataEntry)
        }
        let chartDataSetBottom = PieChartDataSet()// (yVals: dataEntries, label: "")
        chartDataSetBottom.yVals = dataEntries
        chartDataSetBottom.label = ""
        chartDataSetBottom.colors = ChartColorTemplates.colorful()
        chartDataSetBottom.drawValuesEnabled = true
        chartDataSetBottom.sliceSpace = CGFloat(1.0)
        chartDataSetBottom.yValuePosition = .OutsideSlice
        chartDataSetBottom.valueTextColor = NSUIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        chartDataSetBottom.valueLinePart1Length = CGFloat(0.5)
        chartDataSetBottom.valueFormatter?.numberStyle = .NoStyle

        pieChartViewBottom.drawSliceTextEnabled = false
        pieChartViewBottom.holeRadiusPercent = CGFloat(0.45)
        pieChartViewBottom.transparentCircleRadiusPercent = CGFloat(0.5)
        
        pieChartViewBottom.legend.orientation = .Horizontal
        pieChartViewBottom.legend.horizontalAlignment = .Center
        if (currentOrientation == UIInterfaceOrientation.Portrait) {
            pieChartViewBottom.legend.verticalAlignment = .Bottom
            pieChartViewBottom.setExtraOffsets(left: CGFloat(0.0), top: CGFloat(0.0), right: CGFloat(0.0), bottom: CGFloat(0.0))
        } else {
            pieChartViewBottom.legend.verticalAlignment = .Top
            pieChartViewBottom.setExtraOffsets(left: CGFloat(0.0), top: CGFloat(15.0), right: CGFloat(0.0), bottom: CGFloat(15.0))
        }

        let chartData = PieChartData(xVals: dataLabels, dataSet: chartDataSetBottom)
        pieChartViewBottom.centerText = "Quantity"
        pieChartViewBottom.drawMarkers = true
        pieChartViewBottom.data = chartData
        pieChartViewBottom.descriptionText = ""
        if (animate) {
            pieChartViewBottom.animate(xAxisDuration: 2.0, easingOption: .EaseInCubic)
        }
        
    }

}
