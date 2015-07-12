//
//  DVCalendar.swift
//  DVCalendar
//
//  Created by Vinh Dang Duc on 7/10/15.
//  Copyright © 2015 Vinh Dang Duc. All rights reserved.
//

import UIKit

class DVCalendar: UIViewController {
    
    // MARK: - Properties
    
    weak var target: UIViewController!
    weak var calendarTitleView: CalendarTitleView!
    weak var mainScrollView: UIScrollView!
    var subScrollViewArray = [UIScrollView]()
    var calendarTitleViewArray = [CalendarTitleView]()
    var subViewArray = [UIView]()
    
    var frame: CGRect!
    
    var todayDate: [String:Int]!
    var calendarTitleViewSize: CGSize!
    
    
    
    // MARK: - Init methods
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(target: UIViewController, frame: CGRect) {
        super.init(nibName: nil, bundle: nil)
        self.target = target
        self.frame = frame
        
        setupMainView()
        setupComponentsInsideCalendarView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceRotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    // MARK: - Loading view states
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Setup views
    
    private func setupMainView() {
        view.frame = frame
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clearColor()
    }
    
    private func setupCalendarTitleViewWithDate(month: Int, year: Int) {
        calendarTitleViewSize = CGSize(width: frame.width, height: frame.height/5)
        let strongTitleView = CalendarTitleView(frame: CGRect(x: 0, y: 0, width: calendarTitleViewSize.width, height: calendarTitleViewSize.height), month: month, year: year)
        view.addSubview(strongTitleView)
        
        view.addConstraint(NSLayoutConstraint(item: strongTitleView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: strongTitleView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: strongTitleView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: strongTitleView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: calendarTitleViewSize.height))
        
        calendarTitleView = strongTitleView
    }
    
    private func setupComponentsInsideCalendarView() {
        setupCalendarScrollView()
    }
    
    private func setupCalendarScrollView() {
        todayDate = DVCalendarAPI.getTodayDate()
        //setupCalendarTitleViewWithDate(Int(todayDate["Month"]!), year: Int(todayDate["Year"]!))
        let strongMainScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        strongMainScrollView.contentSize = CGSizeMake(3 * self.view.bounds.width, self.view.bounds.height)
        strongMainScrollView.backgroundColor = UIColor.whiteColor()
        strongMainScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        strongMainScrollView.delegate = self
        view.addSubview(strongMainScrollView)
        mainScrollView = strongMainScrollView
        
        for i in 0...2 {
            
        }
    }
    
    private func createSubScrollViewWithFrameWithCenterDate(frame: CGRect, month: Int, year: Int) {
        
    }
    
    private func createSubViewWithFrameAndDate(subViewFrame subViewFrame: CGRect, month: Int, year: Int) -> UIView {
        let subView = UIView(frame: subViewFrame)
        return subView
    }
    
    // MARK: - Show/Hide views
    
    func show() {
        target.addChildViewController(self)
        target.view.addSubview(view)
        self.didMoveToParentViewController(target)
    }
    
    func hide() {
        view.hidden = true
    }
    
    // MARK: - Notification Center
    
    func deviceRotated() {
        if view.superview != nil {
            
        }
    }
}

extension DVCalendar: UIScrollViewDelegate {
    
}

//---------------------------------------------------------------//
//---------------------- CALENDARTITLEVIEW ----------------------//
//---------------------------------------------------------------//

class CalendarTitleView: UIView {
    
    var dayLabelArray = [UILabel]()
    
    let margin: CGFloat = 10
    let distanceBetweenDayButtons = 0
    
    var monthValue = 0
    var yearValue = 0
    
    let monthTextFontSize: CGFloat = 17
    let yearTextFontSize: CGFloat = 20
    let dayLabelFontSize: CGFloat = 11
    
    let lineWidth: CGFloat = 4
    let lineColor = UIColor.randomColor()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setNeedsDisplay()
    }
    
    init(frame: CGRect, month: Int, year: Int) {
        super.init(frame: frame)
        monthValue = month
        yearValue = year
        setupView()
        setNeedsDisplay()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.clearColor()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func drawRect(rect: CGRect) {
        let cornerPath = UIBezierPath(roundedRect: rect, byRoundingCorners: [UIRectCorner.TopLeft, UIRectCorner.TopRight], cornerRadii: CGSize(width: 8, height: 5))
        cornerPath.addClip()
        cornerPath.closePath()
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillRect(context, rect)
        
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
        
        let halfHeight = self.bounds.height/2
        
        addMonthLabel()
        addYearLabel()
        
        let dayArray = ["M", "T", "W", "T", "F", "S", "S"]
        
        for i in 0...6 {
            let dayLabelSize = CGSize(width: self.bounds.width/7, height: halfHeight - lineWidth - lineWidth/2)
            let dayLabelOriginPoint = CGPoint(x: CGFloat(i) * dayLabelSize.width, y: halfHeight)
            let dayLabel = UILabel(frame: CGRect(origin: dayLabelOriginPoint, size: dayLabelSize))
            dayLabel.text = dayArray[i]
            dayLabel.font = UIFont(name: "Helvetica", size: dayLabelFontSize)
            dayLabel.textAlignment = .Center
            self.addSubview(dayLabel)
            dayLabelArray.append(dayLabel)
        }
        
//        for i in 0...6 {
//            let dayLabel = dayLabelArray[i] as UILabel
//            addConstraintForDayLabelAtIndex(index: i, label: dayLabel)
//        }
        
        let linePath = UIBezierPath()
        linePath.moveToPoint(CGPoint(x: lineWidth, y: self.bounds.height - lineWidth - lineWidth/2))
        linePath.addLineToPoint(CGPoint(x: self.bounds.width - lineWidth, y: self.bounds.height - lineWidth - lineWidth/2))
        lineColor.setStroke()
        linePath.lineWidth = lineWidth
        linePath.stroke()
        linePath.closePath()
    }
    
    private func addMonthLabel() {
        let halfHeight = self.bounds.height/2
        
        let monthText: NSString = DVCalendarAPI.convertMonthValueToText(monthValue: monthValue) as NSString
        let monthTextSize: CGSize = monthText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(monthTextFontSize)])
        
        let monthLabel = UILabel(frame: CGRect(x: margin, y: margin, width: monthTextSize.width, height: halfHeight - margin))
        monthLabel.text = monthText as String
        monthLabel.font = UIFont(name: "Futura", size: monthTextFontSize)
        monthLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(monthLabel)
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: monthLabel.bounds.width))
        self.addConstraint(NSLayoutConstraint(item: monthLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: monthLabel.bounds.height))
    }
    
    private func addYearLabel() {
        let halfHeight = self.bounds.height/2
        
        let yearText: NSString = String(yearValue) as NSString
        let yearTextSize: CGSize = yearText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(yearTextFontSize)])
        
        let yearLabel = UILabel(frame: CGRect(x: self.bounds.width - margin - yearTextSize.width, y: margin, width: yearTextSize.width, height: halfHeight - margin))
        yearLabel.text = yearText as String
        yearLabel.font = UIFont(name: "Helvetica", size: yearTextFontSize)
        yearLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(yearLabel)
        
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: yearLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -margin))
        self.addConstraint(NSLayoutConstraint(item: yearLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: margin))
        self.addConstraint(NSLayoutConstraint(item: yearLabel, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: yearLabel.bounds.width))
        self.addConstraint(NSLayoutConstraint(item: yearLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: yearLabel.bounds.height))
    }
    
//    private func addConstraintForDayLabelAtIndex(index index: Int, label: UILabel) {
//        label.translatesAutoresizingMaskIntoConstraints = false
//        if index == 0 {
//            self.addConstraint(NSLayoutConstraint(item: label, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
//            for i in 1...6 {
//                let listDayLabel = dayLabelArray[i] as UILabel
//                listDayLabel.translatesAutoresizingMaskIntoConstraints = false
//                self.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: listDayLabel, attribute: .Width, multiplier: 1.0, constant: 0))
//            }
//        } else if index == 6 {
//            self.addConstraint(NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
//        }
//        
//        if index > 0 {
//            let firstDayLabel = dayLabelArray[0] as UILabel
//            self.addConstraint(NSLayoutConstraint(item: label, attribute: .Width, relatedBy: .Equal, toItem: firstDayLabel, attribute: .Width, multiplier: 1.0, constant: 0))
//        }
//        
//        if index < 6 {
//            let nextDayLabel = dayLabelArray[index+1] as UILabel
//            nextDayLabel.translatesAutoresizingMaskIntoConstraints = false
//            self.addConstraint(NSLayoutConstraint(item: label, attribute: .Right, relatedBy: .Equal, toItem: nextDayLabel, attribute: .Right, multiplier: 1.0, constant: 0))
//        }
//
//        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -(lineWidth + lineWidth/2)))
//        self.addConstraint(NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: label.bounds.height))
//    }
}

//---------------------------------------------------------------//
//------------------------ DVCALENDARAPI ------------------------//
//---------------------------------------------------------------//

class DVCalendarAPI {

    static func getNumberDaysInMonthOfYear(month month: Int, year: Int) -> Int {
        if month < 1 || month > 12 || year < 0 { return 0 }
        else {
            switch month {
            case 1, 3, 5, 7, 8, 10, 12:
                return 31
            case 4, 6, 9, 11:
                return 30
            case 2:
                if (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0) {
                    return 29
                } else {
                    return 28
                }
            default:
                return 0
            }
        }
    }
    
    static func getDayOfWeek(day day: Int, month: Int, year: Int)->Int {
        let today = "\(year)-\(month)-\(day)"
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let todayDate = formatter.dateFromString(today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let myComponents = myCalendar.components(NSCalendarUnit.Weekday, fromDate: todayDate)
            let weekDay = myComponents.weekday
            return weekDay
        } else {
            return 0
        }
    }
    
    static func getTodayDate() -> [String:Int] {
        let todayDate = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let component = calendar!.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: todayDate)
        return [
            "Day" : component.day,
            "Month" : component.month,
            "Year" : component.year
        ]
    }
    
    static func convertMonthValueToText(monthValue monthValue: Int) -> String {
        let monthArray = ["January","February","March","April","May","June","July","August","September","October","November","December"]
        return monthArray[monthValue-1]
    }
    
    static func getDateAfterAddNewDate(currentDay currentDay: Int, currentMonth: Int, currentYear: Int, numberDayToAdd: Int, numberMonthToAdd: Int, numberYearToAdd: Int) -> [String:Int]! {
        let calendar = NSCalendar.currentCalendar()
        let currentDateComponent = NSDateComponents()
        currentDateComponent.day = currentDay
        currentDateComponent.month = currentMonth
        currentDateComponent.year = currentYear
        let currentDate = calendar.dateFromComponents(currentDateComponent)
        
        let featureDateToAdd = NSDateComponents()
        featureDateToAdd.day = numberDayToAdd
        featureDateToAdd.month = numberMonthToAdd
        featureDateToAdd.year = numberYearToAdd
        
        let featureDate = calendar.dateByAddingComponents(featureDateToAdd, toDate: currentDate!, options: [])
        let featureDateComponent = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: featureDate!)
        return [
            "Day" : featureDateComponent.day,
            "Month" : featureDateComponent.month,
            "Year" : featureDateComponent.year
        ]
    }

}

class BoxDay: UIButton {
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
    }
}

//---------------------------------------------------------------//
//------------------------- EXTENSION ---------------------------//
//---------------------------------------------------------------//

extension UIColor {
    static func randomColor() -> UIColor {
        let r = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let g = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let b = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
