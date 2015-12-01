//
//  DVAlertViewController.swift
//  DVAlertViewController
//
//  Created by Đặng Vinh on 3/29/15.
//  Copyright (c) 2015 DVISoft. All rights reserved.
//

import UIKit

class DVAlertViewButton: UIButton {
    enum DVAlertViewButtonType {
        case Important, Normal, Cancel
    }
    var alertViewButtonType = DVAlertViewButtonType.Normal
    var title: String? {
        willSet(value) {
            setTitle(value, forState: .Normal)
        }
    }
    var shadowColor: UIColor?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 3.0
        self.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
//        let path = UIBezierPath(rect: CGRect(x: 0, y: self.frame.height-4, width: self.frame.width, height: 4))
//        shadowColor!.setFill()
//        path.fill()
    }
}

@objc protocol DVAlertViewControllerDelegate {
    optional func dvAlertViewWillAppear(dvAlertView dvAlertView: DVAlertViewController)
    optional func dvAlertViewWillDisappear(dvAlertView dvAlertView: DVAlertViewController)
    optional func dvAlertViewDidAppear(dvAlertView dvAlertView: DVAlertViewController)
    optional func dvAlertViewDidDisappear(dvAlertView dvAlertView: DVAlertViewController)
    optional func dvAlertView(dvAlertView dvAlertView: DVAlertViewController, didClickButtonAtIndex: Int)
}

class DVAlertViewController: UIViewController {
    
    enum DVAlertViewStyle {
        case Success, Info, Warning, Error, Notice, Normal
    }
    
    enum DVAlertViewCurrentState {
        case Hide, Show
    }
    
    var deviceWidth = UIScreen.mainScreen().bounds.width
    var deviceHeight = UIScreen.mainScreen().bounds.height
    var alertBodyViewWidth: CGFloat = 250
    var alertBodyViewHeight: CGFloat = 210
//    let alertStyleBodyViewWidth: CGFloat = 225
//    let alertStyleBodyViewHeight: CGFloat = 45
    let alertStyleBodyViewWidth: CGFloat = 0
    let alertStyleBodyViewHeight: CGFloat = 0

    let alertTitleWidth: CGFloat = 225
    let alertTitleHeight: CGFloat = 30
    var alertSubTitleWidth: CGFloat = 225
    var alertSubTitleHeight: CGFloat = 60
    var alertButtonWidth: CGFloat = 234
    var alertButtonHeight: CGFloat = 35
    
//    let alertStyleBodyViewMarginTop: CGFloat = -14
//    let distanceAlertStyleBodyViewAndAlertTitleLabel: CGFloat = 10
    let alertStyleBodyViewMarginTop: CGFloat = 0
    let distanceAlertStyleBodyViewAndAlertTitleLabel: CGFloat = 15
    
    let distanceAlertTitleLabelAndAlertSubTitleTextView: CGFloat = 10
    let distanceAlertSubTitleTextViewAndButton: CGFloat = 20
    let distanceButtonAndButton: CGFloat = 8
    
    let defaultFont = "HelveticaNeue"
    let buttonFont = "HelveticaNeue-Bold"
    
    weak var vibrancyView: UIView?
    
    var containerView = UIView()
    var alertBodyView = UIView()
    var alertStyleBodyView = UIView()
    var alertTitleLabel = UILabel()
    var alertSubTitleTextView = UITextView()
    var alertButtons = [DVAlertViewButton]()
    var alertViewStyle: DVAlertViewStyle?
    var alertViewCurrentState: DVAlertViewCurrentState = .Hide
    var delegate: DVAlertViewControllerDelegate?
    
    let successColor = UIColor(red: 0.263, green: 0.824, blue: 0.620, alpha: 1.0)
    let infoColor = UIColor(red: 0.208, green: 0.706, blue: 0.894, alpha: 1.0)
    let warningColor = UIColor(red: 0.867, green: 0.765, blue: 0.333, alpha: 1.0)
    let errorColor = UIColor(red: 0.973, green: 0.145, blue: 0.251, alpha: 1.0)
    let noticeColor = UIColor(red: 0.910, green: 0.431, blue: 0.537, alpha: 1.0)
    let normalColor = UIColor(red: 0.686, green: 0.686, blue: 0.686, alpha: 1.0)
    
    let shadowSuccessColor = UIColor(red: 0.569, green: 0.925, blue: 0.682, alpha: 1)
    let shadowInfoColor = UIColor(red: 0.157, green: 0.576, blue: 0.839, alpha: 1)
    let shadowWarningColor = UIColor(red: 0.941, green: 0.91, blue: 0.541, alpha: 1)
    let shadowErrorColor = UIColor(red: 0.839, green: 0.165, blue: 0.165, alpha: 1)
    let shadowNoticeColor = UIColor(red: 0.933, green: 0.537, blue: 0.537, alpha: 1)
    let shadowNormalColor = UIColor(red: 0.157, green: 0.576, blue: 0.839, alpha: 1)
    
    let alertBodyViewBorderWidth: CGFloat = 0.0
    let alertBodyViewCornerRadius: CGFloat = 5.0
    
    var alertTitle: String? {
        set(value) { alertTitleLabel.text = value }
        get { return self.alertTitle }
    }
    
    var alertSubTitle: String? {
        set(value) {
            alertSubTitleTextView.text = value
            checkingHeightOfSubTitleViewWithTitle(subTitle: value!)
        }
        get { return self.alertSubTitle }
    }
    
    var duration: NSTimeInterval? = 0.7
    
    /////////////////// Setting values ///////////////////
    
    weak var target: UIViewController?
    private var maxNumberOfButtons = 6
    private var maxNumberOfButtonLines = 3
    private var maxNumberOfButtonsInALine = 1
    private var existedCancelButton = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        initAllViews()
    }
    
    convenience init(target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, duration: NSTimeInterval, alertViewStyle: DVAlertViewStyle, cancelButtonTitle: String, otherButtonsTitles: [String]?, animate: Bool) {
        self.init(nibName: nil, bundle: nil)
        initAllViews()
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: alertViewStyle, duration: duration, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: true, show: false)
    }
    
    private func initAllViews() {
        setupView()
        setupAlertBodyView()
        //setupAlertStyleBodyView()
        setupAlertTitleLabel()
        setupAlertSubTitleTextView()
        
        view.addSubview(alertBodyView)
        //alertBodyView.addSubview(alertStyleBodyView)
        alertBodyView.addSubview(alertTitleLabel)
        alertBodyView.addSubview(alertSubTitleTextView)
        
        //addVibrancyEffectToView(self.view)
        view.bringSubviewToFront(self.alertBodyView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    private func setupView() {
        view.frame = UIScreen.mainScreen().bounds
        view.backgroundColor = UIColor.clearColor()
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
    }
    
    private func setupAlertBodyView() {
        alertBodyView.frame = CGRectMake(0, 0, alertBodyViewWidth, alertBodyViewHeight)
        alertBodyView.center = CGPoint(x: deviceWidth/2, y: deviceHeight/2)
        alertBodyView.backgroundColor = UIColor.whiteColor()
        alertBodyView.layer.masksToBounds = true
        alertBodyView.layer.cornerRadius = alertBodyViewCornerRadius
    }

    private func setupAlertStyleBodyView() {
        let xPos = (alertBodyViewWidth - alertStyleBodyViewWidth)/2
        let yPos = alertStyleBodyViewMarginTop
        alertStyleBodyView.frame = CGRectMake(xPos, yPos, alertStyleBodyViewWidth, alertStyleBodyViewHeight)
        alertStyleBodyView.layer.cornerRadius = 5.0
    }
    
    private func setupAlertTitleLabel() {
        let xPos = (alertBodyViewWidth - alertTitleWidth)/2
        let yPos = CGRectGetMaxY(alertStyleBodyView.frame) + distanceAlertStyleBodyViewAndAlertTitleLabel
        alertTitleLabel.frame = CGRectMake(xPos, yPos, alertTitleWidth, alertTitleHeight)
        alertTitleLabel.numberOfLines = 1
        alertTitleLabel.textAlignment = .Center
        alertTitleLabel.font = UIFont(name: defaultFont, size: 20)
        alertTitleLabel.text = "Success"
    }
    
    private func setupAlertSubTitleTextView() {
        let xPos = (alertBodyViewWidth - alertSubTitleWidth)/2
        let yPos = CGRectGetMaxY(alertTitleLabel.frame) + distanceAlertTitleLabelAndAlertSubTitleTextView
        alertSubTitleTextView.frame = CGRectMake(xPos, yPos, alertSubTitleWidth, 0)
        alertSubTitleTextView.editable = false
        alertSubTitleTextView.scrollEnabled = false
        alertSubTitleTextView.textAlignment = .Center
        alertSubTitleTextView.textContainerInset = UIEdgeInsetsZero
        alertSubTitleTextView.textContainer.lineFragmentPadding = 0;
        alertSubTitleTextView.font = UIFont(name: defaultFont, size:14)
        alertSubTitleTextView.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do"
    }
    
    // MARK: - Show alert methods
    
    // No delegate, duration,  otherButtonsTitles, animate (Only cancel button)
    
    func showAlertSuccess(target target: UIViewController, title: String, subTitle: String, cancelButtonTitle: String) {
        setupAlertWithTitle(target: target, delegate: nil, title: title, subTitle: subTitle, alertViewStyle: .Success, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: nil, animate: true, show: true)
    }
    
    func showAlertInfo(target target: UIViewController, title: String, subTitle: String, cancelButtonTitle: String) {
        setupAlertWithTitle(target: target, delegate: nil, title: title, subTitle: subTitle, alertViewStyle: .Info, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: nil, animate: true, show: true)
    }
    
    func showAlertWarning(target target: UIViewController, title: String, subTitle: String, cancelButtonTitle: String) {
        setupAlertWithTitle(target: target, delegate: nil, title: title, subTitle: subTitle, alertViewStyle: .Warning, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: nil, animate: true, show: true)
    }
    
    func showAlertError(target target: UIViewController, title: String, subTitle: String, cancelButtonTitle: String) {
        setupAlertWithTitle(target: target, delegate: nil, title: title, subTitle: subTitle, alertViewStyle: .Error, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: nil, animate: true, show: true)
    }
    
    func showAlertNotice(target target: UIViewController, title: String, subTitle: String, cancelButtonTitle: String) {
        setupAlertWithTitle(target: target, delegate: nil, title: title, subTitle: subTitle, alertViewStyle: .Notice, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: nil, animate: true, show: true)
    }
    
    func showAlertNormal(target target: UIViewController, title: String, subTitle: String, cancelButtonTitle: String) {
        setupAlertWithTitle(target: target, delegate: nil, title: title, subTitle: subTitle, alertViewStyle: .Normal, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: nil, animate: true, show: true)
    }
    
    
    // No duration, animate
    
    func showAlertSuccess(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, cancelButtonTitle: String, otherButtonsTitles: [String]?) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Success, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: true, show: true)
    }
    
    func showAlertInfo(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, cancelButtonTitle: String, otherButtonsTitles: [String]?) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Info, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: true, show: true)
    }
    
    func showAlertWarning(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, cancelButtonTitle: String, otherButtonsTitles: [String]?) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Warning, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: true, show: true)
    }
    
    func showAlertError(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, cancelButtonTitle: String, otherButtonsTitles: [String]?) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Error, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: true, show: true)
    }
    
    func showAlertNotice(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, cancelButtonTitle: String, otherButtonsTitles: [String]?) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Notice, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: true, show: true)
    }
    
    func showAlertNormal(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, cancelButtonTitle: String, otherButtonsTitles: [String]?) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Normal, duration: 0.6, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: true, show: true)
    }
    
    // Full options
    
    func showAlertSuccess(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, duration: NSTimeInterval, cancelButtonTitle: String, otherButtonsTitles: [String]?, animate: Bool) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Success, duration: duration, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: animate, show: true)
    }
    
    func showAlertInfo(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, duration: NSTimeInterval, cancelButtonTitle: String, otherButtonsTitles: [String]?, animate: Bool) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Info, duration: duration, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: animate, show: true)
    }
    
    func showAlertWarning(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, duration: NSTimeInterval, cancelButtonTitle: String, otherButtonsTitles: [String]?, animate: Bool) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Warning, duration: duration, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: animate, show: true)
    }
    
    func showAlertError(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, duration: NSTimeInterval, cancelButtonTitle: String, otherButtonsTitles: [String]?, animate: Bool) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Error, duration: duration, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: animate, show: true)
    }
    
    func showAlertNotice(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, duration: NSTimeInterval, cancelButtonTitle: String, otherButtonsTitles: [String]?, animate: Bool) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Notice, duration: duration, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: animate, show: true)
    }
    
    func showAlertNormal(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, duration: NSTimeInterval, cancelButtonTitle: String, otherButtonsTitles: [String]?, animate: Bool) {
        setupAlertWithTitle(target: target, delegate: delegate, title: title, subTitle: subTitle, alertViewStyle: .Normal, duration: duration, cancelButtonTitle: cancelButtonTitle, otherButtonsTitles: otherButtonsTitles, animate: animate, show: true)
    }
    
    private func setupAlertWithTitle(target target: UIViewController, delegate: DVAlertViewControllerDelegate?, title: String, subTitle: String, alertViewStyle: DVAlertViewStyle, duration: NSTimeInterval, cancelButtonTitle: String, otherButtonsTitles: [String]?, animate: Bool, show: Bool) {
        
        if alertViewCurrentState == .Show { return }
        if delegate != nil { self.delegate = delegate }
        
        if !title.isEmpty { alertTitleLabel.text = title }
        else { alertTitleLabel.text = "Empty label" }
        
        self.duration = duration
        
        checkingHeightOfSubTitleViewWithTitle(subTitle: subTitle)
        if otherButtonsTitles != nil {
            var numberTitle = otherButtonsTitles?.count
            if numberTitle >= maxNumberOfButtons { numberTitle = maxNumberOfButtons - 1 }
            for var i = 0; i < numberTitle; i++ {
                let currentTitle = otherButtonsTitles![i]
                addButtonWithTitle(title: currentTitle, buttonType: .Normal, alertViewStyle: alertViewStyle)
            }
        }
        
        addButtonWithTitle(title: cancelButtonTitle, buttonType: .Cancel, alertViewStyle: alertViewStyle)
        
        self.target = target
        
        // Start animation
        if show { showAlert(animate: animate) }
    }
    
    func addButtonWithTitle(title title: String, buttonType: DVAlertViewButton.DVAlertViewButtonType, alertViewStyle: DVAlertViewStyle) {
        if alertButtons.count >= maxNumberOfButtons { return }
        let newButton = DVAlertViewButton()
        if buttonType == .Cancel {
            if !existedCancelButton { existedCancelButton = true }
            else { return }
        }
        newButton.alertViewButtonType = buttonType
        newButton.title = title
        changeButtonColor(button: newButton, alertViewStyle: alertViewStyle)
        
        let xPos = (alertBodyViewWidth - alertButtonWidth)/2
        var yPos: CGFloat?
        
        if alertButtons.count == 0 {
            yPos = CGRectGetMaxY(alertSubTitleTextView.frame) + distanceAlertSubTitleTextViewAndButton
            newButton.frame = CGRectMake(xPos, yPos!, alertButtonWidth, alertButtonHeight)
        } else {
            let lastButton = alertButtons.last as DVAlertViewButton!
            yPos = CGRectGetMaxY(lastButton.frame) + distanceButtonAndButton
            newButton.frame = CGRectMake(xPos, yPos!, alertButtonWidth, alertButtonHeight)
        }
        if buttonType != .Cancel {
            addNewValueToBodyViewHeightWithValue(alertButtonHeight + distanceButtonAndButton)
            newButton.tag = alertButtons.count + 1
        } else { newButton.tag = 0 }
        
        newButton.addTarget(self, action: Selector("buttonAction:"), forControlEvents: .TouchUpInside)
        alertBodyView.addSubview(newButton)
        alertButtons.append(newButton)
        
        sortingPositionsOfAllButtons()
    }
    
    func sortingPositionsOfAllButtons() {
    
        let horizontalDistance = (alertBodyViewWidth - alertButtonWidth)/4
        let newWidth = alertButtonWidth/2 - horizontalDistance
        
        var valueWidth = 0, valueHeight = 0
        if alertButtons.count > 3 {
            for var i = 0 ; i < alertButtons.count; i++ {
                    let currentButton = alertButtons[i] as DVAlertViewButton
                    let xPos = (alertBodyViewWidth - alertButtonWidth)/2 + (CGFloat(valueWidth) * newWidth) + (CGFloat(valueWidth) * horizontalDistance*2)
                    let yPos = CGRectGetMaxY(alertSubTitleTextView.frame) + distanceAlertSubTitleTextViewAndButton + (CGFloat(valueHeight) * alertButtonHeight) + (CGFloat(valueHeight) * distanceButtonAndButton)
                    currentButton.frame = CGRectMake(xPos, yPos, newWidth, alertButtonHeight)
                    valueWidth += 1
                if valueWidth == 2 {
                    valueHeight += 1
                    valueWidth = 0
                }
            }
            
            if alertButtons.count % 2 != 0 {
                let lastButton = alertButtons[alertButtons.count-1] as DVAlertViewButton
                lastButton.frame.size.width = alertButtonWidth
            }
        }
        
        var offsetValue: CGFloat = 0
        if alertButtons.count % 2 == 0 {
            offsetValue = CGFloat(alertButtons.count)/2
        } else {
            if alertButtons.count <= 3 {
                offsetValue = CGFloat(alertButtons.count)
            } else {
                offsetValue = CGFloat(ceil(Double(alertButtons.count)/2))
            }
        }
        let alertBodyViewNewHeight = (alertStyleBodyViewHeight + alertStyleBodyViewMarginTop) + distanceAlertStyleBodyViewAndAlertTitleLabel + alertTitleHeight + distanceAlertTitleLabelAndAlertSubTitleTextView + alertSubTitleHeight + distanceAlertSubTitleTextViewAndButton + (alertButtonHeight * offsetValue) + (distanceButtonAndButton * offsetValue) - alertBodyViewHeight
        addNewValueToBodyViewHeightWithValue(alertBodyViewNewHeight)
    }
    
    func showAlert(animate animate: Bool) {
        delegate?.dvAlertViewWillAppear?(dvAlertView: self)
        if target != nil {
            let vView = UIView()
            target?.view.addSubview(vView)
            
            vView.translatesAutoresizingMaskIntoConstraints = false
            target?.view.addConstraint(NSLayoutConstraint(item: vView, attribute: .Leading, relatedBy: .Equal, toItem: target?.view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
            target?.view.addConstraint(NSLayoutConstraint(item: vView, attribute: .Trailing, relatedBy: .Equal, toItem: target?.view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
            target?.view.addConstraint(NSLayoutConstraint(item: vView, attribute: .Top, relatedBy: .Equal, toItem: target?.view, attribute: .Top, multiplier: 1.0, constant: 0.0))
            target?.view.addConstraint(NSLayoutConstraint(item: vView, attribute: .Bottom, relatedBy: .Equal, toItem: target?.view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
            vView.backgroundColor = UIColor.blackColor()
            //addVibrancyEffectToView(vView)
            vibrancyView = vView
            
            target!.addChildViewController(self)
            target!.view.addSubview(self.view)
            self.didMoveToParentViewController(target!)
            target!.view.bringSubviewToFront(self.view)
        }
        
        if !existedCancelButton {
            if alertViewStyle == nil { alertViewStyle = .Normal }
            addButtonWithTitle(title: "Cancel", buttonType: .Cancel, alertViewStyle: alertViewStyle!)
        }
        showAlertAnimation(animate)
        delegate?.dvAlertViewDidAppear?(dvAlertView: self)
    }
    
    func hideAlert(animate: Bool) {
        delegate?.dvAlertViewWillDisappear?(dvAlertView: self)
        hideAlertAnimation(animate)
        delegate?.dvAlertViewDidDisappear?(dvAlertView: self)
    }
    
    private func showAlertAnimation(animate: Bool) {
        alertViewCurrentState = .Show
        // Prepare for animation
        alertBodyView.center = CGPoint(x: alertBodyView.center.x, y: -alertBodyView.bounds.height/2)
        self.view.alpha = 0
        vibrancyView?.alpha = 0
        
        if animate {
            UIView.animateWithDuration(self.duration!, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.view.alpha = 1
                self.vibrancyView?.alpha = 0.6
                self.alertBodyView.center = CGPoint(x: self.deviceWidth/2, y: self.deviceHeight/2)
                
                if self.target?.navigationController != nil {
                    self.target?.navigationController?.navigationBar.alpha = 0
                }
                
                }, completion: { finished in
                    if self.target?.navigationController != nil {
                        self.target?.navigationController?.navigationBar.hidden = true
                    }
            })
        } else {
            self.view.alpha = 1
            self.vibrancyView?.alpha = 0.6
            self.alertBodyView.center = CGPoint(x: self.deviceWidth/2, y: self.deviceHeight/2)
            
            if self.target?.navigationController != nil {
                self.target?.navigationController?.navigationBar.alpha = 0
                self.target?.navigationController?.navigationBar.hidden = true
            }
        }
    }
    
    private func hideAlertAnimation(animate: Bool) {
        alertViewCurrentState = .Hide
        if animate {
            UIView.animateWithDuration(self.duration!, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                self.alertBodyView.center = CGPoint(x: self.deviceWidth/2, y: -self.alertBodyView.bounds.height/2)
                self.view.alpha = 0
                self.vibrancyView?.alpha = 0
                
                if self.target?.navigationController != nil {
                    self.target?.navigationController?.navigationBar.hidden = false
                    self.target?.navigationController?.navigationBar.alpha = 1
                }
                
                }, completion: { finished in
                    self.view.removeFromSuperview()
                    self.willMoveToParentViewController(nil)
                    self.view = nil
                    
                    self.vibrancyView?.removeFromSuperview()
                    self.vibrancyView = nil
            })
        }
    }

    private func checkingHeightOfSubTitleViewWithTitle(subTitle subTitle: String) {
        if subTitle.isEmpty {
            alertSubTitleTextView.text = "I think you have forgot something..."
        } else {
            alertSubTitleTextView.text = subTitle
            
            let newSize = alertSubTitleTextView.sizeThatFits(CGSize(width: alertSubTitleWidth, height: 0))
            alertSubTitleHeight = newSize.height
            let ht = alertSubTitleHeight
            alertSubTitleTextView.frame.size.height = ht
            
            var valueChange: CGFloat?
            if ht < alertSubTitleHeight {
                valueChange = -(alertSubTitleHeight - CGFloat(ht))
                addNewValueToBodyViewHeightWithValue(valueChange!)
            } else {
                valueChange = CGFloat(ht) - alertSubTitleHeight
                addNewValueToBodyViewHeightWithValue(valueChange!)
            }
            
            if alertButtons.count != 0 {
                for button in alertButtons {
                    button.center = CGPoint(x: button.center.x, y: button.center.y + valueChange!)
                }
            }
        }
    }
    
    private func changeButtonColor(button button: DVAlertViewButton, alertViewStyle: DVAlertViewStyle) {
        switch(alertViewStyle) {
        case .Success:
            self.alertViewStyle = .Success
            alertStyleBodyView.backgroundColor = successColor
            button.backgroundColor = successColor
            button.shadowColor = shadowSuccessColor
        case .Info:
            self.alertViewStyle = .Info
            alertStyleBodyView.backgroundColor = infoColor
            button.backgroundColor = infoColor
            button.shadowColor = shadowInfoColor
        case .Warning:
            self.alertViewStyle = .Warning
            alertStyleBodyView.backgroundColor = warningColor
            button.backgroundColor = warningColor
            button.shadowColor = shadowWarningColor
        case .Error:
            self.alertViewStyle = .Error
            alertStyleBodyView.backgroundColor = errorColor
            button.backgroundColor = errorColor
            button.shadowColor = shadowErrorColor
        case .Notice:
            self.alertViewStyle = .Notice
            alertStyleBodyView.backgroundColor = noticeColor
            button.backgroundColor = noticeColor
            button.shadowColor = shadowNoticeColor
        case .Normal:
            self.alertViewStyle = .Normal
            alertStyleBodyView.backgroundColor = normalColor
            button.backgroundColor = normalColor
            button.shadowColor = shadowNormalColor
        }
        button.setNeedsDisplay()
    }
    
    private func addNewValueToBodyViewHeightWithValue(value: CGFloat) {
        alertBodyViewHeight += value
        alertBodyView.frame.size.height = alertBodyViewHeight
    }
    
    private func addVibrancyEffectToView(currentView: UIView) {
        let blurE: UIBlurEffect = UIBlurEffect(style: .Dark)
        let blurV: UIVisualEffectView = UIVisualEffectView(effect: blurE)
        blurV.frame = currentView.frame
        blurV.translatesAutoresizingMaskIntoConstraints = false
        currentView.addSubview(blurV)
    }
    
    // MARK: - Button methods
    
    func cancelAction(sender: DVAlertViewButton) {
        hideAlert(true)
    }
    
    func buttonAction(sender: DVAlertViewButton) {
        if sender.tag == 0 { hideAlert(true) }
        delegate?.dvAlertView?(dvAlertView: self, didClickButtonAtIndex: sender.tag)
    }
    
    // MARK: - Supporting methods
    
//    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
//        if toInterfaceOrientation.isLandscape {
//            
//        } else if toInterfaceOrientation.isPortrait {
//            
//        }
//    }

    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
//            var marginTopY = (deviceWidth - alertBodyViewWidth)/2
//            var marginTopX = (deviceHeight - alertBodyViewHeight)/2
//            alertBodyView.frame = CGRectMake(marginTopX, marginTopY, alertBodyViewWidth, alertBodyViewHeight)
//        } else {
//            var marginTopX = (deviceWidth - alertBodyViewWidth)/2
//            var marginTopY = (deviceHeight - alertBodyViewHeight)/2
//            alertBodyView.frame = CGRectMake(marginTopX, marginTopY, alertBodyViewWidth, alertBodyViewHeight)
//        }
//    }
    
}

