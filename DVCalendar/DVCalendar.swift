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
    
    
    private func setupComponentsInsideCalendarView() {
        setupCalendarScrollView()
    }
    
    private func setupCalendarScrollView() {
        //setupCalendarTitleViewWithDate(Int(todayDate["Month"]!), year: Int(todayDate["Year"]!))
        let strongMainScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        strongMainScrollView.contentSize = CGSizeMake(3 * self.view.bounds.width, self.view.bounds.height)
        strongMainScrollView.backgroundColor = UIColor.whiteColor()
        strongMainScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        strongMainScrollView.delegate = self
        strongMainScrollView.pagingEnabled = true
        view.addSubview(strongMainScrollView)
        mainScrollView = strongMainScrollView
        
        for i in 0...2 {
            createSubScrollViewWithFrameWithCenterDate(CGRect(x: CGFloat(i) * strongMainScrollView.bounds.width, y: 0, width: strongMainScrollView.bounds.width, height: strongMainScrollView.bounds.height), index: i)
        }
        mainScrollView.scrollRectToVisible(CGRect(x: mainScrollView.bounds.width, y: 0, width: mainScrollView.bounds.width, height: mainScrollView.bounds.height), animated: false)
    }
    
    private func createSubScrollViewWithFrameWithCenterDate(frame: CGRect, index: Int) {
        let subScrollView = UIScrollView(frame: frame)
        subScrollView.contentSize = CGSizeMake(mainScrollView.bounds.width, 3 * mainScrollView.bounds.height)
        subScrollView.backgroundColor = UIColor.clearColor()
        subScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        subScrollView.delegate = self
        subScrollView.pagingEnabled = true
        
        todayDate = DVCalendarAPI.getTodayDate()
        
        for j in 0...2 {
            let subView = UIView(frame: CGRect(x: 0, y: CGFloat(j) * subScrollView.bounds.height, width: subScrollView.bounds.width, height: subScrollView.bounds.height))
            subView.backgroundColor = UIColor.clearColor()
            subView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            var month = Int(todayDate["Month"]!) + (index-1)
            var year = Int(todayDate["Year"]!) + (j-1)
            
            let dateForTitle = DVCalendarAPI.getDateAfterAddNewDate(currentDay: Int(todayDate["Day"]!), currentMonth: Int(todayDate["Month"]!), currentYear: Int(todayDate["Year"]!), numberDayToAdd: 0, numberMonthToAdd: index-1, numberYearToAdd: j-1)
            
            month = Int(dateForTitle["Month"]!)
            year = Int(dateForTitle["Year"]!)
            
            let titleView = createCalendarTitleViewWithDate(month, year: year)
            subView.addSubview(titleView)
            
            subView.addConstraint(NSLayoutConstraint(item: titleView, attribute: .Top, relatedBy: .Equal, toItem: subView, attribute: .Top, multiplier: 1.0, constant: 0))
            subView.addConstraint(NSLayoutConstraint(item: titleView, attribute: .Left, relatedBy: .Equal, toItem: subView, attribute: .Left, multiplier: 1.0, constant: 0))
            subView.addConstraint(NSLayoutConstraint(item: titleView, attribute: .Right, relatedBy: .Equal, toItem: subView, attribute: .Right, multiplier: 1.0, constant: 0))
            subView.addConstraint(NSLayoutConstraint(item: titleView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: calendarTitleViewSize.height))
            
            
            let listDayView = createCalendarListDayViewWithFrameAndDate(frame: CGRect(x: 0, y: titleView.bounds.height, width: subScrollView.bounds.width, height: subScrollView.bounds.height), month: month, year: year)
            subView.addSubview(listDayView)
            
            subScrollView.addSubview(subView)
        }
        subScrollView.scrollRectToVisible(CGRect(x: 0, y: subScrollView.bounds.height, width: subScrollView.bounds.width, height: subScrollView.bounds.height), animated: false)
        
        mainScrollView.addSubview(subScrollView)
    }
    
    private func createCalendarTitleViewWithDate(month: Int, year: Int) -> CalendarTitleView {
        calendarTitleViewSize = CGSize(width: frame.width, height: frame.height/5)
        let strongTitleView = CalendarTitleView(frame: CGRect(x: 0, y: 0, width: calendarTitleViewSize.width, height: calendarTitleViewSize.height), month: month, year: year)
        return strongTitleView
    }
    
    private func createCalendarListDayViewWithFrameAndDate(frame frame: CGRect, month: Int, year: Int) -> UIView {
        let listDayView = UIView(frame: frame)
        let boxDaySize = CGSize(width: listDayView.bounds.width/7, height: listDayView.bounds.height/6)
        
        var firstDayOfMonthPosition = DVCalendarAPI.getDayOfWeek(day: 1, month: month, year: year)
        if firstDayOfMonthPosition == 1 { firstDayOfMonthPosition = 8 }
        
        var countMonthBefore = 2
        var countMonthNow = 1
        var countMonthAfter = 1
        
        let dateOfMonthBefore = DVCalendarAPI.getDateAfterAddNewDate(currentDay: 1, currentMonth: month, currentYear: year, numberDayToAdd: 0, numberMonthToAdd: -1, numberYearToAdd: 0)
        
        let amountDayOfMonthBefore = DVCalendarAPI.getNumberDaysInMonthOfYear(month: Int(dateOfMonthBefore["Month"]!), year: Int(dateOfMonthBefore["Year"]!))
        let amountDayOfCurrentMonth = DVCalendarAPI.getNumberDaysInMonthOfYear(month: month, year: year)
        
        
        for i in 0...5 {
            for j in 0...6 {
                let boxDay = BoxDay(frame: CGRect(x: CGFloat(j) * boxDaySize.width, y: CGFloat(i) * boxDaySize.height, width: boxDaySize.width, height: boxDaySize.height))
                
                var textDay = ""
                var dayValue = 0
                if countMonthBefore < firstDayOfMonthPosition {
                    dayValue = amountDayOfMonthBefore - (firstDayOfMonthPosition - countMonthBefore - 1)
                    countMonthBefore++
                    boxDay.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                } else {
                    if countMonthNow <= amountDayOfCurrentMonth {
                        dayValue = countMonthNow
                        countMonthNow++
                        boxDay.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    } else {
                        dayValue = countMonthAfter
                        countMonthAfter++
                        boxDay.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    }
                }
                textDay = "\(dayValue)"
                
                boxDay.setTitle(textDay, forState: UIControlState.Normal)
                listDayView.addSubview(boxDay)
            }
        }
        return listDayView
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
    let lineWidth: CGFloat = 4
    let lineColor = UIColor.randomColor()
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let linePath = UIBezierPath()
        linePath.moveToPoint(CGPoint(x: lineWidth, y: self.bounds.height - lineWidth - lineWidth/2))
        linePath.addLineToPoint(CGPoint(x: self.bounds.width - lineWidth - lineWidth/2, y: self.bounds.height - lineWidth - lineWidth/2))
        lineColor.setStroke()
        linePath.lineWidth = lineWidth
        linePath.stroke()
        linePath.closePath()
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
