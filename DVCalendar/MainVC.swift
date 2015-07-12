//
//  MainVC.swift
//  DVCalendar
//
//  Created by Vinh Dang Duc on 7/10/15.
//  Copyright © 2015 Vinh Dang Duc. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    
    weak var calendar: DVCalendar?
    let deviceHeight = UIScreen.mainScreen().bounds.size.height
    let deviceWidth = UIScreen.mainScreen().bounds.size.width
    
    let margin: CGFloat = 10

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cal = DVCalendar(target: self, frame: CGRect(x: margin, y: margin, width: deviceWidth - (2*margin), height: deviceHeight/2))
        cal.show()
        calendar = cal
        
        view.addConstraint(NSLayoutConstraint(item: cal.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: margin))
        view.addConstraint(NSLayoutConstraint(item: cal.view, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: margin))
        view.addConstraint(NSLayoutConstraint(item: cal.view, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: -margin))
        view.addConstraint(NSLayoutConstraint(item: cal.view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: deviceHeight/2))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
