//
//  DVCalendar.swift
//  DVCalendar
//
//  Created by Vinh Dang Duc on 7/10/15.
//  Copyright © 2015 Vinh Dang Duc. All rights reserved.
//

import UIKit

@objc protocol DVCalendarDelegate {
    optional func clickedOnDate(day: Int, month: Int, year: Int)
}

class DVCalendar: UIViewController {
    
    // MARK: - Properties
    
    weak var target: UIViewController!
    weak var titleView: CalendarTitleView!
    weak var mainScrollView: UIScrollView!
    weak var delegate: DVCalendarDelegate?
    
    var subScrollViewArray = [UIScrollView]()
    var subViewArray: [Int:[UIView]] = [
        0 : [],
        1 : [],
        2 : []
    ]
    var calendarSubViewDataArray = [DVCalendarSubViewData]()
    
    var frame: CGRect!
    
    var todayDate: [String:Int]!
    var calendarTitleViewSize: CGSize!
    
    var mainScrollViewIndex = 1
    var subScrollViewIndex = 1
    
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
        
        
    }
    
    // MARK: - Loading view states
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceRotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    // MARK: - Setup views
    
    private func setupMainView() {
        view.frame = frame
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clearColor()
    }
    
    
    private func setupComponentsInsideCalendarView() {
        setupCalendarTitleView()
        setupCalendarScrollView()
    }
    
    private func setupCalendarTitleView() {
        let todayDate = DVCalendarAPI.shareInstance.getTodayDate()
        calendarTitleViewSize = CGSize(width: frame.width, height: frame.height/5)
        let strongTitleView = createCalendarTitleViewWithFrameAndDate(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: calendarTitleViewSize), month: Int(todayDate["Month"]!), year: Int(todayDate["Year"]!))
        view.addSubview(strongTitleView)
        
        view.addConstraint(NSLayoutConstraint(item: strongTitleView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: strongTitleView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: strongTitleView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: strongTitleView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: calendarTitleViewSize.height))
        
        titleView = strongTitleView
    }
    
    private func setupCalendarScrollView() {
        //setupCalendarTitleViewWithDate(Int(todayDate["Month"]!), year: Int(todayDate["Year"]!))
        let strongMainScrollView = UIScrollView(frame: CGRect(x: 0, y: calendarTitleViewSize.height, width: self.view.bounds.width, height: self.view.bounds.height - calendarTitleViewSize.height))
        strongMainScrollView.contentSize = CGSizeMake(3 * self.view.bounds.width, self.view.bounds.height - calendarTitleViewSize.height)
        strongMainScrollView.backgroundColor = UIColor.whiteColor()
        strongMainScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        strongMainScrollView.delegate = self
        strongMainScrollView.pagingEnabled = true
        strongMainScrollView.showsHorizontalScrollIndicator = false
        strongMainScrollView.showsVerticalScrollIndicator = false
        
        view.addSubview(strongMainScrollView)
        mainScrollView = strongMainScrollView
        
        todayDate = DVCalendarAPI.shareInstance.getTodayDate()
        
        for i in 0...2 {
            createSubScrollViewWithFrameAndRootDate(CGRect(x: CGFloat(i) * strongMainScrollView.bounds.width, y: 0, width: strongMainScrollView.bounds.width, height: strongMainScrollView.bounds.height), rootMonth: Int(todayDate["Month"]!), rootYear: Int(todayDate["Year"]!), index: i)
        }
        mainScrollView.scrollRectToVisible(CGRect(x: mainScrollView.bounds.width, y: 0, width: mainScrollView.bounds.width, height: mainScrollView.bounds.height), animated: false)
    }
    
    private func createSubScrollViewWithFrameAndRootDate(frame: CGRect, rootMonth: Int, rootYear: Int, index: Int) {
        let subScrollView = UIScrollView(frame: frame)
        subScrollView.contentSize = CGSizeMake(mainScrollView.bounds.width, 3 * mainScrollView.bounds.height)
        subScrollView.backgroundColor = UIColor.clearColor()
        subScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        subScrollView.delegate = self
        subScrollView.pagingEnabled = true
        subScrollView.showsHorizontalScrollIndicator = false
        subScrollView.showsVerticalScrollIndicator = false
        
        for j in 0...2 {
            var month = rootMonth
            var year = rootYear
            
            let dateForTitle = DVCalendarAPI.shareInstance.getDateAfterAddNewDate(currentDay: 1, currentMonth: month, currentYear: year, numberDayToAdd: 0, numberMonthToAdd: index-1, numberYearToAdd: j-1)
            
            month = Int(dateForTitle["Month"]!)
            year = Int(dateForTitle["Year"]!)
            
            createSubViewForSubScrollView(frame: CGRect(x: 0, y: CGFloat(j) * subScrollView.bounds.height, width: subScrollView.bounds.width, height: subScrollView.bounds.height - 10), month: month, year: year, subScrollView: subScrollView, subScrollViewIndex: j, mainScrollViewIndex: index)
        }
        subScrollView.scrollRectToVisible(CGRect(x: 0, y: subScrollView.bounds.height, width: subScrollView.bounds.width, height: subScrollView.bounds.height), animated: false)
        
        mainScrollView.addSubview(subScrollView)
        subScrollViewArray.insert(subScrollView, atIndex: index)
    }
    
    private func createSubViewForSubScrollView(frame frame: CGRect, month: Int, year: Int, subScrollView: UIScrollView, subScrollViewIndex: Int, mainScrollViewIndex: Int) {
        let subView = createCalendarListDayViewWithFrameAndDate(frame: frame, month: month, year: year)
        subView.backgroundColor = UIColor.whiteColor()
        subView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        subScrollView.addSubview(subView)
        subViewArray[mainScrollViewIndex]!.insert(subView, atIndex: subScrollViewIndex)
        
        var checkExist = false

        
        for subData in calendarSubViewDataArray {
            if subData.mainScrollViewIndex == mainScrollViewIndex && subData.subScrollViewIndex == subScrollViewIndex {
                checkExist = true
                break
            }
        }
        
        if !checkExist {
            let data = DVCalendarSubViewData(subScrollViewIndex: subScrollViewIndex, mainScrollViewIndex: mainScrollViewIndex, day: 0, month: month, year: year)
            
            if mainScrollViewIndex == 0 {
                calendarSubViewDataArray.insert(data, atIndex: 0)
                
            } else {
                calendarSubViewDataArray.append(data)
            }
            
        }
    }
    
    private func createCalendarTitleViewWithFrameAndDate(frame frame: CGRect, month: Int, year: Int) -> CalendarTitleView {
//        calendarTitleViewSize = CGSize(width: frame.width, height: frame.height/5)
        let strongTitleView = CalendarTitleView(frame: frame, month: month, year: year)
        return strongTitleView
    }
    
    private func createCalendarListDayViewWithFrameAndDate(frame frame: CGRect, month: Int, year: Int) -> UIView {
        let listDayView = UIView(frame: frame)
        let boxDaySize = CGSize(width: listDayView.bounds.width/7, height: listDayView.bounds.height/6)
        
        var firstDayOfMonthPosition = DVCalendarAPI.shareInstance.getDayOfWeek(day: 1, month: month, year: year)
        if firstDayOfMonthPosition == 1 { firstDayOfMonthPosition = 8 }
        
        var countMonthBefore = 2
        var countMonthNow = 1
        var countMonthAfter = 1
        
        let dateOfMonthBefore = DVCalendarAPI.shareInstance.getDateAfterAddNewDate(currentDay: 1, currentMonth: month, currentYear: year, numberDayToAdd: 0, numberMonthToAdd: -1, numberYearToAdd: 0)
        
        let amountDayOfMonthBefore = DVCalendarAPI.shareInstance.getNumberDaysInMonthOfYear(month: Int(dateOfMonthBefore["Month"]!), year: Int(dateOfMonthBefore["Year"]!))
        let amountDayOfCurrentMonth = DVCalendarAPI.shareInstance.getNumberDaysInMonthOfYear(month: month, year: year)
        
        let todayDate = DVCalendarAPI.shareInstance.getTodayDate()
        
        for i in 0...5 {
            for j in 0...6 {
                let boxDay = BoxDay(frame: CGRect(x: CGFloat(j) * boxDaySize.width, y: CGFloat(i) * boxDaySize.height, width: boxDaySize.width, height: boxDaySize.height))
                
                var textDay = ""
                var dayValue = 0
                var monthValue = 0
                var yearValue = 0
                if countMonthBefore < firstDayOfMonthPosition {
                    dayValue = amountDayOfMonthBefore - (firstDayOfMonthPosition - countMonthBefore - 1)
                    monthValue = month == 1 ? 12 : month - 1
                    yearValue = month == 1 ? year - 1 : year
                    countMonthBefore++
                    boxDay.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                } else {
                    if countMonthNow <= amountDayOfCurrentMonth {
                        dayValue = countMonthNow
                        monthValue = month
                        yearValue = year
                        countMonthNow++
                        boxDay.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    } else {
                        dayValue = countMonthAfter
                        monthValue = month == 12 ? 1 : month + 1
                        yearValue = month == 12 ? year + 1 : year
                        countMonthAfter++
                        boxDay.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
                    }
                }
                
                if dayValue == Int(todayDate["Day"]!) && monthValue == Int(todayDate["Month"]!) && yearValue == Int(todayDate["Year"]!) {
                    boxDay.addTodayBackground(color: UIColor(red: 0.361, green: 0.816, blue: 0.949, alpha: 1.0), subColor: UIColor(red: 0.604, green: 0.898, blue: 0.988, alpha: 1.0), bgType: .Arc)
                }
                
                textDay = "\(dayValue)"
                
                boxDay.day = dayValue
                boxDay.month = monthValue
                boxDay.year = yearValue
                
                boxDay.setTitle(textDay, forState: UIControlState.Normal)
                boxDay.titleLabel?.font = UIFont(name: "Helvetica", size: 15)
                boxDay.addTarget(self, action: Selector("handleClickedOnBoxDay:"), forControlEvents: UIControlEvents.TouchUpInside)
                
                listDayView.addSubview(boxDay)
            }
        }
        return listDayView
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
            titleView.setNeedsDisplay()
            
//            for subview in mainScrollView.subviews {
//                subview.removeFromSuperview()
//            }
//            
//            mainScrollView.removeFromSuperview()
//            mainScrollView = nil
//            setupCalendarScrollView()
        }
    }
    
    // MARK: - BoxDay Actions
    
    func handleClickedOnBoxDay(boxDay: BoxDay) {
        delegate?.clickedOnDate?(boxDay.day, month: boxDay.month, year: boxDay.year)
    }
}

extension DVCalendar: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentMainScrollViewIndex = mainScrollView.contentOffset.x/mainScrollView.bounds.width
        if currentMainScrollViewIndex > 2 || currentMainScrollViewIndex < 0 || currentMainScrollViewIndex % 1 != 0 { return }
        
        let subScroll = subScrollViewArray[Int(round(currentMainScrollViewIndex))]
        let currentSubScrollViewIndex = subScroll.contentOffset.y/subScroll.bounds.height
        
        if currentMainScrollViewIndex % 1 == 0 {
            refreshTheTitleViewByIndexes(subScrollIndex: Int(round(currentSubScrollViewIndex)), mainScrollIndex: Int(round(currentMainScrollViewIndex)))
            refreshAllScrollViewAccordingToIndexes(subScrollIndex: Int(round(currentSubScrollViewIndex)), mainScrollIndex: Int(round(currentMainScrollViewIndex)))
        }
    }
    
    func refreshTheTitleViewByIndexes(subScrollIndex subScrollIndex: Int, mainScrollIndex: Int) {
        for data in calendarSubViewDataArray {
            if data.subScrollViewIndex == subScrollIndex && data.mainScrollViewIndex == mainScrollIndex {
                titleView.refreshDateLabelsByNewValue(month: data.month, year: data.year, animate: true)
                break
            }
        }
    }
    
    func refreshAllScrollViewAccordingToIndexes(subScrollIndex subScrollIndex: Int, mainScrollIndex: Int) {
        if self.subScrollViewIndex != subScrollIndex {
            switch subScrollIndex {
            case 0:
                for i in 0...2 {
                    refreshSubViewsInSubScrollViewAccordingTo(subScrollIndex: subScrollIndex, mainScrollIndex: i, viewToRemoveIndex: 2)
                }
            case 2:
                for i in 0...2 {
                    refreshSubViewsInSubScrollViewAccordingTo(subScrollIndex: subScrollIndex, mainScrollIndex: i, viewToRemoveIndex: 0)
                }
            default:
                break
            }
        } else if self.mainScrollViewIndex != mainScrollIndex {
            switch mainScrollIndex {
            case 0:
                refreshSubScrollViewAccordingTo(mainScrollIndex: mainScrollIndex, subScrollViewToRemoveIndex: 2)
                break
            case 2:
                refreshSubScrollViewAccordingTo(mainScrollIndex: mainScrollIndex, subScrollViewToRemoveIndex: 0)
            default:
                break
            }
        }
        
    }
    
    private func refreshSubViewsInSubScrollViewAccordingTo(subScrollIndex subScrollIndex: Int, mainScrollIndex: Int, viewToRemoveIndex: Int) {
                let firstSubViewToReplace = getCalendarSubviewDataByIndexes(mainScrollViewIndex: mainScrollIndex, subScrollViewIndex: 0)
                let secondSubViewToReplace = getCalendarSubviewDataByIndexes(mainScrollViewIndex: mainScrollIndex, subScrollViewIndex: 1)
                let thirdSubViewToReplace = getCalendarSubviewDataByIndexes(mainScrollViewIndex: mainScrollIndex, subScrollViewIndex: 2)
                
                switch viewToRemoveIndex {
                case 0:
                    firstSubViewToReplace?.setNewDate(day: secondSubViewToReplace!.day, month: secondSubViewToReplace!.month, year: secondSubViewToReplace!.year)
                    secondSubViewToReplace?.setNewDate(day: thirdSubViewToReplace!.day, month: thirdSubViewToReplace!.month, year: thirdSubViewToReplace!.year)
                case 2:
                    thirdSubViewToReplace?.setNewDate(day: secondSubViewToReplace!.day, month: secondSubViewToReplace!.month, year: secondSubViewToReplace!.year)
                    secondSubViewToReplace?.setNewDate(day: firstSubViewToReplace!.day, month: firstSubViewToReplace!.month, year: firstSubViewToReplace!.year)
                default:
                    break
                }
        
                let viewToRemove = subViewArray[mainScrollIndex]![viewToRemoveIndex] as UIView
                viewToRemove.removeFromSuperview()
                subViewArray[mainScrollIndex]?.removeAtIndex(viewToRemoveIndex)
                
                for viewToMove in subViewArray[mainScrollIndex]! {
                    if viewToRemoveIndex == 0 {
                        viewToMove.frame.origin = CGPoint(x: viewToMove.frame.origin.x, y: viewToMove.frame.origin.y - 10 - viewToMove.bounds.height)
                    } else if viewToRemoveIndex == 2 {
                        viewToMove.frame.origin = CGPoint(x: viewToMove.frame.origin.x, y: viewToMove.frame.origin.y + 10 + viewToMove.bounds.height)
                    }
                }
                
                let subScrollViewToAdd = subScrollViewArray[mainScrollIndex]
                
                let data = getCalendarSubviewDataByIndexes(mainScrollViewIndex: mainScrollIndex, subScrollViewIndex: subScrollIndex)
                
                let month = data!.month
                let year = viewToRemoveIndex == 0 ? data!.year + 1 : data!.year - 1
                
                if viewToRemoveIndex == 0 {
                    createSubViewForSubScrollView(frame: CGRect(x: 0, y: subScrollViewToAdd.frame.height*2, width: subScrollViewToAdd.frame.width, height: subScrollViewToAdd.frame.height - 10), month: month, year: year, subScrollView: subScrollViewToAdd, subScrollViewIndex: 2, mainScrollViewIndex: mainScrollIndex)
                    
                    let newData = DVCalendarSubViewData(subScrollViewIndex: 2, mainScrollViewIndex: mainScrollIndex, day: 0, month: month, year: year)
                    let dataToChange = getCalendarSubviewDataByIndexes(mainScrollViewIndex: mainScrollIndex, subScrollViewIndex: 2)
                    dataToChange?.setNewData(newData)
                    
                } else if viewToRemoveIndex == 2 {
                    createSubViewForSubScrollView(frame: CGRect(x: 0, y: 0, width: subScrollViewToAdd.frame.width, height: subScrollViewToAdd.frame.height - 10), month: month, year: year, subScrollView: subScrollViewToAdd, subScrollViewIndex: 0, mainScrollViewIndex: mainScrollIndex)
                    
                    let newData = DVCalendarSubViewData(subScrollViewIndex: 0, mainScrollViewIndex: mainScrollIndex, day: 0, month: month, year: year)
                    let dataToChange = getCalendarSubviewDataByIndexes(mainScrollViewIndex: mainScrollIndex, subScrollViewIndex: 0)
                    dataToChange?.setNewData(newData)
                }
                subScrollViewToAdd.scrollRectToVisible(CGRect(x: 0, y: subScrollViewToAdd.bounds.height, width: subScrollViewToAdd.bounds.width, height: subScrollViewToAdd.bounds.height), animated: false)
    }
    
    private func refreshSubScrollViewAccordingTo(mainScrollIndex mainScrollIndex: Int, subScrollViewToRemoveIndex: Int) {
        let rootData = getCalendarSubviewDataByIndexes(mainScrollViewIndex: mainScrollIndex, subScrollViewIndex: 1)

        switch subScrollViewToRemoveIndex {
        case 0:
            for i in 0...2 {
                let firstSubViewData = getCalendarSubviewDataByIndexes(mainScrollViewIndex: 0, subScrollViewIndex: i)
                let secondSubViewData = getCalendarSubviewDataByIndexes(mainScrollViewIndex: 1, subScrollViewIndex: i)
                firstSubViewData?.setNewDate(day: secondSubViewData!.day, month: secondSubViewData!.month, year: secondSubViewData!.year)
            }
            
            for i in 0...2 {
                let firstSubViewData = getCalendarSubviewDataByIndexes(mainScrollViewIndex: 1, subScrollViewIndex: i)
                let secondSubViewData = getCalendarSubviewDataByIndexes(mainScrollViewIndex: 2, subScrollViewIndex: i)
                firstSubViewData?.setNewDate(day: secondSubViewData!.day, month: secondSubViewData!.month, year: secondSubViewData!.year)
            }
            break
        case 2:
            for i in 0...2 {
                let firstSubViewData = getCalendarSubviewDataByIndexes(mainScrollViewIndex: 2, subScrollViewIndex: i)
                let secondSubViewData = getCalendarSubviewDataByIndexes(mainScrollViewIndex: 1, subScrollViewIndex: i)
                
                firstSubViewData?.setNewDate(day: secondSubViewData!.day, month: secondSubViewData!.month, year: secondSubViewData!.year)
            }
            
            for i in 0...2 {
                let firstSubViewData = getCalendarSubviewDataByIndexes(mainScrollViewIndex: 1, subScrollViewIndex: i)
                let secondSubViewData = getCalendarSubviewDataByIndexes(mainScrollViewIndex: 0, subScrollViewIndex: i)
                firstSubViewData?.setNewDate(day: secondSubViewData!.day, month: secondSubViewData!.month, year: secondSubViewData!.year)
            }
            break
        default:
            break
        }
        
        let scrollViewToRemove = subScrollViewArray[subScrollViewToRemoveIndex]
        for subView in scrollViewToRemove.subviews {
            subView.removeFromSuperview()
        }
        scrollViewToRemove.removeFromSuperview()
        subScrollViewArray.removeAtIndex(subScrollViewToRemoveIndex)
        
        
        if subScrollViewToRemoveIndex == 0 {
            let arr1 = subViewArray[1]
            let arr2 = subViewArray[2]
            subViewArray[0] = arr1
            subViewArray[1] = arr2
            subViewArray[2]?.removeAll()
        } else if subScrollViewToRemoveIndex == 2 {
            let arr0 = subViewArray[0]
            let arr1 = subViewArray[1]
            subViewArray[2] = arr1
            subViewArray[1] = arr0
            subViewArray[0]?.removeAll()
        }
        
//        for data in calendarSubViewDataArray {
//            print(data.description())
//        }
//        print("-------------------")
        
        if subScrollViewToRemoveIndex == 0 {
            calendarSubViewDataArray.removeRange(Range(start: calendarSubViewDataArray.count - 3, end: calendarSubViewDataArray.count))
        } else if subScrollViewToRemoveIndex == 2 {
            calendarSubViewDataArray.removeRange(Range(start: 0, end: 3))
        }
        
        for scrollViewToMove in subScrollViewArray {
            if subScrollViewToRemoveIndex == 0 {
                scrollViewToMove.frame.origin = CGPoint(x: scrollViewToMove.frame.origin.x - scrollViewToRemove.frame.width, y: scrollViewToMove.frame.origin.y)
            } else if subScrollViewToRemoveIndex == 2 {
                scrollViewToMove.frame.origin = CGPoint(x: scrollViewToMove.frame.origin.x + scrollViewToRemove.frame.width, y: scrollViewToMove.frame.origin.y)
            }
        }
        
        switch subScrollViewToRemoveIndex {
        case 0:
            createSubScrollViewWithFrameAndRootDate(CGRect(x: mainScrollView.bounds.width * 2, y: 0, width: mainScrollView.bounds.width, height: mainScrollView.bounds.height), rootMonth: rootData!.month, rootYear: rootData!.year, index: 2)
        case 2:
            createSubScrollViewWithFrameAndRootDate(CGRect(x: 0, y: 0, width: mainScrollView.bounds.width, height: mainScrollView.bounds.height), rootMonth: rootData!.month, rootYear: rootData!.year, index: 0)
        default:
            break
        }
        
        mainScrollView.scrollRectToVisible(CGRect(x: mainScrollView.bounds.width, y: 0, width: mainScrollView.bounds.width, height: mainScrollView.bounds.height), animated: false)
    }
    
    private func getCalendarSubviewDataByIndexes(mainScrollViewIndex mainScrollViewIndex: Int, subScrollViewIndex: Int) -> DVCalendarSubViewData? {
        for data in calendarSubViewDataArray {
            if data.mainScrollViewIndex == mainScrollViewIndex && data.subScrollViewIndex == subScrollViewIndex {
                return data
            }
        }
        return nil
    }
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
    
    var monthTextFontSize: CGFloat!
    var yearTextFontSize: CGFloat!
    var dayLabelFontSize: CGFloat!
    
    let lineWidth: CGFloat = 6
    let lineColor = UIColor(red: 0.604, green: 0.898, blue: 0.988, alpha: 1.0)
    
    var monthLabelArray = [UILabel]()
    weak var yearLabel: UILabel!
    let distanceBetweenMonthLabels: CGFloat = 10
    
    let bgColor = UIColor(red: 0.361, green: 0.816, blue: 0.949, alpha: 1.0)
    let daysColor = UIColor.whiteColor()
    let monthColor = UIColor.whiteColor()
    let yearColor = UIColor.whiteColor()
    
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
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            if UIScreen.mainScreen().bounds.size.width > 320 {
                monthTextFontSize = 16
                yearTextFontSize = 19
                dayLabelFontSize = 13
            } else {
                monthTextFontSize = 13
                yearTextFontSize = 18
                dayLabelFontSize = 11
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        let cornerPath = UIBezierPath(roundedRect: rect, byRoundingCorners: [UIRectCorner.TopLeft, UIRectCorner.TopRight], cornerRadii: CGSize(width: 8, height: 5))
        cornerPath.addClip()
        cornerPath.closePath()
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, bgColor.CGColor)
        CGContextFillRect(context, rect)
        
        removeAllSubViewInMainView()
        removeAllMonthLabelArray()
        
        let halfHeight = self.bounds.height/2
        
        addMonthLabels()
        addYearLabel()
        
        let dayArray = ["M", "T", "W", "T", "F", "S", "S"]
        
        for i in 0...6 {
            let dayLabelSize = CGSize(width: self.bounds.width/7, height: halfHeight - lineWidth - lineWidth/2)
            let dayLabelOriginPoint = CGPoint(x: CGFloat(i) * dayLabelSize.width, y: halfHeight)
            let dayLabel = UILabel(frame: CGRect(origin: dayLabelOriginPoint, size: dayLabelSize))
            dayLabel.text = dayArray[i]
            dayLabel.textColor = daysColor
            dayLabel.font = UIFont(name: "Helvetica", size: dayLabelFontSize)
            dayLabel.textAlignment = .Center
            self.addSubview(dayLabel)
            dayLabelArray.append(dayLabel)
        }
        
        let linePath = UIBezierPath()
//        linePath.moveToPoint(CGPoint(x: lineWidth, y: self.bounds.height - lineWidth - lineWidth/2))
//        linePath.addLineToPoint(CGPoint(x: self.bounds.width - lineWidth, y: self.bounds.height - lineWidth - lineWidth/2))
        linePath.moveToPoint(CGPoint(x: 0, y: self.bounds.height - lineWidth/2))
        linePath.addLineToPoint(CGPoint(x: self.bounds.width, y: self.bounds.height - lineWidth/2))
        lineColor.setStroke()
        linePath.lineWidth = lineWidth
        linePath.stroke()
        linePath.closePath()
    }
    
    
    private func addMonthLabelWithMonthValue(value: Int, index: Int) {
        let halfHeight = self.bounds.height/2
        
        let monthText: NSString = DVCalendarAPI.shareInstance.convertMonthValueToText(monthValue: value) as NSString
        let monthTextSize: CGSize = monthText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(monthTextFontSize+2)])
        
        var monthLabelOriginX: CGFloat = 0
        for label in monthLabelArray {
            monthLabelOriginX += label.bounds.width + distanceBetweenMonthLabels
        }
        
        let monthLabel = UILabel(frame: CGRect(x: margin + monthLabelOriginX, y: margin, width: monthTextSize.width, height: halfHeight - margin))
        monthLabel.text = monthText as String
        monthLabel.font = index == 1 ? UIFont(name: "Helvetica-Bold", size: monthTextFontSize) : UIFont(name: "Helvetica", size: monthTextFontSize)
        monthLabel.textAlignment = NSTextAlignment.Center
        
//        monthLabel.textColor = index == 1 ? UIColor.blackColor() : UIColor.lightGrayColor()
        monthLabel.textColor = monthColor
        monthLabel.alpha = index == 1 ? 1.0 : 0.5
        
        self.addSubview(monthLabel)
        monthLabelArray.append(monthLabel)
    }
    
    private func addMonthLabels() {
        for i in 0...2 {
            let getDate = DVCalendarAPI.shareInstance.getDateAfterAddNewDate(currentDay: 1, currentMonth: monthValue, currentYear: 2000, numberDayToAdd: 0, numberMonthToAdd: i-1, numberYearToAdd: 0)
            let currentMonthValue = Int(getDate["Month"]!)
            addMonthLabelWithMonthValue(currentMonthValue, index: i)
        }
    }
    
    private func addYearLabel() {
        let halfHeight = self.bounds.height/2
        
        let yearText: NSString = String(yearValue) as NSString
        let yearTextSize: CGSize = yearText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(yearTextFontSize+2)])
        
        let yearLab = UILabel(frame: CGRect(x: self.bounds.width - margin - yearTextSize.width, y: margin, width: yearTextSize.width, height: halfHeight - margin))
        yearLab.text = yearText as String
        yearLab.textColor = yearColor
        yearLab.font = UIFont(name: "Helvetica-Bold", size: yearTextFontSize)
        yearLab.textAlignment = NSTextAlignment.Center
        self.addSubview(yearLab)
        
//        yearLab.translatesAutoresizingMaskIntoConstraints = false
//        
//        self.addConstraint(NSLayoutConstraint(item: yearLab, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -margin))
//        self.addConstraint(NSLayoutConstraint(item: yearLab, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: margin))
//        self.addConstraint(NSLayoutConstraint(item: yearLab, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: yearLab.bounds.width))
//        self.addConstraint(NSLayoutConstraint(item: yearLab, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: yearLab.bounds.height))
        
        yearLabel = yearLab
    }
    
    private func removeAllSubViewInMainView() {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
    }
    
    private func removeAllMonthLabelArray() {
        for subLabel in monthLabelArray {
            subLabel.removeFromSuperview()
        }
        monthLabelArray.removeAll()
    }
    
    func refreshDateLabelsByNewValue(month month: Int, year: Int, animate: Bool) {
        if self.monthValue != month {
            self.monthValue = month
            refreshMonthLabels(animate: animate)
        }
        if self.yearValue != year {
            self.yearValue = year
            refreshYearLabels(animate: animate)
        }
    }
    
    private func refreshMonthLabels(animate animate: Bool) {
        if animate {
            UIView.animateWithDuration(0.3, animations: {
                for subLabel in self.monthLabelArray {
                    subLabel.alpha = 0
                }
            }, completion: { finished in
                self.removeAllMonthLabelArray()
                self.addMonthLabels()
                for subLabel in self.monthLabelArray {
                    subLabel.alpha = 0
                }
                UIView.animateWithDuration(0.3, animations: {
                    for var i=0; i<self.monthLabelArray.count; i++ {
                        let subLabel: UILabel = self.monthLabelArray[i] as UILabel
                        subLabel.alpha = i==1 ? 1.0 : 0.5
                    }
                })
            })
        }
    }
    
    private func refreshYearLabels(animate animate: Bool) {
        if animate {
            UIView.animateWithDuration(0.3, animations: {
                self.yearLabel.alpha = 0
            }, completion: { finished in
                self.yearLabel.text = "\(self.yearValue)"
                UIView.animateWithDuration(0.3, animations: {
                    self.yearLabel.alpha = 1
                })
            })
        }
    }
}


//---------------------------------------------------------------//
//--------------------------- BOXDAY ----------------------------//
//---------------------------------------------------------------//

class BoxDay: UIButton {
    
    enum TodayBackgroundType {
        case Line
        case Oval
        case Arc
    }
    
    var day: Int!
    var month: Int!
    var year: Int!
    var backgroundType: TodayBackgroundType = TodayBackgroundType.Oval
    
    let lineWidth: CGFloat = 3
    let subLineWidth: CGFloat = 3
    let pi: CGFloat = CGFloat(M_PI)
    
//    var todayBgColor = UIColor(red: 0.361, green: 0.816, blue: 0.949, alpha: 1.0)
//    var subTodayBgColor = UIColor(red: 0.604, green: 0.898, blue: 0.988, alpha: 1.0)
    
    var todayBgColor = UIColor.clearColor()
    var subTodayBgColor = UIColor.clearColor()

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if todayBgColor != UIColor.clearColor() {
            switch backgroundType {
            case .Line:
                let linePath = UIBezierPath()
                linePath.moveToPoint(CGPoint(x: lineWidth*2, y: self.bounds.height - lineWidth - lineWidth/2))
                linePath.addLineToPoint(CGPoint(x: self.bounds.width - lineWidth*2, y: self.bounds.height - lineWidth - lineWidth/2))
                todayBgColor.setStroke()
                linePath.lineWidth = lineWidth
                linePath.stroke()
                linePath.closePath()

            case .Oval:
                let ovalRadius = min(self.bounds.width, self.bounds.height)
                let ovalX = self.frame.width - ovalRadius < 0 ? 0 : (self.frame.width - ovalRadius)/2
                let ovalY = self.frame.height - ovalRadius < 0 ? 0 : (self.frame.height - ovalRadius)/2
                let ovalRect = CGRect(x: ovalX, y: ovalY, width: ovalRadius, height: ovalRadius)
                let ovalPath = UIBezierPath(ovalInRect: ovalRect)
                todayBgColor.setFill()
                ovalPath.fill()
                self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

            case .Arc:
                let centerPoint = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
                let radius = min(self.bounds.width, self.bounds.height)/2 - lineWidth/2 - 3
                
                let startAngle: CGFloat = pi/2
                let endAngle: CGFloat = pi/2 + (2*pi)
                
                let arcPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                todayBgColor.setStroke()
                arcPath.lineWidth = lineWidth
                arcPath.stroke()
                arcPath.closePath()
                
                let subArcPath = UIBezierPath(arcCenter: centerPoint, radius: radius - lineWidth/2 - subLineWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                subTodayBgColor.setStroke()
                subArcPath.lineWidth = subLineWidth
                subArcPath.stroke()
                subArcPath.closePath()
            }
            
            
        }
    }
    
    func addTodayBackground(color color: UIColor, subColor: UIColor?, bgType: TodayBackgroundType) {
        todayBgColor = color
        subTodayBgColor = subColor == nil ? UIColor.clearColor() : subColor!
        backgroundType = bgType
        self.setNeedsDisplay()
    }
}

//---------------------------------------------------------------//
//--------------------------- DVCALENDARDATA --------------------//
//---------------------------------------------------------------//

class DVCalendarSubViewData {
    var subScrollViewIndex: Int
    var mainScrollViewIndex: Int
    var day: Int!
    var month: Int!
    var year: Int!
    
    init(subScrollViewIndex: Int, mainScrollViewIndex: Int, day: Int, month: Int, year: Int) {
        self.subScrollViewIndex = subScrollViewIndex
        self.mainScrollViewIndex = mainScrollViewIndex
        self.day = day
        self.month = month
        self.year = year
    }
    
    func setNewDate(day day: Int, month: Int, year: Int) {
        self.day = day
        self.month = month
        self.year = year
    }
    
    func setNewData(newData: DVCalendarSubViewData) {
        self.subScrollViewIndex = newData.subScrollViewIndex
        self.mainScrollViewIndex = newData.mainScrollViewIndex
        self.day = newData.day
        self.month = newData.month
        self.year = newData.year
    }
    
    func getDateString() -> String {
        return "\(day)/\(month)/\(year)"
    }
    
    func description() -> String {
        return "\(mainScrollViewIndex)-\(subScrollViewIndex) : \(getDateString())"
    }
}


//---------------------------------------------------------------//
//------------------------ DVCALENDARAPI ------------------------//
//---------------------------------------------------------------//

class DVCalendarAPI {
    
    class var shareInstance: DVCalendarAPI {
        struct Singleton {
            static let instance = DVCalendarAPI()
        }
        return Singleton.instance
    }

    func getNumberDaysInMonthOfYear(month month: Int, year: Int) -> Int {
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
    
    func getDayOfWeek(day day: Int, month: Int, year: Int)->Int {
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
    
    func getTodayDate() -> [String:Int] {
        let todayDate = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let component = calendar!.components([NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: todayDate)
        return [
            "Day" : component.day,
            "Month" : component.month,
            "Year" : component.year
        ]
    }
    
    func convertMonthValueToText(monthValue monthValue: Int) -> String {
        let monthArray = ["January","February","March","April","May","June","July","August","September","October","November","December"]
        return monthArray[monthValue-1]
    }
    
    func getDateAfterAddNewDate(currentDay currentDay: Int, currentMonth: Int, currentYear: Int, numberDayToAdd: Int, numberMonthToAdd: Int, numberYearToAdd: Int) -> [String:Int]! {
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
