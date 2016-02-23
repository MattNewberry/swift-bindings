//
//  MyView.swift
//  Alpha
//
//  9/21/14
//  Copyright (c) 2014 OpenTable. All rights reserved.
//

import UIKit

class MyView: UIView {
    var label: UILabel
    
    var customVar: String? {
        didSet {
            print("\(oldValue) is now \(customVar)")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        label = UILabel()
        super.init(coder: aDecoder)
        self.addSubview(label)
    }
    
    override func layoutSubviews() {
        label.frame = CGRectInset(self.bounds, 10, 10)
    }
}

class MyViewModel: NSObject {
    dynamic var labelBackgroundColor: UIColor = UIColor.redColor()
    dynamic var labelText: String = "hello!"
    dynamic var labelFont: UIFont = UIFont.systemFontOfSize(15)
    dynamic var labelTextColor: UIColor = UIColor.greenColor()
    dynamic var backgroundColor: UIColor = UIColor.blueColor()
    dynamic var alpha: Float = 1.0
    dynamic var customVar: String = "custom!"
    
    func objectDidUpdate(obj: AnyObject!) {
        let overdue = false
        
        if overdue {
            labelBackgroundColor = UIColor.redColor()
        } else {
            labelBackgroundColor = UIColor.blackColor()
        }
    }
}