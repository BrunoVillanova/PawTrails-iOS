//  GoalsViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 02/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts



class GoalsViewController: UIViewController, IndicatorInfoProvider {

    @IBOutlet weak var livelyChart: BarChartView!
    @IBOutlet weak var wanderingChart: BarChartView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    
    @IBOutlet weak var datePicker: UIView!
    
    lazy var mydatePicker: AirbnbDatePicker = {
        let btn = AirbnbDatePicker()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.delegate = self
        return btn
    }()
    
    let secondColor = UIColor(red: 206/255, green: 19/255, blue: 54/255, alpha: 1)
    let thirdColor = UIColor(red: 255/255, green: 86/255, blue: 96/255, alpha: 1)
    let forthColor = UIColor(red: 149/255, green: 0/255, blue: 17/255, alpha: 1)

    var pet: Pet!
    override func viewDidLoad() {
        super.viewDidLoad()

    
        self.datePicker.addSubview(mydatePicker)

        self.mydatePicker.bounds = datePicker.bounds
        self.mydatePicker.center = datePicker.center
        mydatePicker.centerXAnchor.constraint(equalTo: datePicker.centerXAnchor).isActive = true
        mydatePicker.widthAnchor.constraint(equalTo: datePicker.widthAnchor).isActive = true
        mydatePicker.heightAnchor.constraint(equalTo: datePicker.heightAnchor).isActive = true
        mydatePicker.topAnchor.constraint(equalTo: datePicker.topAnchor).isActive = true
        mydatePicker.bottomAnchor.constraint(equalTo: datePicker.bottomAnchor).isActive = true

        
        
        pieChartUpdate()
        barChartUpdate()
        updateThirdBar()
        updateSecondBar()

    }

    func barChartUpdate () {
        self.barChart.backgroundColor = UIColor.white
        let entry1 = BarChartDataEntry(x: 0, y: 2)
        let entry2 = BarChartDataEntry(x:1, y: 8)
        let entry3 = BarChartDataEntry(x: 2, y: 4)
        let entry4 = BarChartDataEntry(x: 3, y: 12)
        
        
        barChart.xAxis.granularityEnabled = true
        barChart.xAxis.granularity = 1.0
        
        barChart.barData?.highlightEnabled = false
        barChart.isUserInteractionEnabled = false
        
        

        barChart.rightAxis.drawLabelsEnabled = false
        barChart.rightAxis.drawAxisLineEnabled = false
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawTopYLabelEntryEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawLabelsEnabled = false
        barChart.leftAxis.drawAxisLineEnabled = false
        
        barChart.xAxis.drawAxisLineEnabled = false
        barChart.xAxis.drawGridLinesEnabled = false
        
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1.0
        pFormatter.percentSymbol = " hrs"
        let formatter = DefaultValueFormatter(formatter: pFormatter)
        

        let formater = ChartStringFormatter()
        self.barChart.xAxis.valueFormatter = formater
        let dataSet = BarChartDataSet(values: [entry1, entry2, entry3, entry4], label: "Chilling Analysis")
        let data = BarChartData(dataSets: [dataSet])
        data.setValueFormatter(formatter)
        
        barChart.data?.highlightEnabled = false

        
        dataSet.colors = [UIColor.primary]
        barChart.data = data
        barChart.chartDescription?.text = ""
        //This must stay at end of function
        barChart.notifyDataSetChanged()
        
    }
    
    func updateThirdBar () {
        self.livelyChart.backgroundColor = UIColor.white
        let entry1 = BarChartDataEntry(x: 0, y: 2)
        let entry2 = BarChartDataEntry(x:1, y: 8)
        let entry3 = BarChartDataEntry(x: 2, y: 6)
        let entry4 = BarChartDataEntry(x: 3, y: 12)
        
        
        livelyChart.xAxis.granularityEnabled = true
        livelyChart.xAxis.granularity = 1.0
        
        livelyChart.barData?.highlightEnabled = false
        livelyChart.isUserInteractionEnabled = false
        
        
        
        livelyChart.rightAxis.drawLabelsEnabled = false
        livelyChart.rightAxis.drawAxisLineEnabled = false
        livelyChart.rightAxis.drawGridLinesEnabled = false
        livelyChart.rightAxis.drawTopYLabelEntryEnabled = false
        livelyChart.leftAxis.drawGridLinesEnabled = false
        livelyChart.leftAxis.drawLabelsEnabled = false
        livelyChart.leftAxis.drawAxisLineEnabled = false
        
        livelyChart.xAxis.drawAxisLineEnabled = false
        livelyChart.xAxis.drawGridLinesEnabled = false
        
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1.0
        pFormatter.percentSymbol = " hrs"
        let formatter = DefaultValueFormatter(formatter: pFormatter)
        
        
        let formater = ChartStringFormatter()
        self.livelyChart.xAxis.valueFormatter = formater
        
        let dataSet = BarChartDataSet(values: [entry1, entry2, entry3, entry4], label: "Chilling Analysis")
        let data = BarChartData(dataSets: [dataSet])
        data.setValueFormatter(formatter)
        
        livelyChart.data?.highlightEnabled = false
        
        
        dataSet.colors = [forthColor]
        livelyChart.data = data
        livelyChart.chartDescription?.text = ""
        //This must stay at end of function
        livelyChart.notifyDataSetChanged()
        
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
    
    
    
    
    func updateSecondBar () {
        self.wanderingChart.backgroundColor = UIColor.white

 
        let entry1 = BarChartDataEntry(x: 0, y: 2)
        let entry2 = BarChartDataEntry(x: 1, y: 2)
        let entry3 = BarChartDataEntry(x: 2, y: 1)
        let entry4 = BarChartDataEntry(x: 3, y: 3)
        
        
        wanderingChart.barData?.highlightEnabled = false
        wanderingChart.isUserInteractionEnabled = false

        wanderingChart.rightAxis.drawLabelsEnabled = false
        wanderingChart.rightAxis.drawAxisLineEnabled = false
        wanderingChart.rightAxis.drawGridLinesEnabled = false
        wanderingChart.rightAxis.drawTopYLabelEntryEnabled = false
        wanderingChart.leftAxis.drawGridLinesEnabled = false
        wanderingChart.leftAxis.drawLabelsEnabled = false
        wanderingChart.leftAxis.drawAxisLineEnabled = false
        
        wanderingChart.xAxis.drawAxisLineEnabled = false
        wanderingChart.xAxis.drawGridLinesEnabled = false
        
        wanderingChart.xAxis.granularityEnabled = true
        wanderingChart.xAxis.granularity = 1.0
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1.0
        pFormatter.percentSymbol = " hrs"
        let formatter = DefaultValueFormatter(formatter: pFormatter)
        
        let formatere = ChartStringFormatter()
        self.wanderingChart.xAxis.valueFormatter = formatere
        
        
        let dataSet = BarChartDataSet(values: [entry1, entry2, entry3, entry4], label: "Lively Analysis")
        dataSet.colors = [self.thirdColor]

        dataSet.drawValuesEnabled = true
        let data = BarChartData(dataSets: [dataSet])
        data.setValueFormatter(formatter)
        wanderingChart.data = data
        wanderingChart.chartDescription?.text = ""
        

        //This must stay at end of function
        barChart.notifyDataSetChanged()
        
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
