//  GoalsViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 02/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts




class GoalsViewController: UIViewController, IndicatorInfoProvider, ChartViewDelegate {

    @IBOutlet weak var combinedCharts: BarChartView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var datePicker: UIView!
    @IBOutlet weak var chartTitle: UILabel!
    
    
    
    
    lazy var mydatePicker: AirbnbDatePicker = {
        let btn = AirbnbDatePicker()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.delegate = self
        return btn
    }()
    
    let secondColor = UIColor(red: 206/255, green: 19/255, blue: 54/255, alpha: 1)
    let thirdColor = UIColor(red: 255/255, green: 86/255, blue: 96/255, alpha: 1)
    let forthColor = UIColor(red: 149/255, green: 0/255, blue: 17/255, alpha: 1)
    
    
    let months = ["6am-12pm", "12pm - 6pm", "6pm - 12am", "12am -6am"]
    let lively = [20, 4, 6, 3]
    let chiling = [10, 14, 60, 13]
    let wandering = [20, 44, 60, 32]
    var pet: Pet!
    
    weak var axisFormatDelegate: IAxisValueFormatter?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartTitle.text = "Grouped Analysis"
        self.barChart.isHidden = true
        self.datePicker.addSubview(mydatePicker)

        self.mydatePicker.bounds = datePicker.bounds
        self.mydatePicker.center = datePicker.center
        mydatePicker.centerXAnchor.constraint(equalTo: datePicker.centerXAnchor).isActive = true
        mydatePicker.widthAnchor.constraint(equalTo: datePicker.widthAnchor).isActive = true
        mydatePicker.heightAnchor.constraint(equalTo: datePicker.heightAnchor).isActive = true
        mydatePicker.topAnchor.constraint(equalTo: datePicker.topAnchor).isActive = true
        mydatePicker.bottomAnchor.constraint(equalTo: datePicker.bottomAnchor).isActive = true

        barChart.delegate = self
        pieChart.delegate = self
        combinedCharts.delegate = self
        
        if let currentPet = self.pet, let name = currentPet.name {
            barChart.noDataText = "No activity data available for \(name)"
            combinedCharts.noDataText = "No activity data available for \(name)"
            pieChart.noDataText = "No activity data available for \(name)"
        } else {
            barChart.noDataText = "No activity data available"
            combinedCharts.noDataText = "No activity data available"
            pieChart.noDataText = "No activity data available"
        }
        
        pieChartUpdate()
        combinedChartView(myxaxis: self.months, lively: self.lively, chiling: self.chiling, wandering: self.wandering)


    }

    func barChartUpdate(myxaxis: [String], values: [Int], color: UIColor) {
        
        self.barChart.backgroundColor = UIColor.white
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<myxaxis.count {
            let dataEntry = BarChartDataEntry(x: Double(i) , y: Double(values[i]))
            dataEntries.append(dataEntry)
        }

        let xaxis = barChart.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        xaxis.labelPosition = .bottom
//        xaxis.centerAxisLabelsEnabled = true
        xaxis.granularityEnabled = true
        xaxis.granularity = 1.0
        
        xaxis.drawAxisLineEnabled = false
        xaxis.drawGridLinesEnabled = false
        xaxis.valueFormatter = IndexAxisValueFormatter(values: myxaxis)
      
        
//        barChart.xAxis.
//        barChart.xAxis.granularity = 1.0
        
        barChart.barData?.highlightEnabled = false
        barChart.isUserInteractionEnabled = false
        
        

        barChart.rightAxis.drawLabelsEnabled = false
        barChart.rightAxis.drawAxisLineEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawTopYLabelEntryEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawLabelsEnabled = false
        barChart.leftAxis.drawAxisLineEnabled = false
        
        
        
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1.0
        pFormatter.percentSymbol = " hrs"
        let formatter = DefaultValueFormatter(formatter: pFormatter)
        

        let dataSet = BarChartDataSet(values: dataEntries, label: "Chilling Analysis")
        
        let data = BarChartData(dataSets: [dataSet])
        data.setValueFormatter(formatter)
        
        barChart.data?.highlightEnabled = false

        
        dataSet.colors = [color]
        barChart.data = data
        barChart.chartDescription?.text = ""
        //This must stay at end of function
        barChart.notifyDataSetChanged()
        
        barChart.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)

    }
    
    
    func combinedChartView(myxaxis: [String], lively: [Int], chiling: [Int], wandering: [Int]) {
        // legand
        
        self.combinedCharts.chartDescription?.text = ""
        let legand = combinedCharts.legend
        legand.enabled = true
        legand.horizontalAlignment = .right
        legand.verticalAlignment = .top
        legand.orientation = .vertical
        legand.drawInside = true
        legand.yOffset = 10.0;
        legand.xOffset = 10.0;
        legand.yEntrySpace = 0.0;
        
        // xaxis
        let xaxis = combinedCharts.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        xaxis.drawGridLinesEnabled = true
        xaxis.labelPosition = .bottom
        xaxis.centerAxisLabelsEnabled = true
        xaxis.valueFormatter = IndexAxisValueFormatter(values: myxaxis)
        xaxis.granularity = 1
        
        
        // left xaxis
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.numberStyle = .percent
        leftAxisFormatter.percentSymbol = " hr"
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.multiplier = 1.0
        
        let formatter = DefaultValueFormatter(formatter: leftAxisFormatter)

        let yaxis = combinedCharts.leftAxis
        yaxis.spaceTop = 0.35
        yaxis.axisMinimum = 0
        yaxis.drawGridLinesEnabled = false
        combinedCharts.rightAxis.enabled = false
        
        
        //axisFormatDelegate = self

        
        // data entry
        
        var dataEntries: [BarChartDataEntry] = []
        var dataEntries1: [BarChartDataEntry] = []
        var dataEntries2: [BarChartDataEntry] = []
        
        


        for i in 0..<myxaxis.count {
            let dataEntry = BarChartDataEntry(x: Double(i) , y: Double(wandering[i]))
            dataEntries.append(dataEntry)
            
            let dataEntry1 = BarChartDataEntry(x: Double(i) , y: Double(chiling[i]))
            dataEntries1.append(dataEntry1)
            let dataEntry2 = BarChartDataEntry(x: Double(i) , y: Double(lively[i]))
            dataEntries2.append(dataEntry2)
            
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Wandering")
        
        let chartDataSet1 = BarChartDataSet(values: dataEntries1, label: "Chilling")
        let chartDataSet2 = BarChartDataSet(values: dataEntries2, label: "Lively")
        
        let dataSets: [BarChartDataSet] = [chartDataSet,chartDataSet1, chartDataSet2]
        
        chartDataSet.colors = [secondColor]
        chartDataSet1.colors = [forthColor]
        chartDataSet2.colors = [thirdColor]

        
        let chartData = BarChartData(dataSets: dataSets)
        chartData.setValueFormatter(formatter)
        
        
        let groupSpace = 0.01
        let barSpace = 0.03
        let barWidth = 0.3
        
        // (0.3 + 0.03) * 4 + 0.01 = 1.00 -> interval per "group"
        
        
        let groupCount = myxaxis.count
        let startYear = 0
        
        chartData.barWidth = barWidth
        combinedCharts.xAxis.axisMinimum = Double(startYear)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        combinedCharts.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        combinedCharts.notifyDataSetChanged()
        combinedCharts.data = chartData
        combinedCharts.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)








        
    }

    
    class ChartStringFormatter: NSObject, IAxisValueFormatter {
        
        var nameValues: [String]! =  ["Morning", "Afternoon", "Evening", "Night"]
        
        public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return String(describing: nameValues[Int(value)])
        }
    }
    
    
    
    class ChartStringFormattesr: NSObject, IAxisValueFormatter {
        
        var nameValues: [String]! =  ["Morning", "Afternoon", "Evening", "Night", "", "", "", "", ""]
        
        public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return String(describing: nameValues[Int(value)])
        }
    }
    
    func pieChartUpdate() {
        self.pieChart.backgroundColor = UIColor.white
        let entry1 = PieChartDataEntry(value: 12, label: "Chiling")
        let entry2 = PieChartDataEntry(value: 8, label: "Wandering")
        let entry3 = PieChartDataEntry(value: 4, label: "Lively")
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1.0
        pFormatter.percentSymbol = " hrs"
        let formatter = DefaultValueFormatter(formatter: pFormatter)
        let dataSet = PieChartDataSet(values: [entry1, entry2, entry3], label: "")
        dataSet.valueLineColor = UIColor.clear
        let secondColor = UIColor(red: 206/255, green: 19/255, blue: 54/255, alpha: 1)
        let thirdColor = UIColor(red: 255/255, green: 86/255, blue: 96/255, alpha: 1)
        let forthColor = UIColor(red: 149/255, green: 0/255, blue: 17/255, alpha: 1)
        dataSet.colors = [secondColor ,forthColor, thirdColor]
        let data = PieChartData(dataSet: dataSet)
        data.setValueFont(UIFont.systemFont(ofSize: 13))
        data.setValueFormatter(formatter)

        pieChart.data = data
        pieChart.chartDescription?.text = ""
        //This must stay at end of function
        pieChart.notifyDataSetChanged()
        pieChart.animate(xAxisDuration: 1)
    }
    
    
    
    @IBAction func changeModePressed(_ sender: Any) {
        showActionSheet()
    }
    
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: "Change charts mode", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let chiling = UIAlertAction(title: "Chilling", style: .default) { action in
            self.barChartUpdate(myxaxis: self.months, values: self.wandering, color: self.thirdColor)

            self.barChart.isHidden = false
            self.combinedCharts.isHidden = true
            self.chartTitle.text = "Chilling Analysis"
        }
        
        let wandering = UIAlertAction(title: "Wandering", style: .default) { action in
            self.barChartUpdate(myxaxis: self.months, values: self.wandering, color: UIColor.primary)

            self.barChart.isHidden = false
            self.combinedCharts.isHidden = true
            self.chartTitle.text = "Wandering Analysis"
        }
        
        let lively = UIAlertAction(title: "Lively", style: .default) { action in
            self.barChartUpdate(myxaxis: self.months, values: self.wandering, color: self.forthColor)

            self.barChart.isHidden = false
            self.combinedCharts.isHidden = true
            self.chartTitle.text = "Lively Analysis"

        }
        
        let groupedChart = UIAlertAction(title: "Grouped data", style: .default) { action in
            self.barChart.isHidden = true
            self.combinedCharts.isHidden = false
            self.chartTitle.text = "Grouped Analysis"
        }
        
        actionSheet.addAction(chiling)
        actionSheet.addAction(wandering)
        actionSheet.addAction(lively)
        actionSheet.addAction(cancel)
        actionSheet.addAction(groupedChart)
        present(actionSheet, animated: true, completion: nil)
    }
    

    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Activity")
    }
}


extension UIScrollView {
    func updateContentViewSize() {
        var newHeight: CGFloat = 0
        for view in subviews {
            let ref = view.frame.origin.y + view.frame.height
            if ref > newHeight {
                newHeight = ref
            }
        }
        let oldSize = contentSize
        let newSize = CGSize(width: oldSize.width, height: newHeight + 20)
        contentSize = newSize
    }
}
