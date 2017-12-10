//  GoalsViewController.swift
//  PawTrails
//
//  Created by Marc Perello on 02/11/2017.
//  Copyright © 2017 AttitudeTech. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Charts

class GoalsViewController: UIViewController, IndicatorInfoProvider, ChartViewDelegate, DateDelegate {
  
    @IBAction func dateBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showCalender", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController {
            if let topController = destination.topViewController as? CalanderForActivityController {
                topController.delegate = self
                if let date = self.date {
                    topController.date = date
                } else {
                    topController.date = Date()
                }

            }
        }
    }
 
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var combinedCharts: BarChartView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var datePicker: UIView!
    @IBOutlet weak var chartTitle: UILabel!
    @IBOutlet weak var weekelyGoalBarChart: BarChartView!
    @IBOutlet weak var individualWeelyGoalChart: BarChartView!
    @IBOutlet weak var monthlyGoalBarChart: BarChartView!
    @IBOutlet weak var individualMonthlyGoalChart: BarChartView!
    
    
    var date: Date?
    
    
//    lazy var mydatePicker: AirbnbDatePicker = {
//        let btn = AirbnbDatePicker()
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        btn.delegate = self
//        return btn
//    }()
    
    let secondColor = UIColor(red: 206/255, green: 19/255, blue: 54/255, alpha: 1)
    let thirdColor = UIColor(red: 255/255, green: 86/255, blue: 96/255, alpha: 1)
    let forthColor = UIColor(red: 149/255, green: 0/255, blue: 17/255, alpha: 1)
    
    
    let periodsOfDay = ["6am-12pm", "12pm - 6pm", "6pm - 12am", "12am -6am"]
    
    let weekDays = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
    
    let weeks = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5"]

    var lively = [Int]()
    var chiling = [Int]()
    var wandering = [Int]()
    
    var weeklyLively = [Int]()
    var weeklychiling = [Int]()
    var weeklywandering = [Int]()
    
    
    var monthlyLively = [Int]()
    var monthlychiling = [Int]()
    var monthlywandering = [Int]()
    
    
    var pet: Pet!
    
    weak var axisFormatDelegate: IAxisValueFormatter?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chartTitle.text = "Grouped Analysis"
        self.barChart.isHidden = true
        self.individualWeelyGoalChart.isHidden = true
        self.individualMonthlyGoalChart.isHidden = true
        
        self.dateBtn.setTitle("Select Date to show activity", for: .normal)

        barChart.delegate = self
        pieChart.delegate = self
        combinedCharts.delegate = self
        
        // Weekly Chart
        weekelyGoalBarChart.delegate = self
        individualWeelyGoalChart.delegate = self
        
        // Monthly Chart
        monthlyGoalBarChart.delegate = self
        individualMonthlyGoalChart.delegate = self
        
        if let currentPet = self.pet, let name = currentPet.name {
            barChart.noDataText = "No activity data available for \(name)"
            combinedCharts.noDataText = "No activity data available for \(name)"
            pieChart.noDataText = "No activity data available for \(name)"
            
            // weekly
            weekelyGoalBarChart.noDataText = "No activity data available for \(name)"
            individualWeelyGoalChart.noDataText = "No activity data available for \(name)"
            
            // monthly
            
            monthlyGoalBarChart.noDataText = "No activity data available for \(name)"
            individualMonthlyGoalChart.noDataText = "No activity data available for \(name)"
        } else {
            barChart.noDataText = "No activity data available"
            combinedCharts.noDataText = "No activity data available"
            pieChart.noDataText = "No activity data available"
            
            
            weekelyGoalBarChart.noDataText = "No activity data available"
            individualWeelyGoalChart.noDataText = "No activity data available"
            
            // monthly
            
            monthlyGoalBarChart.noDataText = "No activity data available"
            individualMonthlyGoalChart.noDataText = "No activity data available"
        }
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        if let date = self.date, let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date), let pet = self.pet {
            
            let startDate = Int(date.timeIntervalSince1970)
            let tomorrowDate = Int(tomorrow.timeIntervalSince1970)
            
            // API Request for Today
            APIRepository.instance.getActivityMonitorData(pet.id, startDate: startDate, endDate: tomorrowDate, groupedBy: 0) { (error, data) in
                if error == nil, let data =  data ,let activities = data.activities {
                    
                    var chilling = [Int]()
                    var wandering = [Int]()
                    var lively = [Int]()
                    
                    
                    for activity in activities {
                        let chiling = activity.chilling
                        let wanderingg = activity.wandering
                        let livelyy = activity.lively
                        chilling.append(chiling)
                        wandering.append(wanderingg)
                        lively.append(livelyy)
                    }
                    
                    
                    let sum =  chilling.reduce(0, +)
                    let totalChiling = sum / 60
                    
                    let sumW =  wandering.reduce(0, +)
                    let totalWandering = sumW / 60
                    
                    let sumC = lively.reduce(0, +)
                    let totalLively = sumC / 60
                    
                    
                    chilling.enumerated().forEach { index, value in
                        chilling[index] = value / 60
                    }
                    
                    wandering.enumerated().forEach { index, value in
                        wandering[index] = value / 60
                    }
                    lively.enumerated().forEach { index, value in
                        lively[index] = value / 60
                    }
                    
                    self.lively = lively
                    self.chiling = chilling
                    self.wandering = wandering
                    
                    if totalChiling > 0, totalWandering > 0 , totalLively > 0 {
                        self.pieChartUpdate(firstvalue: totalChiling, secondValue: totalWandering, thirdValue: totalLively)
                        self.combinedChartView(myxaxis: self.periodsOfDay, lively: chilling, chiling: wandering, wandering: lively, chart: self.combinedCharts)
                    } else {
                    }
                } else {

                }
            }
            
            guard let startOfWeekDay = date.startOfWeek else {return}
            guard let endOfTheWeek = date.endOfWeek else {return}
            guard let endOfTheWeekWithAddedDay = Calendar.current.date(byAdding: .day, value: 1, to: endOfTheWeek) else {return}
            
            
        
            let startOfWeekInTimeInterval = Int(startOfWeekDay.timeIntervalSince1970)
            let endOfWeekInTimeInterval = Int(endOfTheWeekWithAddedDay.timeIntervalSince1970)

            
            
            APIRepository.instance.getActivityMonitorData(pet.id, startDate: startOfWeekInTimeInterval, endDate: endOfWeekInTimeInterval, groupedBy: 1) { (error, data) in
                if error == nil, let data = data, let activities = data.activities {
                    
                    
                    var chilling = [Int]()
                    var wandering = [Int]()
                    var lively = [Int]()
                    
                    
                    for activity in activities {
                        let chiling = activity.chilling
                        let wanderingg = activity.wandering
                        let livelyy = activity.lively
                        chilling.append(chiling)
                        wandering.append(wanderingg)
                        lively.append(livelyy)
                    }
                    
                    self.weeklyLively = lively
                    self.weeklywandering = wandering
                    self.weeklyLively = lively
                    
                      self.combinedChartView(myxaxis: self.weekDays, lively: chilling, chiling: wandering, wandering: lively, chart: self.weekelyGoalBarChart)

                            
        
                    
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            


            guard let startOfMonth = date.getThisMonthStart() else {return}
            
             guard let endOfMonth = date.getThisMonthStart() else {return}

            guard let nextDayOfEndOfMonth = Calendar.current.date(byAdding: .day, value: 1, to: endOfMonth) else {return}
                
                let startOfMonthDateInterval = Int(startOfMonth.timeIntervalSince1970)
                let tomorrowMonthDateInterval = Int(nextDayOfEndOfMonth.timeIntervalSince1970)
            
            
            
            APIRepository.instance.getActivityMonitorData(pet.id, startDate: startOfMonthDateInterval, endDate: tomorrowMonthDateInterval, groupedBy: 2) { (error, data) in
                if error == nil, let activities = data?.activities {
                    
                    var chilling = [Int]()
                    var wandering = [Int]()
                    var lively = [Int]()
                    
                    
                    for activity in activities {
                        let chiling = activity.chilling
                        let wanderingg = activity.wandering
                        let livelyy = activity.lively
                        chilling.append(chiling)
                        wandering.append(wanderingg)
                        lively.append(livelyy)
                    }
                    
                    self.monthlyLively = lively
                    self.monthlywandering = wandering
                    self.monthlychiling = chilling
                    self.combinedChartView(myxaxis: self.weeks, lively: chilling, chiling: wandering, wandering: lively, chart: self.monthlyGoalBarChart)

                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM dd, yyy"
            let result = formatter.string(from: date)
            self.dateBtn.setTitle(result, for: .normal)
        } else {

        }
    }
    
    
    func date(date: Date) {
        self.date = date
    }
    
    


    func barChartUpdate(myxaxis: [String], values: [Int], color: UIColor, dateSetLabel: String, barChartt: BarChartView) {
        
        barChartt.backgroundColor = UIColor.white
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<values.count {
            let dataEntry = BarChartDataEntry(x: Double(i) , y: Double(values[i]))
            dataEntries.append(dataEntry)
        }

        let xaxis = barChartt.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        xaxis.labelPosition = .bottom
//        xaxis.centerAxisLabelsEnabled = true
        xaxis.granularityEnabled = true
        xaxis.granularity = 1.0
        
        xaxis.drawAxisLineEnabled = false
        xaxis.drawGridLinesEnabled = false
        xaxis.valueFormatter = IndexAxisValueFormatter(values: myxaxis)
      
    
        
        barChartt.barData?.highlightEnabled = false
        barChartt.isUserInteractionEnabled = false
        
        

        barChartt.rightAxis.drawLabelsEnabled = false
        barChartt.rightAxis.drawAxisLineEnabled = false
        barChartt.rightAxis.drawGridLinesEnabled = false
        barChartt.rightAxis.drawTopYLabelEntryEnabled = false
        barChartt.leftAxis.drawGridLinesEnabled = false
        barChartt.leftAxis.drawLabelsEnabled = false
        barChartt.leftAxis.drawAxisLineEnabled = false
        
        
        
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1.0
        pFormatter.percentSymbol = " hrs"
        let formatter = DefaultValueFormatter(formatter: pFormatter)
        

        let dataSet = BarChartDataSet(values: dataEntries, label: dateSetLabel)
        
        let data = BarChartData(dataSets: [dataSet])
        data.setValueFormatter(formatter)
        
        barChartt.data?.highlightEnabled = false

        
        dataSet.colors = [color]
        barChartt.data = data
        barChartt.chartDescription?.text = ""
        //This must stay at end of function
        barChart.notifyDataSetChanged()
        
        barChartt.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)

    }
    
    
    func combinedChartView(myxaxis: [String], lively: [Int], chiling: [Int], wandering: [Int], chart: BarChartView) {
        // legand
        
        chart.chartDescription?.text = ""
        let legand = chart.legend
        legand.enabled = true
        legand.horizontalAlignment = .right
        legand.verticalAlignment = .top
        legand.orientation = .vertical
        legand.drawInside = true
        legand.yOffset = 10.0;
        legand.xOffset = 10.0;
        legand.yEntrySpace = 0.0;
        
        // xaxis
        let xaxis = chart.xAxis
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

        let yaxis = chart.leftAxis
        yaxis.spaceTop = 0.35
        yaxis.axisMinimum = 0
        yaxis.drawGridLinesEnabled = false
        chart.rightAxis.enabled = false
        
        
        //axisFormatDelegate = self

        
        // data entry
        
        var dataEntries: [BarChartDataEntry] = []
        var dataEntries1: [BarChartDataEntry] = []
        var dataEntries2: [BarChartDataEntry] = []
        
        
        for i in 0..<wandering.count {
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
        chart.xAxis.axisMinimum = Double(startYear)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        chart.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        chart.notifyDataSetChanged()
        chart.data = chartData
        chart.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)

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
    
    func pieChartUpdate(firstvalue: Int, secondValue: Int, thirdValue: Int) {
        self.pieChart.backgroundColor = UIColor.white
        let entry1 = PieChartDataEntry(value: Double(firstvalue), label: "Chiling")
        let entry2 = PieChartDataEntry(value: Double(secondValue), label: "Wandering")
        let entry3 = PieChartDataEntry(value: Double(thirdValue), label: "Lively")
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
        showActionSheet(barchart: self.barChart, cominedChart: self.combinedCharts, chiling: self.chiling, wandering: self.wandering, lively: self.lively, myaxiais: self.periodsOfDay)
    }
    
    @IBAction func changeModeForWeeklyChartPressed(_ sender: Any) {
        showActionSheet(barchart: individualWeelyGoalChart, cominedChart: weekelyGoalBarChart, chiling: self.weeklychiling, wandering: self.weeklywandering, lively: self.weeklyLively, myaxiais: self.weekDays)
    }
    
    @IBAction func changeModeForMonthlyChartPressed(_ sender: Any) {
        showActionSheet(barchart: individualMonthlyGoalChart, cominedChart: monthlyGoalBarChart, chiling: self.monthlychiling, wandering: self.monthlywandering, lively: self.monthlyLively, myaxiais: self.weeks)
    }
    
    
    func showActionSheet(barchart: BarChartView, cominedChart: BarChartView, chiling: [Int], wandering: [Int], lively: [Int], myaxiais: [String]) {
        let actionSheet = UIAlertController(title: "Change charts mode", message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let chiling = UIAlertAction(title: "Chilling", style: .default) { action in
            self.barChartUpdate(myxaxis: myaxiais, values: chiling, color: self.secondColor, dateSetLabel: "Chilling Analysis", barChartt: barchart)

            barchart.isHidden = false
            cominedChart.isHidden = true
            self.chartTitle.text = "Chilling Analysis"
        }
        
        let wandering = UIAlertAction(title: "Wandering", style: .default) { action in

            self.barChartUpdate(myxaxis: myaxiais, values: wandering, color: self.thirdColor, dateSetLabel: "Wandering Analysis", barChartt: barchart)
            barchart.isHidden = false
            cominedChart.isHidden = true
            self.chartTitle.text = "Wandering Analysis"
        }
        
        let lively = UIAlertAction(title: "Lively", style: .default) { action in
            self.barChartUpdate(myxaxis: myaxiais, values: lively, color: self.forthColor, dateSetLabel: "Lively Analysis", barChartt: barchart)
            barchart.isHidden = false
            cominedChart.isHidden = true
            self.chartTitle.text = "Lively Analysis"

        }
        
        let groupedChart = UIAlertAction(title: "Grouped data", style: .default) { action in
            barchart.isHidden = true
            cominedChart.isHidden = false
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

extension Date {
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 7, to: sunday)
    }

}

extension Date {
    
    func getLast6Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -6, to: self)
    }
    
    func getLast3Month() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -3, to: self)
    }
    
    func getYesterday() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
    
    func getLast7Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -7, to: self)
    }
    func getLast30Day() -> Date? {
        return Calendar.current.date(byAdding: .day, value: -30, to: self)
    }
    
    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
    
    // This Month Start
    func getThisMonthStart() -> Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)!
    }
    
    func getThisMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month += 1
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    //Last Month Start
    func getLastMonthStart() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    //Last Month End
    func getLastMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.day = 1
        components.day -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
}
